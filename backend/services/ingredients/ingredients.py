from fastapi import HTTPException
from sqlmodel import Session, select
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from typing import List

from database.models.models import Ingredient, Ingredient_MicroNutrient, MicroNutrient, User
from backend.schemas.ingredients import IngredientCreate, IngredientSummary, IngredientRead, MicroNutrientData
from backend.schemas.micronutrient import MicronutrientCreate
from backend.utils.db_utils import is_existing

def add_ingredient(data: IngredientCreate, session: Session) -> Ingredient:

    try:

        new_ingredient = Ingredient(**data.model_dump(exclude={"micronutrients"}))

        session.add(new_ingredient)
        session.flush()

        
        for name, quantity in (data.micronutrients or {}).items():

            if quantity < 0:
                raise HTTPException(422, "Quantity cannot have negative values")
            
            if not is_existing(session, MicroNutrient, "name", name):
                raise HTTPException(400, f"Micronutrient {name} does not exist")
            
            micronutrient = Ingredient_MicroNutrient(
                ingredient_id = new_ingredient.ingredient_id,
                nutrient_name = name,
                quantity = quantity
            )

            session.add(micronutrient)
        
        session.commit()

        return new_ingredient
    
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
    

def add_micronutrient(data: MicronutrientCreate, session: Session) -> MicroNutrient:

    try:
        new_micronutrient = MicroNutrient(**data.model_dump())

        session.add(new_micronutrient)
        session.commit()
        session.refresh(new_micronutrient)

        return new_micronutrient
    
    except IntegrityError as e:
        session.rollback()
        raise HTTPException(409, f"Integrity error: {str(e.orig)}")

    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(500, f"database error: {str(e)}")
    
    except Exception as e:
        session.rollback()
        raise HTTPException(500, f"Unexpected error: {str(e)}")
    
    
def retrieve_micronutrients(session: Session) -> List[MicroNutrient]:

   try:
       results = session.exec(
           select(MicroNutrient)
       ).all()

       micronutrient_list = []

       for micronutrient in results:
           micronutrient_list.append(micronutrient)

       return micronutrient_list
   
   except Exception as e:
       raise HTTPException(500, f"Unexpected error: {str(e)}")
    
    
def retrieve_ingredients(session: Session) -> List[IngredientSummary]:

    try:
        results = session.exec(
            select(Ingredient.ingredient_id, Ingredient.name, Ingredient.calories, User.username)
            .join(User)
        ).all()

        if not results:
            return []
        
        ingredients_list = []

        for row in results:
            ingredient_id, ingredient_name, ingredient_calories, username = row

            ingredient_summary = IngredientSummary(
                ingredient_id=ingredient_id,
                name=ingredient_name,
                calories=ingredient_calories,
                created_by_username=username
            )
        
            ingredients_list.append(ingredient_summary)

        return ingredients_list

    except Exception as e:
        raise HTTPException(500, f"Unexpected error: {str(e)}")
    

def retrieve_single_ingredient(ingredient_id: str, session: Session) -> IngredientRead:

    try:
        results = session.exec(
            select(Ingredient, User.username, MicroNutrient, Ingredient_MicroNutrient.quantity)
            .join(User)
            .join(Ingredient_MicroNutrient)
            .join(MicroNutrient)
            .where(Ingredient.ingredient_id == ingredient_id)
        ).all()

        if not results:
            raise HTTPException(404, "Ingredient not found")
        
        first_row = results[0]
        ingredient_obj: Ingredient = first_row[0]
        username: str = first_row[1]
        
        micronutrients_dict = {}
        
        for row in results:
            micronutrient_obj: MicroNutrient = row[2]
            micronutrient_quantity: int = row[3]

            micronutrient_data = MicroNutrientData(
                quantity=micronutrient_quantity,
                unit=micronutrient_obj.unit,
                category=micronutrient_obj.category
            )
            
            micronutrients_dict[micronutrient_obj.name] = micronutrient_data

        ingredient_read = IngredientRead(
            created_by_username=username,
            name=ingredient_obj.name,
            calories=ingredient_obj.calories,
            protein=ingredient_obj.protein,
            fat=ingredient_obj.fat,
            carbohydrates=ingredient_obj.carbohydrates,
            glycemic_index=ingredient_obj.glycemic_index,
            micronutrients=micronutrients_dict
        )

        return ingredient_read

    except Exception as e:
        raise HTTPException(500, f"Unexpected error: {str(e)}")