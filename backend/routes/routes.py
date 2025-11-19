#run with: uvicorn backend.app:app --reload --port 8000

from fastapi import APIRouter, Depends
from sqlmodel import Session

from database.connection import get_session

from backend.schemas.ingredients import IngredientCreate
from backend.schemas.micronutrient import MicronutrientCreate

from backend.services.ingredients import add_ingredient
from backend.services.micronutrient import add_micronutrient

router = APIRouter()


@router.post('/ingredient', status_code=201)
def add_ingredient_handler(data: IngredientCreate, session: Session = Depends(get_session)):
    
    ingredient = add_ingredient(data, session)
    return {"message": f"ingredient {ingredient.name} created successfully. Id: {ingredient.ingredient_id}"}

@router.post('/micronutrient', status_code=201)
def add_micronutrient_handler(data: MicronutrientCreate, session: Session = Depends(get_session)):
    
    micronutrient = add_micronutrient(data, session)
    return {"message": f"micronutrient {micronutrient.name} created successfully."}