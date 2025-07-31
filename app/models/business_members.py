from sqlalchemy import Column, Integer, Float, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base

class BusinessMember(Base):
    __tablename__ = "business_members"
    
    user_id = Column(Integer, ForeignKey('users.id'), primary_key=True)
    business_id = Column(Integer, ForeignKey('businesses.id'), primary_key=True)    
    role = Column(String(50))  # owner, manager, staff
    joined_at = Column(DateTime, server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="businesses")
    business = relationship("Business", back_populates="members")