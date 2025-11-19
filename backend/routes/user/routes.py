from fastapi import Depends
from sqlmodel import Session

from database.connection import get_session
from backend.routes.routes import router
from backend.services.user.user import register_user
from backend.schemas.user import UserCreate, UserRead

@router.post('user/register', response_model=UserRead, status_code=201)
async def register_handler(data: UserCreate, session: Session = Depends(get_session)):
    return register_user(data, session)

@router.get('user/get')
async def get_user(session: Session = Depends(get_session)):
    users = session.exec(select(User)).all()

    return users