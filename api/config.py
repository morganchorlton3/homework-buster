"""
Application configuration using Pydantic Settings.

Loads configuration from environment variables or .env file.
In Lambda, environment variables are set by Terraform.
For local development, a .env file can be used.
"""
from typing import List

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Cognito Configuration
    cognito_user_pool_id: str = Field(
        ...,
        description="AWS Cognito User Pool ID",
        alias="COGNITO_USER_POOL_ID",
    )
    cognito_region: str = Field(
        default="us-east-1",
        description="AWS region for Cognito",
        alias="AWS_REGION",
    )

    # CORS Configuration
    cors_allow_origins: str | List[str] = Field(
        default="*",
        description="Allowed CORS origins (comma-separated string or list)",
        alias="CORS_ALLOW_ORIGINS",
    )
    cors_allow_credentials: bool = Field(
        default=True,
        description="Allow credentials in CORS",
        alias="CORS_ALLOW_CREDENTIALS",
    )

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        # In Lambda, .env file won't exist, so we rely on environment variables
        env_ignore_empty=True,
        extra="ignore",
    )

    @property
    def jwks_url(self) -> str:
        """Construct JWKS URL for Cognito."""
        return (
            f"https://cognito-idp.{self.cognito_region}.amazonaws.com/"
            f"{self.cognito_user_pool_id}/.well-known/jwks.json"
        )

    @property
    def expected_issuer(self) -> str:
        """Get expected token issuer URL."""
        return (
            f"https://cognito-idp.{self.cognito_region}.amazonaws.com/"
            f"{self.cognito_user_pool_id}"
        )

    def parse_cors_origins(self) -> List[str]:
        """
        Parse CORS origins from environment variable.

        Supports comma-separated string or list format.
        """
        if isinstance(self.cors_allow_origins, str):
            # Handle comma-separated string
            origins = [origin.strip() for origin in self.cors_allow_origins.split(",")]
            # If it's just "*", return as-is
            if origins == ["*"]:
                return ["*"]
            return origins
        # Already a list
        return self.cors_allow_origins


# Global settings instance
# This will be initialized when the module is imported
settings = Settings(ignore_extra=True, ignore_case=True)

