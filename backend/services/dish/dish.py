from fastapi import HTTPException
from sqlmodel import Session, select
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from typing import List, Optional

from backend.utils.db_utils import is_existing
from backend.schemas.dish import DishCreate, DishRead, DishIngredients, DishSummary
from database.models.models import Dish, Ingredient, Ingredient_Dish, User

def add_dish(data: DishCreate, user_id: str, session: Session):
    try:
        new_dish = Dish(
            **data.model_dump(exclude={"ingredients"}),
            created_by=user_id
            )
        
        session.add(new_dish)
        session.flush()

        dish_id = new_dish.dish_id

        for ingredient in data.ingredients or []:

            if ingredient.amount < 0:
                raise HTTPException(422, "Amount cannot have negative values")
            
            if not is_existing(session, Ingredient, "ingredient_id", ingredient.ingredient_id):
                raise HTTPException(400, f"Ingredient {ingredient.ingredient_id} does not exist")
            
            ingredient_dish = Ingredient_Dish(
                dish_id = dish_id,
                ingredient_id = ingredient.ingredient_id,
                amount = ingredient.amount,
                unit = ingredient.unit
            )

            session.add(ingredient_dish)

        session.commit()

        return new_dish

    except IntegrityError as e:
        session.rollback()
        raise HTTPException(409, f"Integrity error: {str(e.orig)}")

    except SQLAlchemyError as e:
        # DB errors
        session.rollback()
        raise HTTPException(500, f"database error: {str(e)}")
    
    except Exception as e:
        # Unexpected errors
        session.rollback()
        raise HTTPException(500, f"Unexpected error: {str(e)}")
    

def retrieve_dishes(session: Session, user_id: str | None = None) -> List[DishSummary]:

    try:
        query = (
            select(Dish, User.username)
            .join(User)
        )
    
        if user_id is not None:
            query = query.where(Dish.created_by == user_id)

        results = session.exec(query).all()
        if not results:
            return []
        
        dishes_list: list[DishSummary] = []

        for dish, username in results:
            dish_summary = DishSummary(
                dish_id=dish.dish_id,
                name=dish.name,
                category=dish.category,
                servings=dish.servings,
                created_at=dish.created_at,
                created_by_username=username,
            )
            dishes_list.append(dish_summary)

        return dishes_list

    except Exception as e:
        raise HTTPException(500, f"Unexpected error: {str(e)}")


def retrieve_single_dish(dish_id: str, session: Session) -> DishRead:
    try:
        # 1. Fetch the dish and join with User to get the creator's username
        row = session.exec(
            select(Dish, User.username)
            .join(User, Dish.created_by == User.user_id)
            .where(Dish.dish_id == dish_id)
        ).first()

        if not row:
            raise HTTPException(404, "Dish not found")

        dish_obj, username = row

        # 2. Fetch all ingredients associated with this dish
        ingredient_rows = session.exec(
            select(Ingredient, Ingredient_Dish.amount, Ingredient_Dish.unit)
            .join(Ingredient_Dish, Ingredient.ingredient_id == Ingredient_Dish.ingredient_id)
            .where(Ingredient_Dish.dish_id == dish_id)
        ).all()

        total_calories = 0.0
        total_protein = 0.0
        total_fat = 0.0
        total_carbs = 0.0
        micronutrients_map = {}

        ingredients_list = []
        
        for ing_obj, amount, unit in ingredient_rows:
            # Scale based on the 100g database standard
            ratio = float(amount) / 100.0
            
            # Aggregate Macronutrients safely
            total_calories += float(ing_obj.calories or 0) * ratio
            total_protein += float(ing_obj.protein or 0) * ratio
            total_fat += float(ing_obj.fat or 0) * ratio
            total_carbs += float(ing_obj.carbohydrates or 0) * ratio

            # 3. Aggregate Micronutrients using correct relationship name: micronutrient_links
            # We traverse: Ingredient -> Ingredient_MicroNutrient -> MicroNutrient
            for link in ing_obj.micronutrient_links:
                micro_info = link.micronutrient # The MicroNutrient table object
                name = micro_info.name
                
                if name not in micronutrients_map:
                    micronutrients_map[name] = {
                        "quantity": 0.0, 
                        "unit": micro_info.unit
                    }
                
                # Add the quantity from the link scaled by the dish ratio
                micronutrients_map[name]["quantity"] += float(link.quantity) * ratio

            ingredients_list.append(DishIngredients(
                ingredient_id=ing_obj.ingredient_id,
                amount=float(amount),
                unit=unit,
                name=ing_obj.name
            ))

        # Scale totals by the number of servings defined for the dish
        servings = float(dish_obj.servings or 1.0)
        
        return DishRead(
            dish_id=dish_obj.dish_id,
            name=dish_obj.name,
            description=dish_obj.description,
            servings=servings,
            category=dish_obj.category,
            created_at=dish_obj.created_at,
            created_by_username=username,
            ingredients=ingredients_list,
            # Calculated stats per serving
            calories=total_calories / servings,
            protein=total_protein / servings,
            fat=total_fat / servings,
            carbohydrates=total_carbs / servings,
            micronutrients=micronutrients_map
        )

    except HTTPException:
        raise
    except Exception as e:
        # Print the error to your terminal so you can see if something else breaks
        print(f"DEBUG ERROR: {str(e)}")
        raise HTTPException(500, f"Unexpected error: {str(e)}")