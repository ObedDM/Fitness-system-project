from fastapi import Depends
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session

from database.connection import get_session
from backend.routes.routes import router
from backend.services.auth.auth import login, refresh
from backend.schemas.refresh import RefreshRequest

@router.post('auth/login')
async def login_handler(form_data: OAuth2PasswordRequestForm = Depends(), session: Session = Depends(get_session)):
    return login(form_data, session)

@router.post('auth/refresh')
async def refresh_handler(data: RefreshRequest):
    return refresh(data)
