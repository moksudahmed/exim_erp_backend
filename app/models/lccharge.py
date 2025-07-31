from sqlalchemy import Column, Integer, String, Float, Boolean, Date, Enum, ForeignKey, Text, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.db.base import Base
from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey, Text, Enum as SqlEnum
#from enum_types import AccountTypeEnum
from app.models.enum_types import LCStatusEnum
import datetime

class LCCharge(Base):
    __tablename__ = "lc_charges"
    id = Column(Integer, primary_key=True)
    lc_id = Column(Integer, ForeignKey("letter_of_credit.id"))
    charge_type = Column(String(100))
    amount = Column(Numeric(12, 2))
    charge_date = Column(Date)
    description = Column(Text)

    letter_of_credit = relationship("LetterOfCredit", back_populates="lc_charges")