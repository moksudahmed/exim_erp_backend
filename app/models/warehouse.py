from sqlalchemy import Column, Integer, String, Date, Numeric, ForeignKey, Text
from sqlalchemy.orm import relationship, Mapped, mapped_column
from app.db.base import Base

class Warehouse(Base):
    __tablename__ = 'warehouse'

    id: Mapped[int] = mapped_column(primary_key=True)
    warehouse_name: Mapped[str] = mapped_column(String(100))
    location: Mapped[str] = mapped_column(String(100))
    branch_id: Mapped[int | None] = mapped_column(ForeignKey('branch.id'), nullable=True)

    goods_receipts = relationship("LCGoodsReceipt", back_populates="warehouse")