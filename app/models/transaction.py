from sqlalchemy import Column, Integer, Numeric,Text, DateTime, ForeignKey, String, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.db.base import Base
from app.models.enum_types import TransactionType
# TRANSACTION MODEL

class Transaction(Base):
    __tablename__ = 'transaction'
    
    transaction_id = Column(Integer, primary_key=True)
    business_id = Column(Integer, ForeignKey("businesses.id"), nullable=False)    
    description = Column(String, nullable=False)    
    transaction_date = Column(DateTime, nullable=False)
    amount = Column(Numeric(15, 2), nullable=False)
    type = Column(Enum(TransactionType, name="transaction_type"), nullable=False)  # e.g.,
    reference_type = Column(String(50))  # sale, purchase, payment, etc.
    reference_id = Column(Integer)
    account_id = Column(Integer, ForeignKey('account.account_id'), nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True)

    # Relationships
    user = relationship("User", back_populates="transactions")
    account = relationship('Account', back_populates='transactions')
  #  accounts_payable = relationship('AccountsPayable', back_populates='transaction')
  #  accounts_receivable = relationship('AccountsReceivable', back_populates='transaction')
    business = relationship("Business", back_populates="transactions")
  