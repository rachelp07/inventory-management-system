import streamlit as st
import pandas as pd
from mysql.connector import Error
from database import fetch_all, fetch_one

st.set_page_config(page_title="InventoryDB | Inventory Management", page_icon="📦", layout="wide")

st.markdown("""
<style>
    .block-container {padding-top: 1.6rem; padding-bottom: 2rem;}
    [data-testid="stMetric"] {background: var(--secondary-background-color); padding: 14px 16px; border-radius: 12px;}
    div[data-testid="stSidebar"] {border-right: 1px solid rgba(128,128,128,.2);}
</style>
""", unsafe_allow_html=True)

st.sidebar.title("📦 InventoryDB")
st.sidebar.caption("Inventory & Supplier Management")
page = st.sidebar.radio("Navigation", ["Dashboard", "Products", "Suppliers", "Stock Management", "Reports"])
st.sidebar.divider()
st.sidebar.caption("DBMS Mini Project • MySQL + Python")

def show_error(exc):
    st.error(f"Database operation failed: {exc}")
    st.caption("Check your .env settings and confirm that the InventoryDB database is running.")

def df_or_empty(rows):
    return pd.DataFrame(rows) if rows else pd.DataFrame()

try:
    if page == "Dashboard":
        st.title("Inventory Dashboard")
        st.caption("A live overview of your inventory database.")
        totals = fetch_one("""
            SELECT COUNT(*) AS product_count,
                   COALESCE(SUM(quantity_in_stock), 0) AS units_in_stock,
                   COALESCE(SUM(quantity_in_stock * unit_price), 0) AS inventory_value
            FROM Products
        """)
        low = fetch_one("SELECT COUNT(*) AS low_count FROM LowStockProducts")
        suppliers = fetch_one("SELECT COUNT(*) AS supplier_count FROM Suppliers")
        c1, c2, c3, c4 = st.columns(4)
        c1.metric("Products", totals["product_count"])
        c2.metric("Units in stock", totals["units_in_stock"])
        c3.metric("Low-stock products", low["low_count"])
        c4.metric("Suppliers", suppliers["supplier_count"])
        st.subheader("Inventory value")
        st.metric("Current stock value", f"₹{float(totals['inventory_value']):,.2f}")
        left, right = st.columns([1.3, 1])
        with left:
            st.subheader("Products requiring attention")
            low_rows = fetch_all("SELECT * FROM LowStockProducts ORDER BY quantity_in_stock ASC")
            if low_rows:
                st.dataframe(df_or_empty(low_rows), use_container_width=True, hide_index=True)
            else:
                st.success("No products are currently at or below their reorder level.")
        with right:
            st.subheader("Recent stock movements")
            movements = fetch_all("""
                SELECT sm.movement_date, p.product_name, sm.movement_type,
                       sm.quantity_changed, sm.remarks
                FROM StockMovements sm JOIN Products p ON p.product_id = sm.product_id
                ORDER BY sm.movement_id DESC LIMIT 8
            """)
            if movements:
                st.dataframe(df_or_empty(movements), use_container_width=True, hide_index=True)
            else:
                st.info("No stock movements recorded yet.")

    elif page == "Products":
        st.title("Product Management")
        tab1, tab2 = st.tabs(["View / Search Products", "Add Product"])
        with tab1:
            search = st.text_input("Search by product name or SKU", placeholder="e.g. Wireless Mouse or ELEC001")
            query = """
                SELECT p.product_id, p.product_name, p.sku, c.category_name,
                       p.unit_price, p.quantity_in_stock, p.reorder_level
                FROM Products p JOIN Categories c ON c.category_id = p.category_id
            """
            if search.strip():
                like = f"%{search.strip()}%"
                rows = fetch_all(query + " WHERE p.product_name LIKE %s OR p.sku LIKE %s ORDER BY p.product_id", (like, like))
            else:
                rows = fetch_all(query + " ORDER BY p.product_id")
            st.dataframe(df_or_empty(rows), use_container_width=True, hide_index=True)
            st.caption(f"{len(rows)} product(s) shown.")
        with tab2:
            categories = fetch_all("SELECT category_id, category_name FROM Categories ORDER BY category_name")
            if not categories:
                st.warning("Add a category in MySQL before adding products.")
            else:
                category_names = {c["category_name"]: c["category_id"] for c in categories}
                with st.form("add_product_form", clear_on_submit=True):
                    name = st.text_input("Product name")
                    sku = st.text_input("SKU / unique code")
                    category_name = st.selectbox("Category", list(category_names))
                    price = st.number_input("Unit price (₹)", min_value=0.0, value=100.0, step=10.0)
                    quantity = st.number_input("Opening stock quantity", min_value=0, value=0, step=1)
                    reorder = st.number_input("Reorder level", min_value=0, value=10, step=1)
                    submitted = st.form_submit_button("Add product", type="primary")
                if submitted:
                    if not name.strip() or not sku.strip():
                        st.warning("Product name and SKU are required.")
                    else:
                        from database import execute_write
                        try:
                            execute_write("""
                                INSERT INTO Products
                                (category_id, product_name, sku, unit_price, quantity_in_stock, reorder_level)
                                VALUES (%s, %s, %s, %s, %s, %s)
                            """, (category_names[category_name], name.strip(), sku.strip(), price, quantity, reorder))
                            st.success("Product added successfully.")
                            st.rerun()
                        except Exception as exc:
                            show_error(exc)

    elif page == "Suppliers":
        st.title("Supplier Management")
        tab1, tab2 = st.tabs(["Supplier Directory", "Add Supplier"])
        with tab1:
            rows = fetch_all("""
                SELECT s.supplier_id, s.supplier_name, s.contact_person, s.phone, s.email, s.address,
                       COUNT(sp.product_id) AS supplied_products
                FROM Suppliers s LEFT JOIN SupplierProducts sp ON sp.supplier_id = s.supplier_id
                GROUP BY s.supplier_id, s.supplier_name, s.contact_person, s.phone, s.email, s.address
                ORDER BY s.supplier_name
            """)
            st.dataframe(df_or_empty(rows), use_container_width=True, hide_index=True)
        with tab2:
            with st.form("add_supplier_form", clear_on_submit=True):
                supplier_name = st.text_input("Supplier name")
                contact = st.text_input("Contact person")
                phone = st.text_input("Phone")
                email = st.text_input("Email")
                address = st.text_input("Address")
                submitted = st.form_submit_button("Add supplier", type="primary")
            if submitted:
                if not supplier_name.strip():
                    st.warning("Supplier name is required.")
                else:
                    from database import execute_write
                    try:
                        execute_write("""
                            INSERT INTO Suppliers (supplier_name, contact_person, phone, email, address)
                            VALUES (%s, %s, %s, %s, %s)
                        """, (supplier_name.strip(), contact.strip() or None, phone.strip() or None,
                              email.strip() or None, address.strip() or None))
                        st.success("Supplier added successfully.")
                        st.rerun()
                    except Exception as exc:
                        show_error(exc)

    elif page == "Stock Management":
        st.title("Stock Management")
        st.info("Stock changes are recorded in StockMovements. MySQL triggers update the product quantity, while stored procedures validate stock operations.")
        products = fetch_all("SELECT product_id, product_name, sku, quantity_in_stock FROM Products ORDER BY product_name")
        users = fetch_all("SELECT user_id, full_name FROM Users ORDER BY full_name")
        if not products or not users:
            st.warning("The Products and Users tables must contain records before stock can be changed.")
        else:
            product_labels = {f'{p["product_name"]} ({p["sku"]}) — current stock: {p["quantity_in_stock"]}': p["product_id"] for p in products}
            user_labels = {u["full_name"]: u["user_id"] for u in users}
            c1, c2 = st.columns(2)
            with c1:
                st.subheader("Receive stock")
                with st.form("receive_stock_form", clear_on_submit=True):
                    product_in = st.selectbox("Product", list(product_labels), key="receive_product")
                    user_in = st.selectbox("Recorded by", list(user_labels), key="receive_user")
                    qty_in = st.number_input("Quantity received", min_value=1, value=1, step=1, key="receive_qty")
                    remarks_in = st.text_input("Remarks", value="Stock received", key="receive_remarks")
                    receive = st.form_submit_button("Receive stock", type="primary")
                if receive:
                    from database import call_procedure
                    try:
                        call_procedure("ReceiveStock", (product_labels[product_in], user_labels[user_in], int(qty_in), remarks_in.strip() or None))
                        st.success("Stock received. Product quantity updated.")
                        st.rerun()
                    except Exception as exc:
                        show_error(exc)
            with c2:
                st.subheader("Issue stock")
                with st.form("issue_stock_form", clear_on_submit=True):
                    product_out = st.selectbox("Product", list(product_labels), key="issue_product")
                    user_out = st.selectbox("Recorded by", list(user_labels), key="issue_user")
                    qty_out = st.number_input("Quantity issued", min_value=1, value=1, step=1, key="issue_qty")
                    remarks_out = st.text_input("Remarks", value="Stock issued", key="issue_remarks")
                    issue = st.form_submit_button("Issue stock", type="primary")
                if issue:
                    from database import call_procedure
                    try:
                        call_procedure("IssueStock", (product_labels[product_out], user_labels[user_out], int(qty_out), remarks_out.strip() or None))
                        st.success("Stock issued. Product quantity updated.")
                        st.rerun()
                    except Exception as exc:
                        show_error(exc)
        st.subheader("Stock movement history")
        history = fetch_all("""
            SELECT sm.movement_id, p.product_name, u.full_name AS recorded_by,
                   sm.movement_type, sm.quantity_changed, sm.movement_date, sm.remarks
            FROM StockMovements sm
            JOIN Products p ON p.product_id = sm.product_id
            JOIN Users u ON u.user_id = sm.user_id
            ORDER BY sm.movement_id DESC
        """)
        st.dataframe(df_or_empty(history), use_container_width=True, hide_index=True)

    elif page == "Reports":
        st.title("Reports")
        report = st.selectbox("Choose a report", [
            "Inventory Report", "Low-stock Products", "Purchase Order Summary",
            "Products and Suppliers", "Stock Movement Totals"
        ])
        if report == "Inventory Report":
            rows = fetch_all("SELECT * FROM InventoryReport ORDER BY product_name")
        elif report == "Low-stock Products":
            rows = fetch_all("SELECT * FROM LowStockProducts ORDER BY quantity_in_stock")
        elif report == "Purchase Order Summary":
            rows = fetch_all("SELECT * FROM PurchaseOrderSummary ORDER BY order_id DESC")
        elif report == "Products and Suppliers":
            rows = fetch_all("""
                SELECT p.product_name, p.sku, s.supplier_name, sp.supplier_price
                FROM SupplierProducts sp
                JOIN Products p ON p.product_id = sp.product_id
                JOIN Suppliers s ON s.supplier_id = sp.supplier_id
                ORDER BY p.product_name, s.supplier_name
            """)
        else:
            rows = fetch_all("""
                SELECT p.product_name,
                    COALESCE(SUM(CASE WHEN sm.quantity_changed > 0 THEN sm.quantity_changed ELSE 0 END), 0) AS total_in,
                    COALESCE(SUM(CASE WHEN sm.quantity_changed < 0 THEN -sm.quantity_changed ELSE 0 END), 0) AS total_out
                FROM Products p LEFT JOIN StockMovements sm ON sm.product_id = p.product_id
                GROUP BY p.product_id, p.product_name ORDER BY p.product_name
            """)
        frame = df_or_empty(rows)
        st.dataframe(frame, use_container_width=True, hide_index=True)
        if not frame.empty:
            st.download_button("Download report as CSV", frame.to_csv(index=False).encode("utf-8"), file_name=report.lower().replace(" ", "_") + ".csv", mime="text/csv")

except Error as exc:
    show_error(exc)
except Exception as exc:
    show_error(exc)
