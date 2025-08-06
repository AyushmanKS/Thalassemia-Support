from flask import Flask, request, jsonify
import json
import random # We'll use this to create a unique ID
from ml_model import find_best_donors

app = Flask(__name__)

# --- User Management (no changes here) ---
@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    with open('users.json', 'r') as f:
        users = json.load(f)
    user = next((u for u in users if u['username'] == data['username'] and u['password'] == data['password']), None)
    if user:
        return jsonify(user)
    return jsonify({"error": "Invalid credentials"}), 401

# --- Patient Routes (THIS IS THE MAIN CHANGE) ---
@app.route('/api/request_blood', methods=['POST'])
def request_blood():
    data = request.json
    
    # Part 1: Create a new request in requests.json
    try:
        with open('requests.json', 'r+') as f:
            requests = json.load(f)
            new_request = {
                "id": random.randint(100, 999), # Simple unique ID for the request
                "patient_id": data['patient_id'],
                "blood_type": data['blood_type'],
                "status": "pending"
            }
            requests.append(new_request)
            f.seek(0) # Rewind to the start of the file
            json.dump(requests, f, indent=4) # Write the updated list back
    except (IOError, json.JSONDecodeError) as e:
        print(f"Error updating requests.json: {e}")
        # Even if this fails, we can still try to find donors
        pass

    # Part 2: Find and return the best donors (no changes to this part)
    matched_donors = find_best_donors(data)
    return jsonify(matched_donors)

# --- Donor Routes (no changes here) ---
@app.route('/api/requests', methods=['GET'])
def get_requests():
    with open('requests.json', 'r') as f:
        requests = json.load(f)
    # Return requests in reverse order so newest are first
    return jsonify(requests[::-1])


if __name__ == '__main__':
    app.run(debug=True, port=5000)