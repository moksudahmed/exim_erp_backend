from enum import Enum
import enum
from enum import Enum as PyEnum

# Enum for AccountType
class AccountTypeEnum(str, Enum):
    ASSET = 'asset'
    LIABILITY = 'liability'
    EQUITY = 'equity'
    REVENUE = 'revenue'
    EXPENSE = 'expense'

class ProductCategory(str, Enum):
    COAL = 'COAL'
    SEND = 'SEND'
    STONE = 'STONE'

class ProductSubCategory(str, Enum):
    SUPER = 'SUPER'
    MEDIUM = 'MEDIUM'
    MIXTURE = 'MIXTURE'
    

class AccountTypeEnum2(str, Enum):
    ASSET = 'ASSET'
    LIABILITY = 'LIABILITY'
    EQUITY = 'EQUITY'
    REVENUE = 'REVENUE'
    EXPENSE = 'EXPENSE'

# Enum for transaction payment methods
class PaymentMethod(str, PyEnum):
    cash = "cash"
    credit="credit"
    credit_card = "credit_card"        
    bank_transfer = "bank_transfer"
    check = "check"
    bkash = "bkash"
    nagad = "nagad"
    online = "online"
    other = "other"

class PaymentMethodOld(str, PyEnum):
    CASH = "cash"
    CARD = "card"
    BANK_TRANSFER = "bank_transfer"
    CHECK = "check"
    BKASH = "bkash"
    NAGAD = "nagad"
    ONLINE = "online"
    OTHER = "other"

class ActionType(enum.Enum):
    ADD = 'ADD'
    DEDUCT = 'DEDUCT'
    DAMAGED = 'DAMAGED'

class AccountAction(str, Enum):
    DEBIT = "DEBIT"
    CREDIT = "CREDIT"

class AccountNature(str, Enum):
    DEBIT = "DEBIT"
    CREDIT = "CREDIT"

"""class AccountAction(str, Enum):
    dr='DEBIT'
    cr='CREDIT'
"""
class OrderStatusEnum(str, Enum):
    PENDING = "PENDING"
    RECEIVED = "RECEIVED"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"

class ProductTypeEnum(Enum):
    tangible = 'tangible'
    intangible = 'intangible'
    digital = 'digital'
    service = 'service'
    liquid = 'liquid'

class UnitOfMeasurement(Enum):
    piece = "piece"
    kg = "kg"
    g = "g"
    lb = "lb"
    litre = "litre"
    ml = "ml"
    meter = "meter"
    cm = "cm"
    pack = "pack"
    box = "box"
    dozen = "dozen"
    carton = "carton"
    set = "set"
    hour = "hour"
    service = "service"
    mt = "mt"

class InvoiceStatus(str, Enum):
    DRAFT = "draft"
    SENT = "sent"
    PAID = "paid"
    OVERDUE = "overdue"
    CANCELLED = "cancelled"
    
# For Accounting Modules

# Enums
class TransactionType2(Enum):
    INCOME = "income"
    EXPENSE = "expense"

class TransactionType(str, Enum):
    DEBIT = "DEBIT"
    CREDIT = "CREDIT"
    TRANSFER = "TRANSFER"
    ADJUSTMENT = "ADJUSTMENT"

class InvoiceStatus(Enum):
    DRAFT = "draft"
    SENT = "sent"
    PAID = "paid"
    OVERDUE = "overdue"
    CANCELLED = "cancelled"

    
class PaymentStatus(str, Enum):
    PENDING = "PENDING"
    PARTIAL = "PARTIAL"
    PAID = "PAID"
    OVERDUE="OVERDUE"
    REFUNDED="REFUNDED"
    DUE="DUE"
   # ONHOLD= "ONHOLD"
   # PROCESSING="PROCESSING"
   #FAILED
   #COMPLETED


    

class CurrencyCode(str, Enum):
    USD = "USD"
    EUR = "EUR"
    GBP = "GBP"
    JPY = "JPY"

class ClientType(str, Enum):
    CUSTOMER ="CUSTOMER"
    SUPPLIER ="SUPPLIER"
    EMPLOYEE ="EMPLOYEE"

class LCStatusEnum(str, Enum):
    OPEN = 'OPEN'
    REALIZED = 'REALIZED'
    CLOSED = 'CLOSED'
    SUBMITTED='SUBMITTED'
    APPROVED='APPROVED'
    ISSUED='ISSUED'
    GOODS_RECEIVED='GOODS_RECEIVED'