from fastapi import HTTPException
from sqlmodel import Session
from sqlalchemy.exc import IntegrityError, SQLAlchemyError

from database.models.models import Ingredient, Ingredient_MicroNutrient, MicroNutrient
from backend.schemas.ingredients import IngredientCreate
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