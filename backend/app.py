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
    with open('users.json', 'r') as f:
        users = json.load(f)
    user = next((u for u in users if u['username'] == data['username'] and u['password'] == data['password']), None)
    if user:
        return jsonify(user)
    return jsonify({"error": "Invalid credentials"}), 401

# --- Patient Routes ---
@app.route('/api/request_blood', methods=['POST'])
def request_blood():
    data = request.json
    matched_donors = find_best_donors(data)
    return jsonify(matched_donors)

# --- NEW ENDPOINT TO RESET THE TIMER ---
@app.route('/api/confirm_transfusion', methods=['POST'])
def confirm_transfusion():
    data = request.json
    patient_id = data.get('patient_id')

    if not patient_id:
        return jsonify({"error": "Patient ID is required"}), 400

    try:
        with open('users.json', 'r') as f:
            users = json.load(f)

        updated = False
        for user in users:
            if user.get('id') == patient_id and user.get('role') == 'patient':
                # Calculate the next due date from today
                interval = user.get('transfusion_interval_days', 21)
                next_due_date = datetime.now() + timedelta(days=interval)
                user['next_transfusion_due_date'] = next_due_date.strftime('%Y-%m-%d')
                updated = True
                break
        
        if not updated:
            return jsonify({"error": "Patient not found"}), 404

        # Write the changes back to the file
        with open('users.json', 'w') as f:
            json.dump(users, f, indent=4)
        
        # Return the updated patient profile
        return jsonify(next((u for u in users if u['id'] == patient_id), None))

    except Exception as e:
        return jsonify({"error": f"An internal error occurred: {e}"}), 500

# --- Donor Routes ---
@app.route('/api/requests', methods=['GET'])
def get_requests():
    # This feature can be deprecated or kept, but is not the focus now.
    return jsonify([])


if __name__ == '__main__':
    app.run(debug=True, port=5000)