from fastapi import HTTPException
from sqlmodel import Session, select
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from typing import List, Dict

from database.models.models import Ingredient, Ingredient_MicroNutrient, MicroNutrient, User
from backend.schemas.ingredients import IngredientCreate, IngredientSummary, IngredientRead, MicroNutrientData
from backend.schemas.micronutrient import MicronutrientCreate
from backend.utils.db_utils import is_existing

def add_ingredient(data: IngredientCreate, user_id: str, session: Session) -> Ingredient:
  
    try:
        new_ingredient = Ingredient(
            **data.model_dump(exclude={"micronutrients"}),
            created_by=user_id
        )

        session.add(new_ingredient)
        session.flush()

        all_nutrients = session.exec(
            select(MicroNutrient).where(MicroNutrient.name.in_(data.micronutrients.keys()))
        ).all()

        nutrient_map = {n.name: n for n in all_nutrients}
        
        for name, quantity in (data.micronutrients or {}).items():
            if quantity < 0:
                raise HTTPException(422, "Quantity cannot have negative values")
            
            micronutrient_def = nutrient_map.get(name)
            
            if not micronutrient_def:
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
            select(Ingredient.ingredient_id, Ingredient.name, Ingredient.calories, User.username, Ingredient.usda_id, Ingredient.brand)
            .join(User)
        ).all()

        if not results:
            return []
        
        ingredients_list = []

        return [
            IngredientSummary(
                ingredient_id=row[0],
                name=row[1],
                calories=row[2],
                created_by_username=row[3],
                usda_id=row[4],
                brand=row[5]
            ) for row in results
        ]

    except Exception as e:
        raise HTTPException(500, f"Unexpected error: {str(e)}")
    

def retrieve_single_ingredient(ingredient_id: str, session: Session) -> IngredientRead:

    try:
        row = session.exec(
            select(Ingredient, User.username)
            .join(User)
            .where(Ingredient.ingredient_id == ingredient_id)
        ).first()

        if not row:
            raise HTTPException(404, "Ingredient not found")
        
        ingredient_obj: Ingredient = row[0]
        username: str = row[1]

        micro_rows = session.exec(
            select(MicroNutrient, Ingredient_MicroNutrient.quantity)
            .join(Ingredient_MicroNutrient)
            .where(Ingredient_MicroNutrient.ingredient_id == ingredient_id)
        ).all()
        
        micronutrients_dict: Dict[str, MicroNutrientData] = {}
        
        for micro_obj, quantity in micro_rows:
            micronutrient_data = MicroNutrientData(
                quantity=quantity,
                unit=micro_obj.unit,
                category=micro_obj.category,
            )
            micronutrients_dict[micro_obj.name] = micronutrient_data

        return IngredientRead(
            created_by_username=username,
            name=ingredient_obj.name,
            usda_id=ingredient_obj.usda_id,
            brand=ingredient_obj.brand,
            calories=ingredient_obj.calories,
            protein=ingredient_obj.protein,
            fat=ingredient_obj.fat,
            carbohydrates=ingredient_obj.carbohydrates,
            water=ingredient_obj.water,
            glycemic_index=ingredient_obj.glycemic_index,
            micronutrients=micronutrients_dict or None,
        )

    except HTTPException:
        raise
    
    except Exception as e:
        raise HTTPException(500, f"Unexpected error: {str(e)}")