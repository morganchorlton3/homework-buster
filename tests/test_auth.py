"""
Unit tests for authentication router.
"""
import os
from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient

from api.main import app

client = TestClient(app)


@pytest.fixture
def mock_jwks_client():
    """Mock JWKS client for testing."""
    with patch("api.routers.auth.jwks_client") as mock_client:
        mock_key = MagicMock()
        mock_key.key = "test-signing-key"
        mock_client.get_signing_key_from_jwt.return_value = mock_key
        yield mock_client


@pytest.fixture
def mock_cognito_env():
    """Set up mock Cognito environment variables."""
    with patch.dict(
        os.environ,
        {
            "COGNITO_USER_POOL_ID": "us-east-1_test123",
            "AWS_REGION": "us-east-1",
        },
    ):
        yield


@pytest.fixture
def valid_token_payload():
    """Valid JWT token payload for testing."""
    return {
        "sub": "user-123",
        "email": "test@example.com",
        "cognito:username": "testuser",
        "token_use": "access",
        "iss": "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_test123",
        "exp": 9999999999,  # Far future expiration
    }


def test_root_endpoint():
    """Test root endpoint returns health status."""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "message": "Homework Buster API"}


def test_health_endpoint():
    """Test health endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


@patch("api.routers.auth.jwt.decode")
def test_validate_token_success(
    mock_jwt_decode, mock_jwks_client, mock_cognito_env, valid_token_payload
):
    """Test successful token validation."""
    mock_jwt_decode.return_value = valid_token_payload

    # Reload the auth module to pick up the new environment variables
    import importlib
    from api import routers

    importlib.reload(routers.auth)

    response = client.post(
        "/api/v1/auth/validate",
        headers={"Authorization": "Bearer valid-token"},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["valid"] is True
    assert data["user_id"] == "user-123"
    assert data["email"] == "test@example.com"


@patch("api.routers.auth.jwt.decode")
def test_validate_token_expired(mock_jwt_decode, mock_jwks_client, mock_cognito_env):
    """Test token validation with expired token."""
    import jwt

    mock_jwt_decode.side_effect = jwt.ExpiredSignatureError("Token expired")

    # Reload the auth module
    import importlib
    from api import routers

    importlib.reload(routers.auth)

    response = client.post(
        "/api/v1/auth/validate",
        headers={"Authorization": "Bearer expired-token"},
    )

    assert response.status_code == 401
    assert "expired" in response.json()["detail"].lower()


def test_validate_token_missing_header(mock_cognito_env):
    """Test token validation without Authorization header."""
    # Reload the auth module
    import importlib
    from api import routers

    importlib.reload(routers.auth)

    response = client.post("/api/v1/auth/validate")

    assert response.status_code == 403


@patch("api.routers.auth.jwt.decode")
def test_get_current_user(
    mock_jwt_decode, mock_jwks_client, mock_cognito_env, valid_token_payload
):
    """Test getting current user information."""
    mock_jwt_decode.return_value = valid_token_payload

    # Reload the auth module
    import importlib
    from api import routers

    importlib.reload(routers.auth)

    response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": "Bearer valid-token"},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["user_id"] == "user-123"
    assert data["email"] == "test@example.com"
    assert data["username"] == "testuser"




