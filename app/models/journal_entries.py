from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Enum, ForeignKey, Text, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.db.base import Base
from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey, Text, Enum as SqlEnum
#from enum_types import AccountTypeEnum
from app.models.enum_types import AccountTypeEnum


class JournalEntry(Base):
    __tablename__ = 'journal_entries'

    id = Column(Integer, primary_key=True, index=True)
    #account_type = Column(Enum(AccountTypeEnum, name="accounttypeenum"), nullable=False)
    ref_no = Column(String(255), nullable=True)
    account_type = Column(Enum(AccountTypeEnum, name="accounttypeenum"), nullable=False)
    company = Column(String(255), nullable=True)
    description = Column(String)
    transaction_date = Column(DateTime, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)

    # Relationships
    user = relationship("User", back_populates="journal_entries")
    journal_items = relationship("JournalItems", back_populates="journal_entries")