from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_db, get_current_user, get_current_active_user
from app.models.user import User
from app.modules.authentication.schemas import (
    UserRegisterRequest,
    UserLoginRequest,
    TokenResponse,
    RefreshTokenRequest,
    RegisterResponse,
    UserResponse,
    MessageResponse,
)
from app.modules.authentication.service import auth_service

router = APIRouter()

@router.post("/register", response_model=RegisterResponse, status_code=status.HTTP_201_CREATED)
async def register(payload: UserRegisterRequest, db: AsyncSession = Depends(get_db)):
    """
    Register a new user account.
    Returns the created user along with an initial JWT token pair.
    """
    return await auth_service.register_user(payload, db)

@router.post("/login", response_model=TokenResponse)
async def login(payload: UserLoginRequest, db: AsyncSession = Depends(get_db)):
    """
    Authenticate user credentials and return a fresh access and refresh token pair.
    """
    return await auth_service.authenticate_user(payload.email, payload.password, db)

@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(payload: RefreshTokenRequest, db: AsyncSession = Depends(get_db)):
    """
    Exchange a valid refresh token for a new access token and rotated refresh token.
    """
    return await auth_service.refresh_token(payload.refresh_token, db)

@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_active_user)):
    """
    Retrieve profile details of the currently authenticated user.
    """
    return UserResponse.model_validate(current_user)

@router.post("/logout", response_model=MessageResponse, status_code=status.HTTP_200_OK)
async def logout(current_user: User = Depends(get_current_user)):
    """
    Invalidate the current session.
    """
    await auth_service.logout_user(str(current_user.id))
    return MessageResponse(message="Successfully logged out.")
