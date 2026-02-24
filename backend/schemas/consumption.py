from sqlmodel import SQLModel
from typing import Optional, Dict, List, Any
from datetime import datetime, date

from backend.schemas.ingredients import MicroNutrientData

class ConsumptionBase(SQLModel):
    amount: float
    unit: str = "g"
    log_timestamp: Optional[datetime] = None

class ConsumptionCreate(ConsumptionBase):
    ingredient_id: Optional[str] = None
    dish_id: Optional[str] = None

class ConsumptionRead(ConsumptionBase):
    consumption_id: str
    item_name: str
    meal_type: str  # "ingredient" or "dish"
    unit: str
    
    # Macros
    calories: float
    protein: float
    fat: float
    carbohydrates: float
    
    # Full Nutrients
    micronutrients: Optional[Dict[str, Any]] = None

class DaySummary(SQLModel):
    date: date
    total_calories: float
    total_protein: float
    total_fat: float
    total_carbohydrates: float
    logs: List[ConsumptionRead]

class ConsumptionReport(SQLModel):
    start_date: date
    end_date: date
    days_count: int
    data: List[DaySummary]