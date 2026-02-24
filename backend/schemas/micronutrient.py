from sqlmodel import SQLModel
from typing import Optional

class MicronutrientBase(SQLModel):
    name: str
    category: Optional[str]
    unit: str
    usda_id: int

class MicronutrientCreate(MicronutrientBase):
    pass

class MicronutrientsRead(MicronutrientBase):
    pass