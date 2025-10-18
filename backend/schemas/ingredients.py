from sqlmodel import SQLModel

class IngredientBase(SQLModel):
    created_by: str
    name: str
    calories: int
    protein: int
    fat: int
    carbohydrates: int
    glycemic_index: float

class IngredientCreate(IngredientBase):
    pass

class IngredientRead(IngredientBase):
    pass