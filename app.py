from flask import Flask, jsonify
from flask_cors import CORS
import psycopg2
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

def get_db_connection():
    """Connect to Render PostgreSQL database using environment variable"""
    try:
        # Render provides DATABASE_URL as environment variable
        database_url = os.getenv("DATABASE_URL")
        if not database_url:
            print("ERROR: DATABASE_URL environment variable not set")
            return None
            
        conn = psycopg2.connect(database_url)
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        return None

@app.route('/', methods=['GET'])
def health_check():
    """Health check endpoint for Render"""
    return jsonify({"status": "Backend is running", "service": "QR Scanner API"})

@app.route('/search/<uuid>', methods=['GET'])
def search_qr_by_uuid(uuid):
    """
    Core functionality: Take QR code UUID from Flutter,
    search database, return matching row
    """
    try:
        if not uuid:
            return jsonify({"error": "UUID is required"}), 400

        conn = get_db_connection()
        if conn is None:
            return jsonify({"error": "Database connection failed"}), 500
            
        cursor = conn.cursor()

        # Query your tenders table where uuid matches QR code text
        cursor.execute("SELECT * FROM tenders WHERE uuid = %s;", (uuid,))
        row = cursor.fetchone()

        if not row:
            cursor.close()
            conn.close()
            return jsonify({"message": "No record found"}), 404

        # Get column names to build response
        colnames = [desc[0] for desc in cursor.description]
        cursor.close()
        conn.close()

        # Return the row data as JSON to Flutter
        result = dict(zip(colnames, row))
        return jsonify(result)

    except Exception as e:
        print(f"Search error: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # For local development
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
