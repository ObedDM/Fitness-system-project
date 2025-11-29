import uuid6
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
from sqlalchemy import String, Column, Numeric, CheckConstraint, UniqueConstraint, CHAR, Date, ForeignKey
from datetime import date

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
    category: str
    unit: str = Field(sa_column=Column(String(8), nullable=False))

    ingredient_links: List[Ingredient_MicroNutrient] = Relationship(
        back_populates="micronutrient"
    )

class Ingredient_Dish(SQLModel, table=True):
    dish_id: str = Field(sa_column=Column(String, ForeignKey("dish.dish_id", ondelete="CASCADE"), primary_key=True, nullable=False))
    ingredient_id: str = Field(sa_column=Column(String, ForeignKey("ingredient.ingredient_id", ondelete="CASCADE"), primary_key=True, nullable=False))
    amount: float = Field(sa_column=Column(Numeric(5, 2), nullable=False))
    unit: str = Field(sa_column=Column(String(8), nullable=False))

    dish: "Dish" = Relationship(back_populates="ingredient_links")
    ingredient: "Ingredient" = Relationship(back_populates="dish_links")

class Ingredient(SQLModel, table=True):
    ingredient_id: str = Field(default_factory=lambda: str(uuid6.uuid7()), primary_key=True, index=True, unique=True)
    created_by: str = Field(foreign_key="user.user_id")
    name: str = Field(nullable=False)
    calories: int = Field(sa_column=Column(Numeric(4), nullable=False))
    protein: int = Field(sa_column=Column(Numeric(3), nullable=False))
    fat: int = Field(sa_column=Column(Numeric(3), nullable=False))
    water: float = Field(sa_column=Column(Numeric(4,1)))
    carbohydrates: int = Field(sa_column=Column(Numeric(3), nullable=False))
    glycemic_index: float = Field(sa_column=Column(Numeric(4,1), nullable=False))

    micronutrient_links: List[Ingredient_MicroNutrient] = Relationship(
        back_populates="ingredient",
        sa_relationship_kwargs={"cascade": "all, delete-orphan"}
    )

    dish_links: List[Ingredient_Dish] = Relationship(
        back_populates="ingredient"
    )

    __table_args__ = (
        UniqueConstraint("name", "created_by", name="UNIQUE_NAME_CREATEDBY"),
    )

class Dish(SQLModel, table=True):
    dish_id: str = Field(default_factory=lambda: str(uuid6.uuid7()), primary_key=True, index=True, unique=True)
    created_by: str = Field(foreign_key="user.user_id")
    name: str = Field(nullable=False)
    description: str = Field(nullable=False)
    servings: float = Field(sa_column=Column(Numeric(4,2)))
    category: str = Field(nullable=False)
    created_at: date = Field(default_factory=date.today, sa_column=Column(Date(), nullable=False))

    __table_args__ = (
        UniqueConstraint("name", "created_by", name="UNIQUE_DISH_NAME_CREATEDBY"),
    )

    ingredient_links: List[Ingredient_Dish] = Relationship(
        back_populates="dish"
    )
    