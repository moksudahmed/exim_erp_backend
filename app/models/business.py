from sqlalchemy import Column, Integer, Float, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base


class Business(Base):
    __tablename__ = "businesses"
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100), index=True)
    tax_id = Column(String(50))
    address = Column(String(255))
    phone = Column(String(20))
    email = Column(String(100))
    default_currency = Column(String(3), default="USD")
    fiscal_year_start = Column(DateTime)
    created_at = Column(DateTime, server_default=func.now())
    
    # Relationships
    members = relationship("BusinessMember", back_populates="business")
    products = relationship("Product", back_populates="business")
   # customers = relationship("Customer", back_populates="business")
    #suppliers = relationship("Supplier", back_populates="business")
   # inventory = relationship("InventoryItem", back_populates="business")
    sales = relationship("Sale", back_populates="business")
    #purchases = relationship("Purchase", back_populates="business")
    accounts = relationship("Account", back_populates="business")
    transactions = relationship("Transaction", back_populates="business")

    branches = relationship("Branch", back_populates="business")
    clients = relationship("Client", back_populates="business")
    letter_of_credit = relationship("LetterOfCredit", back_populates="business")