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
        row = session.exec(
            select(Dish, User.username)
            .join(User, Dish.created_by == User.user_id)
            .where(Dish.dish_id == dish_id)
        ).first()

        if not row:
            raise HTTPException(404, "Dish not found")

        dish_obj, username = row

        ingredient_rows = session.exec(
            select(Ingredient, Ingredient_Dish.amount, Ingredient_Dish.unit)
            .join(Ingredient_Dish, Ingredient.ingredient_id == Ingredient_Dish.ingredient_id)
            .where(Ingredient_Dish.dish_id == dish_id)
        ).all()

        ingredients_list: List[DishIngredients] = [
            DishIngredients(
                ingredient_id=ingredient_obj.ingredient_id,
                amount=float(amount),
                unit=unit,
                name=ingredient_obj.name
            )
            for ingredient_obj, amount, unit in ingredient_rows
        ]

        return DishRead(
            dish_id=dish_obj.dish_id,
            name=dish_obj.name,
            description=dish_obj.description,
            servings=dish_obj.servings,
            category=dish_obj.category,
            created_at=dish_obj.created_at,
            created_by_username=username,
            ingredients=ingredients_list or None,
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(500, f"Unexpected error: {str(e)}")