# Homework Buster API

FastAPI backend for the Homework Buster mobile application.

## Setup

### Prerequisites

- Python 3.11+
- Poetry

### Installation

1. Install dependencies using Poetry:

```bash
poetry install
```

2. Activate the virtual environment:

```bash
poetry shell
```

## Development

### Running Locally

Set environment variables:

```bash
export COGNITO_USER_POOL_ID=your-user-pool-id
export AWS_REGION=us-east-1
```

Run the FastAPI development server:

```bash
poetry run uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

### API Documentation

Once running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Testing

Run tests:

```bash
poetry run pytest
```

Run tests with coverage:

```bash
poetry run pytest --cov=api --cov-report=html
```

## Deployment

The API is deployed to AWS Lambda using Terraform. See the `infrastructure/` directory for deployment configuration.

### Keeping Dependencies in Sync

The `requirements.txt` file is used by Terraform to build the Lambda package. Keep it in sync with `pyproject.toml`:

```bash
poetry export -f requirements.txt --output api/requirements.txt --without-hashes
```

### Environment Variables

The Lambda function requires the following environment variables:
- `COGNITO_USER_POOL_ID`: Cognito User Pool ID for JWT validation
- `AWS_REGION`: AWS region (defaults to us-east-1)

## API Endpoints

### Authentication

- `POST /api/v1/auth/validate` - Validate JWT token from Cognito
- `GET /api/v1/auth/me` - Get current authenticated user information

Both endpoints require a Bearer token in the Authorization header.

## Project Structure

```
api/
├── __init__.py
├── main.py              # FastAPI application
├── lambda_handler.py    # AWS Lambda handler
└── routers/
    ├── __init__.py
    └── auth.py          # Authentication routes

tests/
├── __init__.py
├── test_main.py         # Tests for main app
└── test_auth.py         # Tests for auth routes
```

