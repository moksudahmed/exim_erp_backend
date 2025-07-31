from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import date
from app.db.base import Base
from app.models.enum_types import PaymentMethod
import enum


class Payment(Base):
    __tablename__ = "payments"
    
    id = Column(Integer, primary_key=True)
    business_id = Column(Integer, ForeignKey("businesses.id"))
    payment_date = Column(DateTime, server_default=func.now())
    amount = Column(Numeric(12, 2))    
    payment_method = Column(Enum(PaymentMethod, name="paymentmethodenum"), nullable=False)
    reference_number = Column(String(50))
    notes = Column(String(255))    
    # For customer payments
    sale_id = Column(Integer, ForeignKey("sales.id"), nullable=False)    
    # For supplier payments
    purchase_id = Column(Integer, ForeignKey("purchase_orders.id"), nullable=False)
    
    # Relationships
    business = relationship("Business")
    sales = relationship("Sale", back_populates="payments")
    purchase_order = relationship("PurchaseOrder", back_populates="payments")