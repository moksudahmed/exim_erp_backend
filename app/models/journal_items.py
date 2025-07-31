from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Enum, ForeignKey, Text, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base
from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey, Text, Enum
from app.models.enum_types import AccountAction

class JournalItems(Base):
    __tablename__ = 'journal_items'

    id = Column(Integer, primary_key=True, index=True)
    narration = Column(String(255), nullable=False)
    debitcredit = Column(Enum(AccountAction, name="accountaction"), nullable=False)    
    amount = Column(Numeric(10, 2), nullable=True)    
    created_at = Column(DateTime, server_default=func.now(), nullable=False)    
    journal_entry_id  = Column(Integer, ForeignKey('journal_entries.id'), nullable=False)    
    account_id = Column(Integer, ForeignKey('account.account_id'), nullable=False)
    subsidiary_account_id = Column(Integer, ForeignKey("subsidiary_account.subsidiary_account_id"), nullable=True)

    # Relationships
    journal_entries = relationship("JournalEntry", back_populates="journal_items")
    account = relationship('Account', back_populates='journal_items')    
    ledger_entry = relationship("Ledger", back_populates="journal_items", uselist=False)
    subsidiary_accounts = relationship("SubsidiaryAccount", back_populates="journal_items")
    