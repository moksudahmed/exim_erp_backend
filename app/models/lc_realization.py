from sqlalchemy import Column, Integer, String, Date, Numeric, ForeignKey, Text, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base

class LCRealization(Base):
    __tablename__ = "lc_realization"

    id = Column(Integer, primary_key=True)
    lc_id = Column(Integer, ForeignKey("letter_of_credit.id", ondelete="CASCADE"), nullable=False)
    realization_date = Column(Date, nullable=False)
    amount = Column(Numeric(12, 2), nullable=False)
    receiving_account_id = Column(Integer, ForeignKey("subsidiary_account.subsidiary_account_id"), nullable=True)
    document_reference = Column(String(100), nullable=False)
    remarks = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    letter_of_credit = relationship("LetterOfCredit", back_populates="realizations")
    receiving_account = relationship("SubsidiaryAccount")
