from fastapi import HTTPException
from sqlmodel import Session

from database.models.models import Ingredient
from backend.schemas.ingredients import IngredientCreate

from backend.utils.db_utils import is_existing

from sqlalchemy.exc import IntegrityError, SQLAlchemyError

def add_ingredient(data: IngredientCreate, session: Session) -> Ingredient:
    
    try:
        new_ingredient = Ingredient(**data.model_dump())

        session.add(new_ingredient)
        session.commit()
        session.refresh(new_ingredient)

        return new_ingredient

    except SQLAlchemyError as e:
        # DB errors
        session.rollback()
        raise HTTPException(500, f"database error: {str(e)}")
    
    except Exception as e:
        # Unexpected errors
        session.rollback()
        raise HTTPException(500, f"Unexpected error: {str(e)}")