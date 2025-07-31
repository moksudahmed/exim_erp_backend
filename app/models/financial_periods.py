from sqlalchemy import Column, Integer, String, Float, Boolean, Date , DateTime, Enum, ForeignKey, Text, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.db.base import Base
from sqlalchemy.dialects.postgresql import JSON

class FinancialPeriod(Base):
    __tablename__ = "financial_periods"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    is_closed = Column(Boolean, default=False)
    closed_at = Column(DateTime)
    closed_by = Column(Integer)
    
    reports = relationship("FinancialReport", back_populates="period")