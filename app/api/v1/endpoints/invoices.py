# invoices.py
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from datetime import datetime
from datetime import timedelta
import os
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors
from typing import Optional
from app.models import Sale, Customer, Business, SaleProduct, User, Product
from app.db.session import get_db
#from auth import get_current_user
from app.api.v1.dependencies import get_current_user  # Update the import path
from app.schemas import sale as sale_schema
from typing import List
from sqlalchemy.orm import selectinload  # Import this for loading related objects
from sqlalchemy.future import select

router = APIRouter()

@router.get("/", response_model=List[sale_schema.Sale])
async def get_sales(db: Session = Depends(get_db)):
    result = await db.execute(select(Sale).options(selectinload(Sale.sale_products)))
    sales = result.scalars().all()
    return sales



@router.post("/", response_class=FileResponse)
async def generate_invoice(   
    #business_id: int,
    #sale_id: int,
    #current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    sale_id = 153
    b_id = 1
    include_tax=True
    # Verify business access
    #if not any(b.id == business_id for b in current_user.businesses):
    #    raise HTTPException(status_code=403, detail="Unauthorized access")
    
    # Get sale data
   
    result = await db.execute(select(Sale).options(selectinload(Sale.sale_products)).filter_by(id=sale_id, business_id = b_id))
    sale = result.scalars().first()   

    if not sale:
        raise HTTPException(status_code=404, detail="Sale not found")
    
    _customer = await db.execute(select(Customer).filter(Customer.id == sale.customer_id))
    customer = _customer.scalars().first()
    _business = await db.execute(select(Business).filter(Business.id == b_id))
    business = _business.scalars().first()
    item = await db.execute(select(SaleProduct).filter(SaleProduct.sale_id == sale_id))
    items = item.scalars().all()
    # Generate invoice number
    if not sale.invoice_number:
        sale.invoice_number = f"INV-{datetime.now().year}-{sale_id:05d}"
        db.commit()
            
    print(customer)

    return sale

@router.post("/abc", response_class=FileResponse)
async def generate_invoice2(
    business_id: int,
    sale_id: int,
    #include_tax: Optional[bool] = True,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    print("Hello World")
    business_id: 1
    sale_id: 153
    include_tax=True
    # Verify business access
    if not any(b.id == business_id for b in current_user.businesses):
        raise HTTPException(status_code=403, detail="Unauthorized access")
    
    # Get sale data
    sale = db.query(Sale).filter(
        Sale.id == sale_id,
        Sale.business_id == business_id
    ).first()
    
    if not sale:
        raise HTTPException(status_code=404, detail="Sale not found")
    
    customer = db.query(Customer).filter(Customer.id == sale.customer_id).first()
    business = db.query(Business).filter(Business.id == business_id).first()
    items = db.query(SaleProduct).filter(SaleProduct.sale_id == sale_id).all()
    
    # Generate invoice number
    if not sale.invoice_number:
        sale.invoice_number = f"INV-{datetime.now().year}-{sale_id:05d}"
        db.commit()
    
    # Create PDF invoice
    filename = f"invoice_{sale.invoice_number}.pdf"
    filepath = os.path.join("invoices", filename)
    
    os.makedirs("invoices", exist_ok=True)
    doc = SimpleDocTemplate(filepath, pagesize=letter)
    
    # Styles
    styles = getSampleStyleSheet()
    title_style = styles["Title"]
    heading_style = styles["Heading2"]
    normal_style = styles["Normal"]
    
    # Content
    elements = []
    
    # Header
    elements.append(Paragraph(business.name, title_style))
    elements.append(Paragraph(business.address, normal_style))
    elements.append(Paragraph(f"Phone: {business.phone}", normal_style))
    elements.append(Paragraph(f"Tax ID: {business.tax_id}", normal_style))
    elements.append(Paragraph("<br/><br/>", normal_style))
    
    # Invoice info
    elements.append(Paragraph(f"Invoice: {sale.invoice_number}", heading_style))
    elements.append(Paragraph(f"Date: {sale.sale_date.strftime('%Y-%m-%d')}", normal_style))
    elements.append(Paragraph(f"Due Date: {(sale.sale_date + timedelta(days=30)).strftime('%Y-%m-%d')}", normal_style))
    elements.append(Paragraph("<br/>", normal_style))
    
    # Customer info
    elements.append(Paragraph("Bill To:", heading_style))
    elements.append(Paragraph(customer.name, normal_style))
    elements.append(Paragraph(customer.address, normal_style))
    elements.append(Paragraph(f"Tax ID: {customer.tax_id}", normal_style))
    elements.append(Paragraph("<br/><br/>", normal_style))
    
    # Items table
    data = [["Item", "Qty", "Unit Price", "Amount"]]
    
    for item in items:
        product = db.query(Product).filter(Product.id == item.product_id).first()
        row = [
            product.name,
            str(item.quantity),
            f"${item.unit_price:.2f}",
            f"${item.quantity * item.unit_price:.2f}"
        ]
        data.append(row)
    
    # Add totals
    data.append(["", "", "Subtotal:", f"${sale.subtotal:.2f}"])
    
    if include_tax and sale.tax_amount > 0:
        data.append(["", "", "Tax:", f"${sale.tax_amount:.2f}"])
    
    data.append(["", "", "Total:", f"${sale.total_amount:.2f}"])
    
    table = Table(data)
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'RIGHT'),
        ('ALIGN', (0, 0), (0, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
    ]))
    
    elements.append(table)
    elements.append(Paragraph("<br/><br/>", normal_style))
    
    # Footer
    elements.append(Paragraph("Thank you for your business!", normal_style))
    elements.append(Paragraph("Payment terms: Net 30 days", normal_style))
    
    # Build PDF
    doc.build(elements)
    
    # Update sale status
    sale.invoice_status = "generated"
    db.commit()
    
    return FileResponse(
        filepath,
        media_type="application/pdf",
        filename=filename
    )