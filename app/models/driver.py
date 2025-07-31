from datetime import datetime
from sqlalchemy import Column, Integer, String, Numeric, ForeignKey, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base import Base

class Driver(Base):
    __tablename__ = 'drivers'
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    phone_no = Column(String(255), nullable=True)
    truck_no = Column(String(255), nullable=True)
    measurment = Column(Numeric(15, 2), nullable=False)  
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="drivers")
    deliveries = relationship("Delivery", back_populates="drivers")
    
    # Add any other relationships if needed
    # shipments = relationship("Shipment", back_populates="driver")