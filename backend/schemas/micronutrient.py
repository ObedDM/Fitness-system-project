from sqlmodel import SQLModel

class MicronutrientBase(SQLModel):
    name: str
    category: str
    unit: str

class MicronutrientCreate(MicronutrientBase):
    pass

class MicronutrientsRead(MicronutrientBase):
    pass