import psycopg2
import pandas as pd

conn = psycopg2.connect(
    host="localhost",
    database="olist_db",
    user="postgres",
    password="newp@ssword",
    port="5432"
)

print("Connection successful!")
conn.close()