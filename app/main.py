from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware
from app.api.v1.endpoints import products, sales, auth, inventory_logs, cash_register, transaction, journal_entries ,cash_flow, account, journal_items, vendor, purchase_orders, invoices, payment, enum_type, accounting, customer, business, driver, delivery, subsidiary_account, client, expenses, lc_records
from app.api.v1.endpoints import financial_report
import uvicorn

app = FastAPI()

# Set up CORS
# Add CORS middleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://exim-erp-backend-1.onrender.com"],  # React frontend origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(products.router, prefix="/api/v1/products", tags=["products"])
app.include_router(sales.router, prefix="/api/v1/sales", tags=["sales"])
app.include_router(payment.router, prefix="/api/v1/payments", tags=["payments"])
app.include_router(invoices.router, prefix="/api/v1/businesses", tags=["invoices"])
app.include_router(business.router, prefix="/api/v1/business", tags=["business"])
app.include_router(inventory_logs.router, prefix="/api/v1/inventory", tags=["inventory"])
app.include_router(cash_register.router, prefix="/api/v1/cash-register", tags=["register"])
app.include_router(transaction.router, prefix="/api/v1/transaction", tags=["transaction"])
app.include_router(journal_entries.router, prefix="/api/v1/journal-entries", tags=["journal_entries"])
app.include_router(journal_items.router, prefix="/api/v1/journal-items", tags=["journal_items"])
app.include_router(accounting.router, prefix="/api/v1/accounting", tags=["accounting"])
app.include_router(financial_report.router, prefix="/api/v1/reports", tags=["report"])
app.include_router(cash_flow.router, prefix="/api/v1/cash_flow", tags=["cash_flow"])
app.include_router(enum_type.router, prefix="/api/v1/enum_type", tags=["enum_type"])
app.include_router(account.router, prefix="/api/v1/account", tags=["account"])
app.include_router(subsidiary_account.router, prefix="/api/v1/subsidiary-account", tags=["subsidiary_account"])
app.include_router(customer.router, prefix="/api/v1/customer", tags=["customer"])
app.include_router(client.router, prefix="/api/v1/client", tags=["client"])
app.include_router(vendor.router, prefix="/api/v1/vendor", tags=["vendor"])
app.include_router(purchase_orders.router, prefix="/api/v1/purchase_orders", tags=["purchase_orders"])
app.include_router(driver.router, prefix="/api/v1/drivers", tags=["drivers"])
app.include_router(delivery.router, prefix="/api/v1/deliveries", tags=["deliveries"])
app.include_router(expenses.router, prefix="/api/v1/expenses", tags=["expenses"])
app.include_router(lc_records.router, prefix="/api/v1/lc", tags=["lc"])

app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])


@app.get("/")
def read_root():
    return {"message": "Welcome to the POS API"}


# ------------------------------
# For Local Testing
# ------------------------------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=10000, reload=True)
