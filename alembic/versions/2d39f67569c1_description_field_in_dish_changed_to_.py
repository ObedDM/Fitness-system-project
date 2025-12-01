"""description field in Dish changed to nullable

Revision ID: 2d39f67569c1
Revises: ff15b2b32f82
Create Date: 2025-11-30 23:59:42.895371

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '2d39f67569c1'
down_revision: Union[str, Sequence[str], None] = 'ff15b2b32f82'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.alter_column(
        "dish",
        "description",
        existing_type=sa.Text(),
        existing_nullable=False,
        nullable=True
    )


def downgrade() -> None:
    op.alter_column(
        "dish",
        "description",
        existing_type=sa.Text(),
        existing_nullable=True,
        nullable=False,
    )
