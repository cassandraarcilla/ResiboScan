import os
import re
import base64
from io import BytesIO
from flask import Flask, request, jsonify
from PIL import Image
import pytesseract

app = Flask(__name__)

def extract_receipt_data(text):
    lines = [line.strip() for line in text.split('\n') if line.strip()]
    
    store = lines[0] if lines else ""
    
    amount = ""
    # Look for TOTAL, AMOUNT, or DUE followed by a number
    amount_match = re.search(r'(?:TOTAL|AMOUNT|DUE)\s*[:\$]?\s*([0-9]+[.,][0-9]{2})', text, re.IGNORECASE)
    if amount_match:
        amount = amount_match.group(1).replace(',', '.')
    
    date = ""
    # Look for common date formats (YYYY-MM-DD, MM/DD/YYYY, DD-MM-YYYY, etc)
    date_match = re.search(r'(\d{2,4}[-/]\d{2}[-/]\d{2,4})', text)
    if date_match:
        # Just grab the matched date string
        # In a real scenario, we might parse this to standard YYYY-MM-DD
        date = date_match.group(1)
        
    return {
        "store": store,
        "amount": amount,
        "date": date,
        "raw_text": text
    }

@app.route('/scan', methods=['POST'])
def scan_receipt():
    try:
        data = request.get_json()
        if not data or 'image_base64' not in data:
            return jsonify({"error": "Missing image_base64 in payload."}), 400
            
        img_data = base64.b64decode(data['image_base64'])
        image = Image.open(BytesIO(img_data))
        
        # Run OCR
        extracted_text = pytesseract.image_to_string(image)
        
        # Parse text
        result = extract_receipt_data(extracted_text)
        
        return jsonify(result), 200
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
