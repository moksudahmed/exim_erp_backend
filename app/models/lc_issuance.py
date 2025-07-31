from sqlalchemy import (
    Column, Integer, String, Float, Date, Enum, ForeignKey,
    DateTime, Numeric
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base
from app.models.enum_types import LCStatusEnum

class LCIssuance(Base):
    __tablename__ = "lc_issuance"

    id = Column(Integer, primary_key=True)
    lc_id = Column(Integer, ForeignKey("letter_of_credit.id"), unique=True, nullable=False)
    issuing_bank = Column(String(100))
    issue_date = Column(Date)
    remarks = Column(String(100))

    letter_of_credit = relationship("LetterOfCredit", back_populates="issuance")
