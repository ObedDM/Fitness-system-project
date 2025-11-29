from sqlmodel import SQLModel
from typing import Optional

class IngredientBase(SQLModel):
    name: str
    calories: int
    protein: int
    fat: int
    carbohydrates: int
    water: Optional[float] = None
    glycemic_index: float

class IngredientCreate(IngredientBase):
    micronutrients: Optional[dict[str, float]] = None # Name, Quantity

class IngredientSummary(SQLModel):
    ingredient_id: str
    name: str
    calories: int
    created_by_username: str # user.username

class MicroNutrientData(SQLModel):
    quantity: float
    unit: str
    category: str

class IngredientRead(IngredientBase):
    created_by_username: str # user.username
    micronutrients: Optional[dict[str, MicroNutrientData]] = None # micronutrient_name, micronutrient_data  