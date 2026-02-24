from sqlmodel import SQLModel
from typing import Optional

class IngredientBase(SQLModel):
    name: str

    calories: Optional[float] = None
    protein: Optional[float] = None
    fat: Optional[float] = None
    carbohydrates: Optional[float] = None
    water: Optional[float] = None

    usda_id: Optional[int] = None
    brand: Optional[str] = None

    glycemic_index: Optional[float] = None

class IngredientCreate(IngredientBase):
    micronutrients: Optional[dict[str, float]] = None # Name, Quantity

class IngredientSummary(SQLModel):
    ingredient_id: str
    name: str
    calories: Optional[float] = None
    created_by_username: str # user.username

    usda_id: Optional[int] = None 
    brand: Optional[str] = None

class MicroNutrientData(SQLModel):
    quantity: float
    unit: str
    category: Optional[str] = None

class IngredientRead(IngredientBase):
    created_by_username: str # user.username
    micronutrients: Optional[dict[str, MicroNutrientData]] = None # micronutrient_name, micronutrient_data  