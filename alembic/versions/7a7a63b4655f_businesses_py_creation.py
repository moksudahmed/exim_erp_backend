"""businesses.py creation

Revision ID: 7a7a63b4655f
Revises: 3a7d8546ee9a
Create Date: 2025-05-22 11:07:32.675278

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '7a7a63b4655f'
down_revision: Union[str, None] = '3a7d8546ee9a'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
