from sqlalchemy import Column, Integer, Float, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base


class Branch(Base):
    __tablename__ = 'branch'
    
    id = Column(Integer, primary_key=True, index=True)
    branchaddress = Column(String(80))
    branchname = Column(String(100))
    contactno = Column(String(15))
    emailaddress = Column(String(80))
    business_id = Column(Integer, ForeignKey('businesses.id'), nullable=False)
    employee_id = Column(Integer, ForeignKey('users.id'))
    city = Column(String(80))
    country = Column(String(100))
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    business = relationship("Business", back_populates="branches")
    user = relationship("User", back_populates="branches")
    purchase_order = relationship("PurchaseOrder", back_populates="branches")

    #manager = relationship("User", back_populates="managed_branches")