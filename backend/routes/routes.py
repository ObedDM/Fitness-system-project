#run with: uvicorn backend.app:app --reload --port 8000

from fastapi import APIRouter, Depends
from database.connection import get_session
from database.models.models import User, User_Role, Role
from sqlmodel import Session, select

router = APIRouter()

@router.get('/')
async def root():
    return {'message': 'hola sssssyosaquessss'}

@router.get('/hola')
async def hola():
    return {'hola': 12543}

@router.post('/register_user')
async def register_user(user: User, session: Session = Depends(get_session)):
    session.add(user)
    session.commit()
    session.refresh(user)
    
    return user

@router.get('/get_users')
async def get_user(session: Session = Depends(get_session)):
    users = session.exec(select(User)).all()

    return users