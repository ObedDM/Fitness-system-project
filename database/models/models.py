import uuid6
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List, Dict, Any
from sqlalchemy import String, Column, Numeric, CheckConstraint, UniqueConstraint, CHAR, Date, ForeignKey, Integer, DateTime, JSON
from datetime import date, datetime, timezone

class User_Role(SQLModel, table=True):
    user_id: str = Field(foreign_key="user.user_id", primary_key=True, nullable=False)
    role: str = Field(foreign_key="role.role", primary_key=True, nullable=False)

class User(SQLModel, table=True):
    user_id: str = Field(default_factory=lambda: str(uuid6.uuid7()), primary_key=True, index=True, unique=True, nullable=False)
    username: str = Field(sa_column=Column(String(20), unique=True, index=True, nullable=False))
    name: str
    surname: str
    email: str = Field(sa_column=Column(String(254), unique=True, index=True, nullable=False))
    age: Optional[int] = Field(default=None)
    weight: Optional[float] = Field(sa_column=Column(Numeric(5, 2), default=None))
    height: Optional[float] = Field(sa_column=Column(Numeric(3, 2), default=None))
    password: str = Field(sa_column=Column(CHAR(60), nullable=False))

    __table_args__ = (
        CheckConstraint('age >= 0 AND age <= 120', name='age_to_120'),
    )

    roles: List["Role"] = Relationship(back_populates="users", link_model=User_Role)
    consumptions: List["Consumption"] = Relationship(back_populates="user")

class Role(SQLModel, table=True):
    role: str = Field(sa_column=Column(String(12), primary_key=True, index=True, unique=True))

    users: List[User] = Relationship(back_populates="roles", link_model=User_Role)

class Ingredient_MicroNutrient(SQLModel, table=True):
    ingredient_id: str = Field(foreign_key="ingredient.ingredient_id", primary_key=True)
    nutrient_name: str = Field(foreign_key="micronutrient.name", primary_key=True)
    quantity: float

    ingredient: "Ingredient" = Relationship(back_populates="micronutrient_links")
    micronutrient: "MicroNutrient" = Relationship(back_populates="ingredient_links")

class MicroNutrient(SQLModel, table=True):
    name: str = Field(primary_key=True, index=True, unique=True, nullable=False)
    category: str = Field(nullable=True)
    unit: str = Field(sa_column=Column(String(8), nullable=False))
    usda_id: int = Field(sa_column=Column(Integer, unique=True, nullable=False))

    ingredient_links: List[Ingredient_MicroNutrient] = Relationship(
        back_populates="micronutrient"
    )

class Ingredient_Dish(SQLModel, table=True):
    dish_id: str = Field(sa_column=Column(String, ForeignKey("dish.dish_id", ondelete="CASCADE"), primary_key=True, nullable=False))
    ingredient_id: str = Field(sa_column=Column(String, ForeignKey("ingredient.ingredient_id", ondelete="CASCADE"), primary_key=True, nullable=False))
    amount: float = Field(sa_column=Column(Numeric(5, 2), nullable=False))
    unit: str = Field(default='g', sa_column=Column(String(8), nullable=False))

    dish: "Dish" = Relationship(back_populates="ingredient_links")
    ingredient: "Ingredient" = Relationship(back_populates="dish_links")

class Ingredient(SQLModel, table=True):
    ingredient_id: str = Field(default_factory=lambda: str(uuid6.uuid7()), primary_key=True, index=True, unique=True)
    usda_id: Optional[int] = Field(default=None, unique=True, index=True)

    brand: Optional[str] = Field(default=None)  

    created_by: str = Field(foreign_key="user.user_id")
    name: str = Field(nullable=False)

    calories: Optional[float] = Field(default=None, sa_column=Column(Numeric(6, 2)))
    protein: Optional[float] = Field(default=None, sa_column=Column(Numeric(6, 2)))
    fat: Optional[float] = Field(default=None, sa_column=Column(Numeric(6, 2)))
    carbohydrates: Optional[float] = Field(default=None, sa_column=Column(Numeric(6, 2)))

    water: Optional[float] = Field(default=None, sa_column=Column(Numeric(6, 2)))

    glycemic_index: Optional[float] = Field(default=None, sa_column=Column(Numeric(4, 1)))


    micronutrient_links: List[Ingredient_MicroNutrient] = Relationship(
        back_populates="ingredient",
        sa_relationship_kwargs={"cascade": "all, delete-orphan"}
    )

    dish_links: List[Ingredient_Dish] = Relationship(back_populates="ingredient")
    consumptions: List["Consumption"] = Relationship(back_populates="ingredient")

    __table_args__ = (
        UniqueConstraint("name", "created_by", name="UNIQUE_NAME_CREATEDBY"),
    )

class Dish(SQLModel, table=True):
    dish_id: str = Field(default_factory=lambda: str(uuid6.uuid7()), primary_key=True, index=True, unique=True)
    created_by: str = Field(foreign_key="user.user_id")
    name: str = Field(nullable=False)
    description: str
    servings: float = Field(sa_column=Column(Numeric(4,2)))
    category: str = Field(nullable=False)
    created_at: date = Field(default_factory=date.today, sa_column=Column(Date(), nullable=False))

    __table_args__ = (
        UniqueConstraint("name", "created_by", name="UNIQUE_DISH_NAME_CREATEDBY"),
    )

    ingredient_links: List[Ingredient_Dish] = Relationship(back_populates="dish")
    consumptions: List["Consumption"] = Relationship(back_populates="dish")

class Consumption(SQLModel, table=True):
    consumption_id: str = Field(default_factory=lambda: str(uuid6.uuid7()), primary_key=True, index=True, unique=True, nullable=False)
    
    user_id: str = Field(sa_column=Column(String, ForeignKey("user.user_id", ondelete="CASCADE"), nullable=False, index=True))
    
    ingredient_id: Optional[str] = Field(default=None, sa_column=Column(String, ForeignKey("ingredient.ingredient_id", ondelete="CASCADE"), nullable=True))
    dish_id: Optional[str] = Field(default=None, sa_column=Column(String, ForeignKey("dish.dish_id", ondelete="CASCADE"), nullable=True))

    amount: float = Field(sa_column=Column(Numeric(6, 2), nullable=False)) 
    unit: str = Field(default="g", sa_column=Column(String(8), nullable=False))
    
    log_timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), sa_column=Column(DateTime, nullable=False))

    calories: float = Field(default=0.0, sa_column=Column(Numeric(10, 2), nullable=False))
    protein: float = Field(default=0.0, sa_column=Column(Numeric(10, 2), nullable=False))
    fat: float = Field(default=0.0, sa_column=Column(Numeric(10, 2), nullable=False))
    carbohydrates: float = Field(default=0.0, sa_column=Column(Numeric(10, 2), nullable=False))
    micronutrients: Dict[str, Any] = Field(default={}, sa_column=Column(JSON, nullable=False))

    __table_args__ = (
        CheckConstraint(
            '(ingredient_id IS NOT NULL AND dish_id IS NULL) OR (ingredient_id IS NULL AND dish_id IS NOT NULL)',
            name='check_ingredient_xor_dish'
        ),
    )

    user: "User" = Relationship(back_populates="consumptions")
    ingredient: Optional["Ingredient"] = Relationship(back_populates="consumptions")
    dish: Optional["Dish"] = Relationship(back_populates="consumptions")