from fastapi import Depends
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session

from database.connection import get_session
from backend.routes.router import router
from backend.services.auth.auth import login, refresh
from backend.schemas.refresh import RefreshRequest

@router.post('/auth/login')
async def login_handler(form_data: OAuth2PasswordRequestForm = Depends(), session: Session = Depends(get_session)):
    result = login(form_data, session)

    print(f"Access Token:\n{result['access_token']}\n")
    print(f"Refresh Token:\n{result['refresh_token']}\n")

    return result

@router.post('/auth/refresh')
async def refresh_handler(data: RefreshRequest):
    return refresh(data)
