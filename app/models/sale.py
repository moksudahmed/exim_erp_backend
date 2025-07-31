from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Enum, ForeignKey, Text, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base
from app.models.enum_types import PaymentStatus
from sqlalchemy import Enum as SqlEnum

# Sale Model
class Sale(Base):
    __tablename__ = 'sales'

    id = Column(Integer, primary_key=True, index=True)    
    business_id = Column(Integer, ForeignKey("businesses.id"))
    total = Column(Float, nullable=False)
    discount = Column(Integer, nullable=False)
    #customer_id = Column(Integer, ForeignKey('customers.id'), nullable=False)
    client_id = Column(Integer, ForeignKey('client.client_id'), nullable=False)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    payment_status = Column(Enum(PaymentStatus, name="payment_status"), nullable=False)
    user = relationship("User", back_populates="sales")
    sale_products = relationship("SaleProduct", back_populates="sale")
    # Use a string for the relationship to resolve the circular dependency
   # customers = relationship("Customer", back_populates="sales")
    business = relationship("Business", back_populates="sales")
    payments = relationship("Payment", back_populates="sales")
    deliveries = relationship("Delivery", back_populates="sales")
    clients = relationship("Client", back_populates="sales")
    
    
