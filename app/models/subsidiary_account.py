from sqlalchemy import Column, Integer, String, ForeignKey, TIMESTAMP
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base

class SubsidiaryAccount(Base):
    __tablename__ = "subsidiary_account"

    subsidiary_account_id = Column(Integer, primary_key=True, index=True)
    account_id = Column(Integer, ForeignKey("account.account_id"), nullable=False)
    client_id = Column(Integer, ForeignKey("client.client_id"), nullable=False)

    account_name = Column(String(100))
    account_no = Column(String(20))
    address = Column(String(100))
    branch = Column(String(50))
    account_holder = Column(String(120))
    type = Column(String(50))

    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    account = relationship("Account", back_populates="subsidiary_accounts")
    clients = relationship("Client", back_populates="subsidiary_accounts")
    journal_items = relationship("JournalItems", back_populates="subsidiary_accounts")
   # letter_of_credit = relationship("LetterOfCredit", back_populates="subsidiary_accounts")
    #sales = relationship("Sale", back_populates="subsidiary_accounts")