from flask import Flask, request, jsonify
import pandas as pd
import pickle
from flask_cors import CORS

app = Flask(__name__)
CORS(app) 

# Load the RAC model
model_paths = {
    "RAC": r"C:\Users\user\Documents\SLIIT\YEAR 4\SEM 1\Research\App\models\RAC_model.pkl",
    "DS": r"C:\Users\user\Documents\SLIIT\YEAR 4\SEM 1\Research\App\models\DS_model.pkl",
    "Letter_Jumbling": r"C:\Users\user\Documents\SLIIT\YEAR 4\SEM 1\Research\App\models\Letter_Jumbling_model.pkl",
    "Word_Jumbling": r"C:\Users\user\Documents\SLIIT\YEAR 4\SEM 1\Research\App\models\word_jumbling_model.pkl",
}

models = {}
for model_name, path in model_paths.items():
    with open(path, "rb") as f:
        models[model_name] = pickle.load(f)

@app.route('/')
def home():
    return (
        "Welcome to the Flask app! Available endpoints:\n"
        "/predict_rac - Predict using the RAC model\n"
        "/predict_ds - Predict using the DS model\n"
        "/predict_letter_jumbling - Predict using the Letter Jumbling model\n"
        "/predict_word_jumbling - Predict using the Word Jumbling model"
    )

def make_prediction(model_key, input_data):
    """
    Helper function to make a prediction using a specified model.
    """
    try:
        print(f"Received data for {model_key}: {input_data}")
        
        # Convert input JSON to a DataFrame
        input_df = pd.DataFrame([input_data])
        
        # Make a prediction using the specified model
        prediction = models[model_key].predict(input_df)
        
        # Interpret prediction result
        result = (
            "Doesn't Have Dyslexia" if prediction[0] == 0 else "Have Dyslexia"
        )
        return jsonify({'prediction': result})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/predict_rac', methods=['POST'])
def predict_rac():
    return make_prediction("RAC", request.json)

@app.route('/predict_ds', methods=['POST'])
def predict_ds():
    return make_prediction("DS", request.json)

@app.route('/predict_letter_jumbling', methods=['POST'])
def predict_letter_jumbling():
    return make_prediction("Letter_Jumbling", request.json)

@app.route('/predict_word_jumbling', methods=['POST'])
def predict_word_jumbling():
    return make_prediction("Word_Jumbling", request.json)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
