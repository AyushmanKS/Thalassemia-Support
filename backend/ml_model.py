from sklearn.neighbors import KDTree
import numpy as np
import json
from datetime import datetime
from geopy.distance import geodesic # <-- IMPORT THE NEW LIBRARY

def find_best_donors(patient_request):
    """
    Finds the best donors for a given patient request.
    VERSION 3:
    - Calculates geographic distance.
    - Uses a weighted score of donation recency and distance.
    """
    print(f"Received request: {patient_request}")

    try:
        with open('users.json', 'r') as f:
            users = json.load(f)

        patient_list = [u for u in users if u['role'] == 'patient' and u['id'] == patient_request['patient_id']]
        if not patient_list:
            print(f"Error: Patient with ID {patient_request['patient_id']} not found.")
            return []
        
        patient = patient_list[0]
        patient_coords = (patient['location']['lat'], patient['location']['lon'])
        
        donors = [u for u in users if u['role'] == 'donor' and u['blood_type'] == patient_request['blood_type']]

        if not donors:
            print("No compatible donors found.")
            return []

        ranked_donors = []
        for donor in donors:
            donor_coords = (donor['location']['lat'], donor['location']['lon'])
            
            # Feature 2: Calculate distance in kilometers
            distance_km = geodesic(patient_coords, donor_coords).kilometers

            # Feature 3: Create a smarter, weighted score
            # Score 1: Time since last donation (more days is better)
            try:
                last_donation = datetime.strptime(donor['last_donation_date'], '%Y-%m-%d')
                days_since_donation = (datetime.now() - last_donation).days
                time_score = days_since_donation
            except (ValueError, KeyError):
                time_score = 90  # Default score if date is missing

            # Score 2: Distance (closer is better). We invert it.
            # Adding 1 to avoid division by zero.
            distance_score = 100 / (1 + distance_km)

            # Combine scores with weights (60% time, 40% distance)
            # We normalize by typical values to balance the weights
            final_score = (0.6 * (time_score / 365)) + (0.4 * (distance_score / 100))
            final_score = final_score * 100 # Scale it up to be a nice number

            ranked_donors.append({
                "donor_id": donor['id'],
                "username": donor['username'],
                "blood_type": donor['blood_type'],
                "location": donor['location'],
                "distance_km": round(distance_km, 1), # <-- ADD THE NEW DATA
                "score": round(final_score, 2)       # The new, smarter score
            })

        # Sort by the new final_score in descending order
        ranked_donors.sort(key=lambda x: x['score'], reverse=True)
        print(f"Found and ranked {len(ranked_donors)} donors.")
        return ranked_donors

    except Exception as e:
        print(f"An unexpected error occurred in find_best_donors: {e}")
        return []