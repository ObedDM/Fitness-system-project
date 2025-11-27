from fastapi import Depends
from sqlmodel import Session

from database.connection import get_session
from backend.routes.router import router
from backend.schemas.ingredients import IngredientCreate, IngredientSummary, IngredientRead
from backend.schemas.micronutrient import MicronutrientCreate, MicronutrientsRead
from backend.services.ingredients.ingredients import add_ingredient, add_micronutrient, retrieve_micronutrients, retrieve_ingredients, retrieve_single_ingredient
from backend.utils.dependencies import get_user_id


@router.post('/ingredient', status_code=201)
def add_ingredient_handler(data: IngredientCreate, user_id: str = Depends(get_user_id), session: Session = Depends(get_session)):
    
    ingredient = add_ingredient(data, user_id, session)
    return {"message": f"ingredient {ingredient.name} created successfully. Id: {ingredient.ingredient_id}"}


@router.post('/micronutrient', status_code=201)
def add_micronutrient_handler(data: MicronutrientCreate, session: Session = Depends(get_session)):
    
    micronutrient = add_micronutrient(data, session)
    return {"message": f"micronutrient {micronutrient.name} created successfully."}


@router.get('/micronutrients', response_model=list[MicronutrientsRead], status_code=200)
def retrieve_micronutrients_handler(session: Session = Depends(get_session)):
    return retrieve_micronutrients(session)


@router.get('/ingredients', response_model=list[IngredientSummary], status_code=200)
def retrieve_ingredients_handler(session: Session = Depends(get_session)):
    return retrieve_ingredients(session)


@router.get('/ingredient/{ingredient_id}', response_model=IngredientRead, status_code=200)
def retrieve_single_ingredient_handler(ingredient_id: str, session: Session = Depends(get_session)):
    return retrieve_single_ingredient(ingredient_id, session)