from flask import Flask, request, jsonify
import pytesseract
import cv2
import numpy as np
import re
from datetime import datetime

app = Flask(__name__)

# Configure tesseract path (Standard Windows Install Path)
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

def preprocess_image(img):
    # Resize if too large (improves speed significantly)
    height, width = img.shape[:2]
    if width > 1000:
        new_width = 1000
        new_height = int(height * (new_width / width))
        img = cv2.resize(img, (new_width, new_height))

    # Convert to grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Faster Denoising (Gaussian Blur instead of NlMeans)
    denoised = cv2.GaussianBlur(gray, (3, 3), 0)
    
    # Adaptive thresholding
    thresh = cv2.adaptiveThreshold(denoised, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2)
    
    return thresh

def calculate_confidence(text, pattern):
    if pattern.search(text):
        return 0.95
    return 0.40

def extract_data(img):
    # Stage 2: Preprocessing
    processed = preprocess_image(img)
    
    # Stage 3/4: Optimized OCR Call (Single call)
    full_text = pytesseract.image_to_string(processed, lang='eng+osd')
    
    data = {
        "name": {"value": "", "confidence": 0.0},
        "dob": {"value": "", "confidence": 0.0},
        "aadhaar": {"value": "", "confidence": 0.0},
        "gender": {"value": "", "confidence": 0.0},
        "father_name": {"value": "", "confidence": 0.0},
        "age": {"value": "", "confidence": 0.0}
    }

    # Regex patterns with fuzzy thinking
    name_pattern = re.compile(r'Name[:\- ]+([A-Z ]+)', re.IGNORECASE)
    dob_pattern = re.compile(r'(\d{2}/\d{2}/\d{4})')
    aadhaar_pattern = re.compile(r'(\d{4}\s\d{4}\s\d{4})')
    gender_pattern = re.compile(r'(Male|Female|Boy|Girl)', re.IGNORECASE)
    father_pattern = re.compile(r'(Father|Parent|Son of)[:\- ]+([A-Z ]+)', re.IGNORECASE)

    # Search in text
    name_match = name_pattern.search(full_text)
    if name_match:
        data["name"] = {"value": name_match.group(1).strip(), "confidence": 0.92}

    dob_match = dob_pattern.search(full_text)
    if dob_match:
        val = dob_match.group(1)
        data["dob"] = {"value": val, "confidence": 0.98}
        # Calculate Age
        try:
            dob_dt = datetime.strptime(val, "%d/%m/%Y")
            today = datetime.now()
            age_years = today.year - dob_dt.year - ((today.month, today.day) < (dob_dt.month, dob_dt.day))
            data["age"] = {"value": f"{age_years} years", "confidence": 1.0}
        except:
            pass

    aadhaar_match = aadhaar_pattern.search(full_text)
    if aadhaar_match:
        data["aadhaar"] = {"value": aadhaar_match.group(1), "confidence": 0.95}

    gender_match = gender_pattern.search(full_text)
    if gender_match:
        data["gender"] = {"value": gender_match.group(1).capitalize(), "confidence": 0.85}

    father_match = father_pattern.search(full_text)
    if father_match:
        data["father_name"] = {"value": father_match.group(2).strip(), "confidence": 0.88}

    return data

import uuid
import json
import os

# ... (existing imports)

# ... (preprocess_image, calculate_confidence, extract_data functions remain same)

@app.route('/ocr', methods=['POST'])
def ocr_process():
    request_id = str(uuid.uuid4())
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    try:
        file = request.files['image']
        img_array = np.frombuffer(file.read(), np.uint8)
        img = cv2.imdecode(img_array, cv2.IMREAD_COLOR)

        # check if tesseract is installed
        tesseract_available = os.path.exists(pytesseract.pytesseract.tesseract_cmd)
        
        if not tesseract_available:
            # Fallback Mock Mode
            print("⚠ Tesseract not found. Using Mock Data Mode.")
            extracted = {
                 "name": {"value": "RAHUL VERMA", "confidence": 0.95},
                 "dob": {"value": "12/05/2021", "confidence": 0.98},
                 "aadhaar": {"value": "1234 5678 9012", "confidence": 0.92},
                 "gender": {"value": "Male", "confidence": 0.90},
                 "father_name": {"value": "SURESH VERMA", "confidence": 0.88},
                 "age": {"value": "4 years", "confidence": 1.0}
            }
            return jsonify({
                "request_id": request_id,
                "extracted_data": extracted,
                "status": "mock_mode",
                "message": "Running in Simulation Mode (Tesseract Missing)"
            })

        # Extract structured data with stages
        extracted = extract_data(img)
        
        return jsonify({
            "request_id": request_id,
            "extracted_data": extracted
        })
    except pytesseract.TesseractNotFoundError:
        return jsonify({"error": "Tesseract not installed or path incorrect."}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/feedback', methods=['POST'])
def save_feedback():
    try:
        data = request.json
        request_id = data.get('request_id')
        corrected_data = data.get('corrected_data')
        
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "request_id": request_id,
            "corrected_data": corrected_data
        }
        
        # Simple JSON logging (Learning Loop)
        log_file = 'feedback_log.json'
        logs = []
        if os.path.exists(log_file):
            with open(log_file, 'r') as f:
                try:
                    logs = json.load(f)
                except:
                    pass
        
        logs.append(log_entry)
        
        with open(log_file, 'w') as f:
            json.dump(logs, f, indent=4)
            
        return jsonify({"status": "success", "message": "Feedback saved for learning loop"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/ocr_field', methods=['POST'])
def ocr_field():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    try:
        file = request.files['image']
        img_array = np.frombuffer(file.read(), np.uint8)
        img = cv2.imdecode(img_array, cv2.IMREAD_COLOR)

        # Preprocess for single line
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        denoised = cv2.GaussianBlur(gray, (3, 3), 0)
        thresh = cv2.threshold(denoised, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]
        
        # PSM 7 = Treat the image as a single text line.
        custom_config = r'--oem 3 --psm 7'
        text = pytesseract.image_to_string(thresh, config=custom_config, lang='eng')
        
        # Basic cleanup
        text = text.strip()
        text = re.sub(r'[|\n]', '', text)

        return jsonify({
            "extracted_text": text,
            "confidence": 0.85 # Placeholder
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
