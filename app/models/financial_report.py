from sqlalchemy import Column, Integer, String, Float, Boolean, Date , DateTime, Enum, ForeignKey, Text, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.db.base import Base
from sqlalchemy.dialects.postgresql import JSON

class FinancialReport(Base):
    __tablename__ = "financial_reports"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    type = Column(String(50), nullable=False)
    period_id = Column(Integer, ForeignKey("financial_periods.id"))
    start_date = Column(Date)
    end_date = Column(Date)
    data = Column(JSON, nullable=False)
    generated_at = Column(DateTime, server_default=func.now())    
    generated_by = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    period = relationship("FinancialPeriod", back_populates="reports")    
    user = relationship("User", back_populates="reports")