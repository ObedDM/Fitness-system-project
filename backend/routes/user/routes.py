from fastapi import Depends
from sqlmodel import Session

from database.connection import get_session
from backend.routes.router import router
from backend.services.user.user import register_user, get_users, get_profile
from backend.schemas.user import UserCreate, UserRead, UserResponse
from backend.utils.dependencies import get_user_id

@router.post('/user/register', status_code=201)
async def register_handler(data: UserCreate, session: Session = Depends(get_session)):
    return {"message": f"{register_user(data, session)}"}

@router.get('/user/get_all', response_model=list[UserRead], status_code=200)
async def get_users_handler(session: Session = Depends(get_session)):
    return get_users(session)

@router.get('/user/profile', response_model=UserRead, status_code=200)
async def get_profile_handler(user_id: str = Depends(get_user_id), session: Session = Depends(get_session)):
    return get_profile(user_id, session)