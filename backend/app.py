from flask import Flask, request, jsonify
import json
import random
from datetime import datetime, timedelta
from ml_model import find_best_donors

app = Flask(__name__)

# --- User Management ---
@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    try:
        with open('users.json', 'r') as f:
            users = json.load(f)
        user = next((u for u in users if u['username'] == data['username'] and u['password'] == data['password']), None)
        if user:
            return jsonify(user)
        return jsonify({"error": "Invalid credentials"}), 401
    except FileNotFoundError:
        return jsonify({"error": "Database file not found."}), 500

# --- Patient Routes ---
@app.route('/api/request_blood', methods=['POST'])
def request_blood():
    data = request.json
    matched_donors = find_best_donors(data)
    return jsonify(matched_donors)

@app.route('/api/confirm_transfusion', methods=['POST'])
def confirm_transfusion():
    data = request.json
    patient_id = data.get('patient_id')
    if not patient_id:
        return jsonify({"error": "Patient ID is required"}), 400
    try:
        with open('users.json', 'r') as f:
            users = json.load(f)
        
        patient_found = False
        for user in users:
            if user.get('id') == patient_id and user.get('role') == 'patient':
                interval = user.get('transfusion_interval_days', 21)
                next_due_date = datetime.now() + timedelta(days=interval)
                user['next_transfusion_due_date'] = next_due_date.strftime('%Y-%m-%d')
                patient_found = True
                break
        
        if not patient_found:
             return jsonify({"error": "Patient not found"}), 404

        with open('users.json', 'w') as f:
            json.dump(users, f, indent=4)
        
        # Find and return the updated user object
        updated_user = next((u for u in users if u['id'] == patient_id), None)
        return jsonify(updated_user)

    except Exception as e:
        return jsonify({"error": f"An internal error occurred: {e}"}), 500

# --- NEW: e-RaktKosh Integration Simulation ---
@app.route('/api/blood_bank_status', methods=['GET'])
def get_blood_bank_status():
    try:
        with open('blood_banks.json', 'r') as f:
            data = json.load(f)
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# --- NEW: Patient Education Content ---
@app.route('/api/education_content', methods=['GET'])
def get_education_content():
    try:
        with open('education_content.json', 'r') as f:
            data = json.load(f)
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# --- NEW: Patient-Provider Communication ---
@app.route('/api/messages/<int:patient_id>', methods=['GET'])
def get_messages(patient_id):
    try:
        with open('messages.json', 'r') as f:
            all_messages = json.load(f)
        patient_messages = [msg for msg in all_messages if msg['patient_id'] == patient_id]
        return jsonify(sorted(patient_messages, key=lambda x: x['timestamp']))
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/messages', methods=['POST'])
def send_message():
    data = request.json
    try:
        with open('messages.json', 'r+') as f:
            messages = json.load(f)
            new_message = {
                "message_id": f"msg{len(messages) + 1}",
                "patient_id": data['patient_id'],
                "sender_role": data['sender_role'],
                "text": data['text'],
                "timestamp": datetime.now().isoformat()
            }
            messages.append(new_message)
            f.seek(0)
            json.dump(messages, f, indent=4)
        return jsonify(new_message), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True, port=5000)