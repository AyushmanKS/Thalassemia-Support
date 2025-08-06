from flask import Flask, request, jsonify
import json
from ml_model import find_best_donors

app = Flask(__name__)

@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    with open('users.json', 'r') as f:
        users = json.load(f)
    user = next((u for u in users if u['username'] == data['username'] and u['password'] == data['password']), None)
    if user:
        return jsonify(user)
    return jsonify({"error": "Invalid credentials"}), 401

@app.route('/api/request_blood', methods=['POST'])
def request_blood():
    data = request.json
    matched_donors = find_best_donors(data)
    return jsonify(matched_donors)

@app.route('/api/requests', methods=['GET'])
def get_requests():
    with open('requests.json', 'r') as f:
        requests = json.load(f)
    return jsonify(requests)


if __name__ == '__main__':
    app.run(debug=True, port=5000)