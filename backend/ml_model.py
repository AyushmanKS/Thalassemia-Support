import json
from datetime import datetime
from geopy.distance import geodesic

def find_best_donors(patient_request):
    """
    Finds the best donors for a given patient request.
    VERSION 4:
    - Calculates a 'Trust Score' based on donation history and civic score.
    - Ranks donors based on a combination of match score and trust score.
    """
    print(f"AI Model V4 running for request: {patient_request}")

    try:
        with open('users.json', 'r') as f:
            users = json.load(f)

        # Find patient details
        patient_list = [u for u in users if u['role'] == 'patient' and u['id'] == patient_request['patient_id']]
        if not patient_list:
            return []
        patient = patient_list[0]
        patient_coords = (patient['location']['lat'], patient['location']['lon'])
        
        # Find compatible donors
        donors = [u for u in users if u['role'] == 'donor' and u['blood_type'] == patient_request['blood_type']]
        if not donors:
            return []

        ranked_donors = []
        for donor in donors:
            # --- CALCULATE MATCH SCORE (recency + distance) ---
            distance_km = geodesic(patient_coords, (donor['location']['lat'], donor['location']['lon'])).kilometers
            try:
                days_since_donation = (datetime.now() - datetime.strptime(donor['last_donation_date'], '%Y-%m-%d')).days
            except (ValueError, KeyError):
                days_since_donation = 90  # Default if no date

            distance_score = 100 / (1 + distance_km)
            recency_score = min(days_since_donation, 365) # Cap at 1 year
            match_score = (0.4 * distance_score) + (0.6 * (recency_score / 3.65)) # Weighted and normalized

            # --- CALCULATE TRUST SCORE (reliability and engagement) ---
            donation_count = donor.get('donations', 0)
            civic_score = donor.get('civic_score', 0)
            # Formula: 10 points per donation + 1 point per 10 civic points. Capped at 100.
            trust_score = min(100, (donation_count * 10) + (civic_score / 10))

            # --- COMBINE SCORES FOR FINAL RANKING ---
            # 70% Trust, 30% immediate Match convenience
            final_rank = (0.7 * trust_score) + (0.3 * match_score)

            ranked_donors.append({
                "donor_id": donor['id'],
                "username": donor['username'],
                "blood_type": donor['blood_type'],
                "distance_km": round(distance_km, 1),
                "trust_score": round(trust_score, 1), # The new trust score
                "final_rank": round(final_rank, 2)    # The new final ranking metric
            })

        # Sort by the new final_rank in descending order
        ranked_donors.sort(key=lambda x: x['final_rank'], reverse=True)
        print(f"AI successfully ranked {len(ranked_donors)} donors.")
        return ranked_donors

    except Exception as e:
        print(f"An unexpected error occurred in AI model: {e}")
        return []