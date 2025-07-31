from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Enum, ForeignKey, Text, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.db.base import Base
from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey, Text, Enum as SqlEnum
#from enum_types import AccountTypeEnum
from app.models.enum_types import AccountTypeEnum,AccountNature
import datetime

class Account(Base):
    __tablename__ = 'account'
    
    account_id = Column(Integer, primary_key=True)
    business_id = Column(Integer, ForeignKey("businesses.id"), nullable=False)
    parent_id = Column(Integer, ForeignKey('account.account_id'), nullable=True)    
    account_name = Column(String, nullable=False)
    account_type = Column(Enum(AccountTypeEnum, name="accounttypeenum"), nullable=False)  # e.g., Asset, Liability, Equity
    balance = Column(Numeric(15, 2), nullable=False)  
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    code = Column(String(20))
    is_active = Column(Boolean, default=True)
    #nature_type = Column(Enum(AccountNature, name="accountnature"), nullable=False)  # e.g., Asset, Liability, Equity
    
    # Relationships
    business = relationship("Business", back_populates="accounts")
    transactions = relationship('Transaction', back_populates='account')
    journal_items = relationship('JournalItems', back_populates='account')
    
    # Self-referencing relationship
    parent = relationship("Account", remote_side=[account_id], backref="children")   
    ledger_entries = relationship("Ledger", back_populates="account")
    subsidiary_accounts = relationship("SubsidiaryAccount", back_populates="account")