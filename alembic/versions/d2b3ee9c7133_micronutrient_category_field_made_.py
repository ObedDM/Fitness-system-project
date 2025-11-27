"""Micronutrient category field made nullable and with no size restriction

Revision ID: d2b3ee9c7133
Revises: 287ffe7d7ff9
Create Date: 2025-11-27 11:31:20.981265

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'd2b3ee9c7133'
down_revision: Union[str, Sequence[str], None] = '287ffe7d7ff9'
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
