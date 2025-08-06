from sklearn.neighbors import KDTree
import numpy as np
import json
from datetime import datetime

def find_best_donors(patient_request):
    """
    Finds the best donors for a given patient request.
    """
    with open('users.json', 'r') as f:
        users = json.load(f)

    donors = [u for u in users if u['role'] == 'donor' and u['blood_type'] == patient_request['blood_type']]

    if not donors:
        return []

    donor_locations = np.array([[d['location']['lat'], d['location']['lon']] for d in donors])
    patient_location = np.array([[u['location']['lat'], u['location']['lon']] for u in users if u['id'] == patient_request['patient_id']])

    tree = KDTree(donor_locations)
    dist, ind = tree.query(patient_location, k=min(len(donors), 5)) 

    ranked_donors = []
    for i in ind[0]:
        donor = donors[i]
        last_donation = datetime.strptime(donor['last_donation_date'], '%Y-%m-%d')
        days_since_donation = (datetime.now() - last_donation).days
        score = days_since_donation 

        ranked_donors.append({
            "donor_id": donor['id'],
            "username": donor['username'],
            "blood_type": donor['blood_type'],
            "location": donor['location'],
            "score": score
        })

    ranked_donors.sort(key=lambda x: x['score'], reverse=True)
    return ranked_donors