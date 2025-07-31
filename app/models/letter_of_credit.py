from sqlalchemy import (
    Column, Integer, String, Float, Date, Enum, ForeignKey,
    DateTime, Numeric
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base
from app.models.enum_types import LCStatusEnum


class LetterOfCredit(Base):
    __tablename__ = "letter_of_credit"

    id = Column(Integer, primary_key=True)
    
    lc_number = Column(String(50), unique=True, nullable=False)
    applicant = Column(String(100))
    beneficiary = Column(String(100))
    issue_date = Column(Date, nullable=False)
    expiry_date = Column(Date)
    amount = Column(Float)
    currency = Column(String(10))
    
    businesses_id = Column(Integer, ForeignKey("businesses.id"))
    status = Column(Enum(LCStatusEnum, name="lc_status_enum"), nullable=False, default=LCStatusEnum.OPEN)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    business = relationship("Business", back_populates="letter_of_credit")

    lc_goods = relationship("LCGoods", back_populates="letter_of_credit")
    lc_charges = relationship("LCCharge", back_populates="letter_of_credit")
    margin_payments = relationship("LCMarginPayment", back_populates="letter_of_credit")
    goods_receipts = relationship("LCGoodsReceipt", back_populates="letter_of_credit")
    realizations = relationship("LCRealization", back_populates="letter_of_credit")
    final_payments = relationship("LCFinalPayment", back_populates="letter_of_credit")
    goods_shipments = relationship("LCGoodsShipment", back_populates="letter_of_credit")
    issuance = relationship("LCIssuance", back_populates="letter_of_credit")
    # Optional if you plan to reintroduce these:
    # subsidiary_accounts = relationship("SubsidiaryAccount", back_populates="letter_of_credit")
    # clients = relationship("Client", back_populates="letter_of_credit")
