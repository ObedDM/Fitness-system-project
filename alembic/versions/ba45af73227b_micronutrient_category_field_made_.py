"""Micronutrient category field made nullable and with no size restriction

Revision ID: ba45af73227b
Revises: d2b3ee9c7133
Create Date: 2025-11-27 11:33:58.438484

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'ba45af73227b'
down_revision: Union[str, Sequence[str], None] = 'd2b3ee9c7133'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.alter_column(
        "micronutrient",
        "category",
        existing_type=sa.VARCHAR(length=20),
        type_=sa.Text(),
        existing_nullable=False,
        nullable=True,
    )
    pass


def downgrade() -> None:
    op.alter_column(
        "micronutrient",
        "category",
        existing_type=sa.Text(),
        type_=sa.VARCHAR(length=20),
        existing_nullable=True,
        nullable=False,
    )
    pass