from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle
import numpy as np
import pandas as pd

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes
# Load the model once at startup
with open('accommodation_model.pkl', 'rb') as f:
    model_data = pickle.load(f)

models = model_data['models']
mlb = model_data['mlb']
label_encoder = model_data['label_encoder']
accommodations = model_data['accommodations']

@app.route('/predict', methods=['POST'])
def predict():
    """
    Expects JSON like:
    {
        "grade": 3,
        "diagnosis": "ADHD",
        "reading": 2,
        "math": 2, 
        "attention": 1,
        "social": 2,
        "motor": 3
    }
    """
    try:
        data = request.json
        if not data:
            return jsonify({
                'success': False,
                'error': 'No JSON data provided'
            }), 400
        
        # Validate required fields
        required_fields = ['grade', 'diagnosis', 'reading', 'math', 'attention', 'social', 'motor']
        missing_fields = [field for field in required_fields if field not in data]
        if missing_fields:
            return jsonify({
                'success': False,
                'error': f'Missing required fields: {", ".join(missing_fields)}'
            }), 400
        
        # Encode diagnosis
        diagnosis_code = label_encoder.transform([data['diagnosis']])[0]

        # Create feature vector
        student_features = pd.DataFrame({
            'grade_level': [data['grade']],
            'reading_fluency': [data['reading']],
            'math_skill': [data['math']],
            'attention_level': [data['attention']],
            'social_skills': [data['social']],
            'motor_skills': [data['motor']],
            'diagnosis_encoded': [diagnosis_code]
        })

        # Get predictions from all models
        predictions = {}
        for accommodation, model in models.items():
            probability = model.predict_proba(student_features)[0][1]
            predictions[accommodation] = float(probability)

        # Sort and return top 4
        sorted_preds = sorted(predictions.items(), key=lambda x: x[1], reverse=True)
        top_4 = [(acc, prob) for acc, prob in sorted_preds[:4]]

        return jsonify({
            'success': True,
            'accommodations': top_4
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
