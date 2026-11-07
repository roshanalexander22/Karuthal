from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.config.database import get_db
from app.modules.authentication.schemas import (
    UserRegisterRequest,
    UserLoginRequest,
    TokenResponse,
    RefreshTokenRequest,
    RegisterResponse,
    UserResponse
)
from app.modules.authentication.service import AuthService
from app.core.dependencies import get_current_user

router = APIRouter()
auth_service = AuthService()

@router.post("/register", response_model=RegisterResponse, status_code=status.HTTP_201_CREATED)
async def register(payload: UserRegisterRequest, db: AsyncSession = Depends(get_db)):
    """Register a new user account."""
    return await auth_service.register_user(payload, db=db)

@router.post("/login", response_model=TokenResponse)
async def login(payload: UserLoginRequest, db: AsyncSession = Depends(get_db)):
    """Authenticate and obtain JWT access & refresh tokens."""
    return await auth_service.authenticate_user(email=payload.email, password=payload.password, db=db)

@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(payload: RefreshTokenRequest, db: AsyncSession = Depends(get_db)):
    """Exchange a valid refresh token for a new access token."""
    return await auth_service.refresh_token(refresh_token_str=payload.refresh_token, db=db)

@router.post("/logout", status_code=status.HTTP_200_OK)
async def logout(current_user: dict = Depends(get_current_user)):
    """Invalidate the current session."""
    user_id = str(current_user.get("sub", ""))
    await auth_service.logout_user(user_id=user_id)
    return {"message": "Successfully logged out"}
