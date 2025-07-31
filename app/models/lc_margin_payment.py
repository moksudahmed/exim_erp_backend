from sqlalchemy import Column, Integer, Numeric, Date, ForeignKey
from sqlalchemy.orm import relationship
from app.db.base import Base

class LCMarginPayment(Base):
    __tablename__ = "lc_margin_payment"

    id = Column(Integer, primary_key=True)
    lc_id = Column(Integer, ForeignKey("letter_of_credit.id", ondelete="CASCADE"), nullable=False)
    amount = Column(Numeric(12, 2), nullable=False)
    payment_date = Column(Date, nullable=False)
    account_id = Column(Integer, ForeignKey("subsidiary_account.subsidiary_account_id"), nullable=True)

    letter_of_credit = relationship("LetterOfCredit", back_populates="margin_payments")
    account = relationship("SubsidiaryAccount", backref="lc_margin_payments")
