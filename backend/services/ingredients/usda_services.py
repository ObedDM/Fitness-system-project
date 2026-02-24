import httpx
from fastapi import HTTPException
from typing import List, Dict, Any
from sqlmodel import Session, select
from decouple import config

from database.models.models import Ingredient, MicroNutrient
from backend.schemas.ingredients import IngredientCreate
from backend.services.ingredients.ingredients import add_ingredient

USDA_KEY = config("FOOD_DATA_CENTRAL_KEY")
USDA_API_URL = "https://api.nal.usda.gov/fdc/v1/foods/search"

MACRO_COLS = {
    1008: "calories",
    1003: "protein",
    1004: "fat",
    1005: "carbohydrates",
    1051: "water"
}

async def search_usda(query: str, page_size: int = 10) -> List[Dict[str, Any]]:

    params = {
        "query": query,
        "pageSize": page_size,
        "api_key": USDA_KEY,
        #"dataType": ["Foundation", "SR Legacy", "Branded"],
        "dataType": ["Foundation", "SR Legacy"]
    }

    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(USDA_API_URL, params=params)
            response.raise_for_status()
            data = response.json()
            return data.get("foods", [])
            
        except httpx.HTTPStatusError as e:
            raise HTTPException(status_code=e.response.status_code, detail="USDA API Error")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Connection Error: {str(e)}")
        

def ingest_usda_food(usda_data: dict, user_id: str, session: Session) -> Ingredient:
    """
    1. Checks if USDA ID exists locally.
    2. If yes -> Returns existing ingredient.
    3. If no -> Parses JSON and calls add_ingredient.
    """
    existing = session.exec(
        select(Ingredient).where(Ingredient.usda_id == usda_data['fdcId'])
    ).first()
    
    if existing:
        return existing

    db_micros = session.exec(select(MicroNutrient)).all()
    usda_id_to_name = {m.usda_id: m.name for m in db_micros}

    nutrients_found = {}
    macros_found = {}

    for n in usda_data.get("foodNutrients", []):
        n_id = n.get("nutrientId")
        amount = n.get("value", 0.0)

        if n_id in MACRO_COLS:
            macros_found[MACRO_COLS[n_id]] = amount
        
        elif n_id in usda_id_to_name:
            nutrients_found[usda_id_to_name[n_id]] = amount

    payload = {
        "name": usda_data.get("description"),
        "usda_id": usda_data.get("fdcId"),
        "brand": usda_data.get("brandOwner", "Generic"),
        "micronutrients": nutrients_found, 
        **macros_found 
    }

    return add_ingredient(IngredientCreate(**payload), user_id, session)