from sqlalchemy import Column, String, Numeric
from app.db.base import Base

class ViewJournalEntryDetails(Base):
    __tablename__ = "view_journal_entry_details"
    __table_args__ = {'extend_existing': True}
    __mapper_args__ = {"eager_defaults": True}
    
    subsidiary_account_name = Column(String, nullable=True)
    main_account_name = Column(String, nullable=True)
    debitcredit = Column(String(1), nullable=True)
    amount = Column(Numeric, nullable=True)
