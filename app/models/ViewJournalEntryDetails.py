# app/models/ViewJournalEntryDetails.py

from sqlalchemy import Column, Integer, String, Date, Numeric
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class ViewJournalEntryDetails(Base):
    __tablename__ = 'view_journal_entry_details'
    __table_args__ = {'schema': 'public'}

    journal_entry_id = Column(Integer, primary_key=True)
    ref_no = Column(String)
    account_type = Column(String)
    company = Column(String)
    transaction_date = Column(Date)
    journal_created_at = Column(Date)
    user_id = Column(Integer)
    journal_description = Column(String)
    journal_item_id = Column(Integer)
    narration = Column(String)
    debitcredit = Column(String)
    amount = Column(Numeric)
    journal_item_created_at = Column(Date)
    account_id = Column(Integer)
    subsidiary_account_id = Column(Integer)
    main_account_name = Column(String)
    main_account_code = Column(String)
    subsidiary_account_name = Column(String)
    subsidiary_account_no = Column(String)
    subsidiary_branch = Column(String)
    subsidiary_holder = Column(String)
    subsidiary_type = Column(String)
    client_id = Column(Integer)
    client_type = Column(String)
    registration_date = Column(Date)
