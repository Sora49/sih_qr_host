# QR Scanner Backend

Simple Flask API that connects to your existing Neon PostgreSQL database to lookup QR code data.

## Core Functionality

1. **Flutter app** scans QR code containing UUID
2. **Flask backend** receives UUID via HTTP GET request
3. **PostgreSQL query** searches your existing `tenders` table
4. **JSON response** returns matching row data to Flutter

## API Endpoint

### GET `/search/<uuid>`
Lookup data by UUID from QR code.

**Example:**
```
GET /search/abc123-def456-ghi789
```

**Response:**
```json
{
  "id": 1,
  "uuid": "abc123-def456-ghi789",
  "tender_name": "Road Construction",
  "amount": 100000,
  "department": "Public Works"
}
```

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Create `.env` file with your Neon PostgreSQL connection:
```env
DATABASE_URL=postgresql://username:password@host/database?sslmode=require
```

3. Run the server:
```bash
python app.py
```

Server runs on `http://localhost:5000`

## Files

- `app.py` - Main Flask application
- `.env` - Database connection credentials  
- `requirements.txt` - Python dependencies
- `README.md` - This documentation"# sih_qr_host" 
