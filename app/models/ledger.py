from sqlalchemy import Column, Integer, String, Float, Boolean, Date, Enum, ForeignKey, Text, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base
from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey, Text, Enum
from app.models.enum_types import AccountAction

class Ledger(Base):
    __tablename__ = "ledger"
    
    id = Column(Integer, primary_key=True, index=True)
    account_id = Column(Integer, ForeignKey('account.account_id'), nullable=False)    
    journal_item_id = Column(Integer, ForeignKey("journal_items.id"), nullable=False)
    entry_date = Column(Date, nullable=False)
    amount = Column(Numeric(15, 2), nullable=False)
    balance = Column(Numeric(15, 2), nullable=False)
    type = Column(Enum(AccountAction, name="accountaction"), nullable=False)    
    created_at = Column(DateTime, server_default=func.now())
    
    account = relationship("Account", back_populates="ledger_entries")
    journal_items = relationship("JournalItems", back_populates="ledger_entry")