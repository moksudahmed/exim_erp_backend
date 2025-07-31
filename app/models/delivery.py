# SQLAlchemy Model (models/delivery.py)

from sqlalchemy import Column, Integer, ForeignKey, Numeric, DateTime, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base

class Delivery(Base):
    __tablename__ = 'deliveries'

    id = Column(Integer, primary_key=True, index=True)
    sale_id = Column(Integer, ForeignKey("sales.id", ondelete="CASCADE"), nullable=False)
    driver_id = Column(Integer, ForeignKey("drivers.id", ondelete="CASCADE"), nullable=False)
    fare = Column(Numeric(15, 2), nullable=False)
    other_cost = Column(Numeric(15, 2), default=0)
    delivery_date = Column(DateTime(timezone=True), server_default=func.now())
    note = Column(Text, nullable=True)    
    total_cost = Column(Numeric(15, 2), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    sales = relationship("Sale", back_populates="deliveries")
    drivers = relationship("Driver", back_populates="deliveries")

