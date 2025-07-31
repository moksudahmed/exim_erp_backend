from sqlalchemy import Column, Integer, String, Date, ForeignKey, Text, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base

class LCGoodsShipment(Base):
    __tablename__ = "lc_goods_shipment"

    shipment_id = Column(Integer, primary_key=True, index=True)
    lc_id = Column(Integer, ForeignKey("letter_of_credit.id"), nullable=False)
    shipment_date = Column(Date, nullable=False)
    bl_number = Column(String(100))
    shipping_company = Column(String(100))
    port_of_loading = Column(String(100))
    port_of_discharge = Column(String(100))
    created_at = Column(DateTime, server_default=func.now())

    letter_of_credit = relationship("LetterOfCredit", back_populates="goods_shipments")
