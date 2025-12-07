"""
Authentication router for JWT validation from Cognito.
"""
import os
from typing import Optional

import jwt
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt import PyJWKClient

router = APIRouter()
security = HTTPBearer()

# Get Cognito User Pool ID from environment variable
COGNITO_USER_POOL_ID = os.getenv("COGNITO_USER_POOL_ID")
COGNITO_REGION = os.getenv("AWS_REGION", "us-east-1")

if COGNITO_USER_POOL_ID:
    # Construct JWKS URL for Cognito
    JWKS_URL = (
        f"https://cognito-idp.{COGNITO_REGION}.amazonaws.com/"
        f"{COGNITO_USER_POOL_ID}/.well-known/jwks.json"
    )
    jwks_client = PyJWKClient(JWKS_URL)
else:
    jwks_client = None


async def verify_token(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    """
    Verify JWT token from Cognito.

    Args:
        credentials: HTTP Bearer token credentials

    Returns:
        Decoded token payload

    Raises:
        HTTPException: If token is invalid or missing
    """
    if not jwks_client:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Cognito configuration not available",
        )

    token = credentials.credentials

    try:
        # Get the signing key from JWKS
        signing_key = jwks_client.get_signing_key_from_jwt(token)

        # Decode and verify the token
        decoded_token = jwt.decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            audience=None,  # Cognito tokens don't always have audience
            options={
                "verify_signature": True,
                "verify_exp": True,
                "verify_aud": False,
            },
        )

        # Verify token issuer matches Cognito User Pool
        expected_issuer = (
            f"https://cognito-idp.{COGNITO_REGION}.amazonaws.com/"
            f"{COGNITO_USER_POOL_ID}"
        )
        if decoded_token.get("iss") != expected_issuer:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token issuer",
            )

        return decoded_token

    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
        )
    except jwt.InvalidTokenError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token: {str(e)}",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token verification failed: {str(e)}",
        )


@router.post("/auth/validate")
async def validate_token(token_data: dict = Depends(verify_token)):
    """
    Validate JWT token from Cognito.

    This endpoint validates the JWT token passed in the Authorization header
    and returns user information if valid.

    Returns:
        User information from the validated token
    """
    return {
        "valid": True,
        "user_id": token_data.get("sub"),
        "email": token_data.get("email"),
        "username": token_data.get("cognito:username"),
        "token_use": token_data.get("token_use"),
    }


@router.get("/auth/me")
async def get_current_user(token_data: dict = Depends(verify_token)):
    """
    Get current authenticated user information.

    Returns:
        Current user information from the validated token
    """
    return {
        "user_id": token_data.get("sub"),
        "email": token_data.get("email"),
        "username": token_data.get("cognito:username"),
        "token_use": token_data.get("token_use"),
    }

