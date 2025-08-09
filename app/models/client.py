from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Enum, ForeignKey, Text, Numeric
from sqlalchemy.orm import relationship
from app.db.base import Base
# --- models/client.py ---
from sqlalchemy import Column, Integer, String, Date, ForeignKey
from app.models.enum_types import ClientType


class Client(Base):
    __tablename__ = "client"

    client_id = Column(Integer, primary_key=True, index=True)
    client_type = Column(Enum(ClientType, name="client_type"), nullable=False)  # e.g.,
    registration_date = Column(Date)
    businesses_id = Column(Integer, ForeignKey("businesses.id"), nullable=False)
    person_id = Column(Integer, ForeignKey("person.person_id"), nullable=True)

    # Relationship
    subsidiary_accounts = relationship("SubsidiaryAccount", back_populates="clients")
    business = relationship("Business", back_populates="clients")
    sales = relationship("Sale", back_populates="clients")
    purchase_order = relationship("PurchaseOrder", back_populates="clients")
    person = relationship("Person", back_populates="clients")
#    letter_of_credit = relationship("LetterOfCredit", back_populates="clients")