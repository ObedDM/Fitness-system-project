#run with: uvicorn backend.app:app --reload --port 8000

from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select

from fastapi.responses import PlainTextResponse

from database.connection import get_session
from database.models.models import User

from backend.schemas.user import UserCreate, UserRead
from backend.schemas.ingredients import IngredientCreate, IngredientRead
from backend.schemas.micronutrient import MicronutrientCreate

from backend.services.user import register_user
from backend.services.ingredients import add_ingredient
from backend.services.micronutrient import add_micronutrient

router = APIRouter()

@router.get('/')
async def root():
    return {'message': 'hola sssssyosaquessss'}

@router.get('/hola')
async def hola():
    return {'hola': 12543}

@router.post('/register_user', response_model=UserRead, status_code=201)
def register_user_handler(data: UserCreate, session: Session = Depends(get_session)):
    return register_user(data, session)

@router.post('/ingredient', status_code=201)
def add_ingredient_handler(data: IngredientCreate, session: Session = Depends(get_session)):
    
    ingredient = add_ingredient(data, session)
    return {"message": f"ingredient {ingredient.name} created successfully. Id: {ingredient.ingredient_id}"}

@router.post('/micronutrient', status_code=201)
def add_micronutrient_handler(data: MicronutrientCreate, session: Session = Depends(get_session)):
    
    micronutrient = add_micronutrient(data, session)
    return {"message": f"micronutrient {micronutrient.name} created successfully."}

@router.get('/get_users')
async def get_user(session: Session = Depends(get_session)):
    users = session.exec(select(User)).all()

    return users