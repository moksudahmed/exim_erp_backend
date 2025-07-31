from sqlalchemy import Column, Integer, String, Date, ForeignKey, Text, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base

class LCGoodsReceipt(Base):
    __tablename__ = "lc_goods_receipt"

    id = Column(Integer, primary_key=True)
    lc_id = Column(Integer, ForeignKey("letter_of_credit.id", ondelete="CASCADE"), nullable=False)
    receipt_date = Column(Date, nullable=False)
    warehouse_id = Column(Integer, ForeignKey("warehouse.id"), nullable=True)
    receiver_name = Column(String(100), nullable=False)
    remarks = Column(Text, nullable=True)    

    # Relationships
    warehouse = relationship("Warehouse", back_populates="goods_receipts")
    letter_of_credit = relationship("LetterOfCredit", back_populates="goods_receipts")
