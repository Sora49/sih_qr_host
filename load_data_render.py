"""
Script to load tenders.sql data into Render PostgreSQL database
Run this ONCE after setting up your Render database
"""
import psycopg2
import os

def load_data_to_render():
    print("🚀 Loading data to Render PostgreSQL database...")
    
    # Render database connection
    database_url = "postgresql://tenders_db_38eb_user:gu5BmXMPnOcholevzyC9Kn30Zh9MmBnW@dpg-d382sm0gjchc73cnljm0-a.oregon-postgres.render.com/tenders_db_38eb"
    
    try:
        # Connect to Render database
        conn = psycopg2.connect(database_url)
        cursor = conn.cursor()
        print("✅ Connected to Render database")
        
        # Read and execute the SQL file
        with open('sql/tenders.sql', 'r', encoding='utf-8') as file:
            sql_content = file.read()
        
        # Execute the SQL (this will create table and insert all data)
        cursor.execute(sql_content)
        conn.commit()
        
        # Check how many records were inserted
        cursor.execute("SELECT COUNT(*) FROM tenders;")
        count = cursor.fetchone()[0]
        print(f"✅ Loaded {count} tenders successfully")
        
        # Show some sample UUIDs for testing
        cursor.execute("SELECT uuid, tender_title FROM tenders WHERE uuid IS NOT NULL LIMIT 5;")
        samples = cursor.fetchall()
        
        if samples:
            print("\n📋 Sample UUIDs for QR code testing:")
            for uuid_val, title in samples:
                print(f"   UUID: {uuid_val}")
                print(f"   Title: {title[:50]}...")
                print(f"   Test URL: https://sih-qr-host.onrender.com/search/{uuid_val}")
                print()
        else:
            print("⚠️ No UUIDs found - check if UUID column was created properly")
        
        cursor.close()
        conn.close()
        print("🎉 Database setup completed on Render!")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    load_data_to_render()