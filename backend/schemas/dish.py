from sqlmodel import SQLModel
from typing import Optional, List, Dict, Any
from datetime import date

class DishIngredients(SQLModel):
    ingredient_id: str
    amount: float
    unit: str
    name: Optional[str] = None

class DishCreate(SQLModel):
    name: str
    description: Optional[str] = None
    servings: Optional[float] = None
    category: str
    ingredients: list[DishIngredients]

class DishRead(SQLModel):
    dish_id: str
    name: str
    description: Optional[str] = None
    servings: Optional[float] = None
    category: str
    created_at: date
    created_by_username: str
    ingredients: Optional[List[DishIngredients]] = None
    
    calories: Optional[float] = 0.0
    protein: Optional[float] = 0.0
    fat: Optional[float] = 0.0
    carbohydrates: Optional[float] = 0.0
    micronutrients: Optional[Dict[str, Any]] = None
    
class DishSummary(SQLModel):
    dish_id: str
    name: str
    category: str
    servings: Optional[float] = None
    created_at: date
    created_by_username: str
