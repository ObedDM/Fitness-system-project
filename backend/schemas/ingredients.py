from sqlmodel import SQLModel
from typing import Optional

class IngredientBase(SQLModel):
    created_by: str
    name: str
    calories: int
    protein: int
    fat: int
    carbohydrates: int
    glycemic_index: float

class IngredientCreate(IngredientBase):
    micronutrients: Optional[dict[str, int]] = None # Name, Quantity

class IngredientRead(IngredientBase):
    pass