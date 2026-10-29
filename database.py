import os
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv

load_dotenv()

def get_connection():
    """Create a new MySQL connection using local .env settings."""
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "InventoryDB"),
        connection_timeout=5,
    )

def fetch_all(query, params=None):
    conn = get_connection()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(query, params or ())
        return cur.fetchall()
    finally:
        cur.close()
        conn.close()

def fetch_one(query, params=None):
    conn = get_connection()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(query, params or ())
        return cur.fetchone()
    finally:
        cur.close()
        conn.close()

def execute_write(query, params=None):
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute(query, params or ())
        conn.commit()
        return cur.lastrowid
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()

def call_procedure(name, args):
    """Call one of the project's known stored procedures."""
    allowed = {"ReceiveStock", "IssueStock", "GetLowStockProducts"}
    if name not in allowed:
        raise ValueError("Procedure is not permitted.")
    conn = get_connection()
    try:
        cur = conn.cursor(dictionary=True)
        cur.callproc(name, args)
        results = []
        for result in cur.stored_results():
            results.extend(result.fetchall())
        conn.commit()
        return results
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()
