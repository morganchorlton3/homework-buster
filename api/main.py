"""
FastAPI application for Homework Buster API.
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.config import settings
from api.routers import auth

app = FastAPI(
    title="Homework Buster API",
    description="Backend API for Homework Buster mobile app",
    version="1.0.0",
)

# Configure CORS for mobile app using settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.parse_cors_origins(),
    allow_credentials=settings.cors_allow_credentials,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Include routers
app.include_router(auth.router, prefix="/api/v1", tags=["auth"])


@app.get("/")
async def root():
    """Health check endpoint."""
    return {"status": "ok", "message": "Homework Buster API"}


@app.get("/health")
async def health():
    """Health check endpoint."""
    return {"status": "healthy"}

