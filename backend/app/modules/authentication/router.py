from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from app.modules.authentication.schemas import (
    UserRegisterRequest,
    UserLoginRequest,
    TokenResponse,
    RefreshTokenRequest,
    UserResponse
)
from app.modules.authentication.service import AuthService
from app.core.dependencies import get_current_user

router = APIRouter()

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(payload: UserRegisterRequest):
    """Register a new user account."""
    user = await AuthService.register_user(payload)
    return user

@router.post("/login", response_model=TokenResponse)
async def login(payload: UserLoginRequest):
    """Authenticate and obtain JWT access & refresh tokens."""
    tokens = await AuthService.authenticate_user(payload)
    return tokens

@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(payload: RefreshTokenRequest):
    """Exchange a valid refresh token for a new access token."""
    tokens = await AuthService.refresh_access_token(payload.refresh_token)
    return tokens

@router.post("/logout", status_code=status.HTTP_200_OK)
async def logout(current_user: dict = Depends(get_current_user)):
    """Invalidate the current session."""
    return {"message": "Successfully logged out"}
