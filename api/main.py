"""
FastAPI application for Homework Buster API.
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.routers import auth

app = FastAPI(
    title="Homework Buster API",
    description="Backend API for Homework Buster mobile app",
    version="1.0.0",
)

# Configure CORS for mobile app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
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

