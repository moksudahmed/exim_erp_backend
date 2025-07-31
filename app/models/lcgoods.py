from sqlalchemy import Column, Integer, String, Float, Boolean, Date, Enum, ForeignKey, Text, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.db.base import Base
from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey, Text, Enum as SqlEnum
#from enum_types import AccountTypeEnum
from app.models.enum_types import LCStatusEnum
import datetime

class LCGoods(Base):
    __tablename__ = "lc_goods"
    id = Column(Integer, primary_key=True)
    lc_id = Column(Integer, ForeignKey("letter_of_credit.id"))
    product_id = Column(Integer, ForeignKey("products.id"))
    quantity = Column(Integer)
    unit_cost = Column(Numeric(12, 2))
    received = Column(Boolean, default=False)
    
    letter_of_credit = relationship("LetterOfCredit", back_populates="lc_goods")
    product = relationship("Product", back_populates="lc_goods")