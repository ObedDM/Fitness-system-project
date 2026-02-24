from sqlmodel import Session, select, func
from fastapi import HTTPException, Request
from datetime import datetime, date, timedelta, timezone
from typing import Dict

from database.models.models import Ingredient, Dish, Ingredient_Dish, Ingredient_MicroNutrient, MicroNutrient, Consumption
from backend.schemas.consumption import ConsumptionCreate, ConsumptionRead, DaySummary, ConsumptionReport

def log_consumption(user_id: str, data: ConsumptionCreate, session: Session):
    total_calories = 0.0
    total_protein = 0.0
    total_fat = 0.0
    total_carbohydrates = 0.0
    micronutrients_map = {}

    # 1. LOGGING A DISH
    if data.dish_id:
        dish = session.get(Dish, data.dish_id)
        if not dish:
            raise HTTPException(404, "Dish not found")
        
        ratio = float(data.amount) / float(dish.servings or 1.0)

        for link in dish.ingredient_links:
            ing = link.ingredient
            ing_ratio = float(link.amount) / 100.0
            
            total_calories += float(ing.calories or 0) * ing_ratio * ratio
            total_protein += float(ing.protein or 0) * ing_ratio * ratio
            total_fat += float(ing.fat or 0) * ing_ratio * ratio
            total_carbohydrates += float(ing.carbohydrates or 0) * ing_ratio * ratio

            for micro_link in ing.micronutrient_links:
                micro = micro_link.micronutrient
                name = micro.name
                if name not in micronutrients_map:
                    micronutrients_map[name] = {"quantity": 0.0, "unit": micro.unit}
                micronutrients_map[name]["quantity"] += float(micro_link.quantity) * ing_ratio * ratio

    # 2. LOGGING A SINGLE INGREDIENT
    else:
        ingredient = session.get(Ingredient, data.ingredient_id)
        if not ingredient:
            raise HTTPException(404, "Ingredient not found")
        
        ratio = float(data.amount) / 100.0
        total_calories = float(ingredient.calories or 0) * ratio
        total_protein = float(ingredient.protein or 0) * ratio
        total_fat = float(ingredient.fat or 0) * ratio
        total_carbohydrates = float(ingredient.carbohydrates or 0) * ratio

        for micro_link in ingredient.micronutrient_links:
            micro = micro_link.micronutrient
            name = micro.name
            if name not in micronutrients_map:
                micronutrients_map[name] = {"quantity": 0.0, "unit": micro.unit}
            micronutrients_map[name]["quantity"] += float(micro_link.quantity) * ratio

    # 3. SAVE SNAPSHOT TO DATABASE
    new_consumption = Consumption(
        user_id=user_id,
        ingredient_id=data.ingredient_id,
        dish_id=data.dish_id,
        amount=data.amount,
        unit=data.unit,
        log_timestamp=datetime.now(timezone.utc),
        calories=total_calories,
        protein=total_protein,
        fat=total_fat,
        carbohydrates=total_carbohydrates,
        micronutrients=micronutrients_map 
    )
    
    session.add(new_consumption)
    session.commit()
    return new_consumption


def get_consumption_range_report(user_id: str, session: Session, days: int):
    end_date = date.today()
    start_date = end_date - timedelta(days=days - 1)

    print(f"🔍 DEBUG: {days} días | {start_date} → {end_date}")

    # ✅ VUELVE A func.date() ORIGINAL (sin astimezone)
    statement = (
        select(Consumption)
        .where(
            Consumption.user_id == user_id,
            func.date(Consumption.log_timestamp) >= start_date,
            func.date(Consumption.log_timestamp) <= end_date
        )
        .order_by(Consumption.log_timestamp.desc())
    )
    
    logs = session.exec(statement).all()
    print(f"📊 Logs encontrados: {len(logs)}")
    
    # Print FECHAS de logs para debug
    for log in logs[:5]:  # Primeros 5
        print(f"Log: {log.log_timestamp.date()} | {log.log_timestamp}")

    # Group by date
    grouped_data: Dict[date, DaySummary] = {}
    
    for i in range(days):
        d = start_date + timedelta(days=i)
        grouped_data[d] = DaySummary(
            date=d, total_calories=0, total_protein=0, 
            total_fat=0, total_carbohydrates=0, logs=[]
        )

    for log in logs:
        log_date = log.log_timestamp.date()  # Python date() después de query
        
        item_name = log.dish.name if log.dish_id else log.ingredient.name

        day_entry = grouped_data[log_date]
        day_entry.total_calories += round(float(log.calories), 1)
        day_entry.total_protein += round(float(log.protein), 1)
        day_entry.total_fat += round(float(log.fat), 1)
        day_entry.total_carbohydrates += round(float(log.carbohydrates), 1)
        
        day_entry.logs.append(ConsumptionRead(
            consumption_id=str(log.consumption_id),
            item_name=item_name,
            meal_type="ingredient" if log.ingredient_id else "dish",
            unit=log.unit,
            amount=log.amount,
            log_timestamp=log.log_timestamp,
            calories=round(log.calories, 1),
            protein=round(log.protein, 1),
            fat=round(log.fat, 1),
            carbohydrates=round(log.carbohydrates, 1),
            micronutrients=log.micronutrients 
        ))

    return ConsumptionReport(
        start_date=start_date,
        end_date=end_date,
        days_count=days,
        data=sorted(grouped_data.values(), key=lambda x: x.date, reverse=True)
    )
