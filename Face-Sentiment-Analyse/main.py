"""
EdenMind - Face Sentiment Analysis Service
Uses FER+ ONNX model for accurate emotion detection.
"""

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import numpy as np
import cv2
import base64
import logging
import traceback
import os
import urllib.request

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="EdenMind Face Sentiment Analysis",
    description="Analyze facial emotions using FER+ AI model",
    version="2.2.0"
)

# CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Models directory
MODELS_DIR = os.path.join(os.path.dirname(__file__), "models")
os.makedirs(MODELS_DIR, exist_ok=True)

# Face detector
face_cascade = None

# ONNX model for emotion recognition
emotion_model = None

# FER+ emotion labels (in model output order)
# Order: neutral, happiness, surprise, sadness, anger, disgust, fear, contempt
FERPLUS_LABELS = ['neutral', 'happy', 'surprise', 'sad', 'angry', 'disgust', 'fear', 'contempt']

# Our emotion labels
EMOTION_LABELS = ['angry', 'disgust', 'fear', 'happy', 'sad', 'surprise', 'neutral']


def download_file(url, filepath):
    """Download a file if it doesn't exist"""
    if not os.path.exists(filepath):
        logger.info(f"Downloading {os.path.basename(filepath)}...")
        urllib.request.urlretrieve(url, filepath)
        logger.info(f"Downloaded {os.path.basename(filepath)}")
    return filepath


def get_face_detector():
    """Get OpenCV face detector"""
    global face_cascade
    if face_cascade is None:
        cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        face_cascade = cv2.CascadeClassifier(cascade_path)
        if face_cascade.empty():
            raise Exception("Failed to load face cascade classifier")
        logger.info("Face detector initialized")
    return face_cascade


def get_emotion_model():
    """Get ONNX emotion recognition model"""
    global emotion_model
    if emotion_model is None:
        import onnxruntime as ort
        
        # Download the emotion model (FER+ model from ONNX Model Zoo)
        model_url = "https://github.com/onnx/models/raw/main/validated/vision/body_analysis/emotion_ferplus/model/emotion-ferplus-8.onnx"
        model_path = os.path.join(MODELS_DIR, "emotion-ferplus-8.onnx")
        
        download_file(model_url, model_path)
        
        # Create ONNX Runtime session
        emotion_model = ort.InferenceSession(model_path, providers=['CPUExecutionProvider'])
        
        # Log model info
        input_info = emotion_model.get_inputs()[0]
        logger.info(f"Model input: {input_info.name}, shape: {input_info.shape}, type: {input_info.type}")
        
        output_info = emotion_model.get_outputs()[0]
        logger.info(f"Model output: {output_info.name}, shape: {output_info.shape}")
        
        logger.info("Emotion model loaded successfully")
    
    return emotion_model


# Emotion mapping to EdenMind mood types
EMOTION_MAPPING = {
    "angry": "Angry",
    "disgust": "Stressed",
    "fear": "Anxious",
    "happy": "Happy",
    "sad": "Sad",
    "surprise": "Excited",
    "neutral": "Neutral",
    "contempt": "Stressed"
}

# Empathetic messages for each mood
EMPATHETIC_MESSAGES = {
    "Angry": "I notice you might be feeling frustrated or upset right now. It's completely okay to feel this way. Would you like to talk about what's bothering you? I'm here to listen without judgment.",
    "Stressed": "It seems like you might be under some pressure. Remember, it's important to take things one step at a time. Would you like to try a breathing exercise or talk about what's on your mind?",
    "Anxious": "I can sense you might be feeling a bit anxious. You're not alone in this. Let's take a moment together – perhaps a calming exercise would help? Or we could talk through what's making you feel this way.",
    "Happy": "It's wonderful to see you're in good spirits! 😊 Would you like to share what's making you feel so positive today? Or perhaps continue this good energy with some mindfulness?",
    "Sad": "I notice you might be feeling a bit down. It's okay to have these feelings – they're a natural part of being human. I'm here for you. Would you like to talk about it, or shall I suggest something that might help lift your spirits?",
    "Excited": "You seem energized! That's great energy to have. Would you like to channel this into something productive, or perhaps share what's got you feeling this way?",
    "Neutral": "Hello! I'm here whenever you need to talk. How has your day been so far? Is there anything specific on your mind that you'd like to discuss?"
}


def preprocess_face_for_model(face_img):
    """
    Preprocess face image for the FER+ model.
    FER+ expects: 1x1x64x64 grayscale image, normalized
    """
    # Convert to grayscale
    if len(face_img.shape) == 3:
        gray = cv2.cvtColor(face_img, cv2.COLOR_BGR2GRAY)
    else:
        gray = face_img
    
    # Resize to 64x64
    resized = cv2.resize(gray, (64, 64), interpolation=cv2.INTER_AREA)
    
    # The model expects pixel values as float32
    # FER+ model uses raw pixel values (0-255) normalized
    normalized = resized.astype(np.float32)
    
    # Reshape for model: (1, 1, 64, 64) - batch, channel, height, width
    input_data = normalized.reshape(1, 1, 64, 64)
    
    logger.debug(f"Preprocessed face shape: {input_data.shape}, min: {input_data.min()}, max: {input_data.max()}")
    
    return input_data


def softmax(x):
    """Compute softmax values"""
    e_x = np.exp(x - np.max(x))
    return e_x / e_x.sum()


def predict_emotion(face_img):
    """Predict emotion using the ONNX model"""
    try:
        model = get_emotion_model()
        
        # Preprocess
        input_data = preprocess_face_for_model(face_img)
        
        # Get model input name
        input_name = model.get_inputs()[0].name
        
        # Run inference
        outputs = model.run(None, {input_name: input_data})
        
        # Get raw logits
        logits = outputs[0][0]
        logger.info(f"Raw model output (logits): {logits}")
        
        # Apply softmax to get probabilities
        probabilities = softmax(logits)
        logger.info(f"Probabilities after softmax: {probabilities}")
        
        # Map to emotion labels
        # FER+ order: neutral(0), happiness(1), surprise(2), sadness(3), 
        #             anger(4), disgust(5), fear(6), contempt(7)
        emotions = {}
        for i, label in enumerate(FERPLUS_LABELS):
            if i < len(probabilities):
                prob = float(probabilities[i] * 100)
                # Map to our standard labels
                if label == 'happy':
                    emotions['happy'] = prob
                elif label == 'contempt':
                    # Add contempt to neutral or stressed
                    pass
                else:
                    emotions[label] = prob
        
        # Add contempt to neutral
        if len(probabilities) > 7:
            emotions['neutral'] = emotions.get('neutral', 0) + float(probabilities[7] * 100)
        
        # Find dominant emotion
        dominant = max(emotions.keys(), key=lambda k: emotions[k])
        
        logger.info(f"Final emotions: {emotions}")
        logger.info(f"Dominant: {dominant} ({emotions[dominant]:.1f}%)")
        
        return emotions, dominant
        
    except Exception as e:
        logger.error(f"Error predicting emotion: {e}")
        logger.error(traceback.format_exc())
        return None, None


def analyze_image(img):
    """Analyze emotion from image"""
    try:
        detector = get_face_detector()
        
        logger.info(f"Analyzing image with shape: {img.shape}")
        
        # Convert to grayscale for face detection
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # Enhance contrast for better face detection
        gray = cv2.equalizeHist(gray)
        
        # Detect faces with multiple attempts
        faces = detector.detectMultiScale(
            gray,
            scaleFactor=1.1,
            minNeighbors=4,
            minSize=(50, 50),
            flags=cv2.CASCADE_SCALE_IMAGE
        )
        
        logger.info(f"Detected {len(faces)} faces")
        
        if len(faces) == 0:
            # Try with original (non-equalized) image
            gray_orig = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            faces = detector.detectMultiScale(
                gray_orig,
                scaleFactor=1.05,
                minNeighbors=3,
                minSize=(30, 30)
            )
            logger.info(f"Second attempt: {len(faces)} faces")
        
        if len(faces) == 0:
            return {
                "success": True,
                "emotion": "Neutral",
                "rawEmotion": "neutral",
                "confidence": 50.0,
                "allEmotions": {e: round(100/7, 2) for e in EMOTION_LABELS},
                "empatheticMessage": EMPATHETIC_MESSAGES["Neutral"] + "\n\n(Note: No face was detected. Please try again with a clearer photo.)",
                "faceDetected": False
            }
        
        # Get the largest face
        largest_face = max(faces, key=lambda f: f[2] * f[3])
        x, y, w, h = largest_face
        logger.info(f"Largest face: x={x}, y={y}, w={w}, h={h}")
        
        # Extract face region with some padding
        padding_ratio = 0.1
        pad_x = int(w * padding_ratio)
        pad_y = int(h * padding_ratio)
        
        x_start = max(0, x - pad_x)
        y_start = max(0, y - pad_y)
        x_end = min(img.shape[1], x + w + pad_x)
        y_end = min(img.shape[0], y + h + pad_y)
        
        face_roi = img[y_start:y_end, x_start:x_end]
        logger.info(f"Face ROI shape: {face_roi.shape}")
        
        # Predict emotion using the model
        emotions, dominant = predict_emotion(face_roi)
        
        if emotions is None:
            return {
                "success": True,
                "emotion": "Neutral",
                "rawEmotion": "neutral",
                "confidence": 50.0,
                "allEmotions": {e: 14.3 for e in EMOTION_LABELS},
                "empatheticMessage": EMPATHETIC_MESSAGES["Neutral"],
                "faceDetected": True
            }
        
        confidence = emotions.get(dominant, 50.0)
        eden_emotion = EMOTION_MAPPING.get(dominant, "Neutral")
        empathetic_message = EMPATHETIC_MESSAGES.get(eden_emotion, EMPATHETIC_MESSAGES["Neutral"])
        
        logger.info(f"Final result: {dominant} -> {eden_emotion} (confidence: {confidence:.2f}%)")
        
        return {
            "success": True,
            "emotion": eden_emotion,
            "rawEmotion": dominant,
            "confidence": round(confidence, 2),
            "allEmotions": {k: round(v, 2) for k, v in emotions.items()},
            "empatheticMessage": empathetic_message,
            "faceDetected": True
        }
        
    except Exception as e:
        logger.error(f"Error in analyze_image: {str(e)}")
        logger.error(traceback.format_exc())
        raise


@app.get("/")
async def root():
    return {"status": "healthy", "service": "EdenMind Face Sentiment Analysis", "version": "2.2.0"}


@app.get("/health")
async def health_check():
    return {"status": "ok"}


@app.post("/analyze")
async def analyze_emotion(file: UploadFile = File(...)):
    """Analyze facial emotion from an uploaded image."""
    try:
        logger.info(f"Received file: {file.filename}")
        contents = await file.read()
        logger.info(f"File size: {len(contents)} bytes")
        
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise HTTPException(status_code=400, detail="Invalid image format")
        
        result = analyze_image(img)
        return JSONResponse(content=result)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error analyzing emotion: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@app.post("/analyze-base64")
async def analyze_emotion_base64(data: dict):
    """Analyze facial emotion from a base64 encoded image."""
    try:
        image_data = data.get('image')
        if not image_data:
            raise HTTPException(status_code=400, detail="No image data provided")
        
        logger.info(f"Received base64 image, length: {len(image_data)}")
        
        if ',' in image_data:
            image_data = image_data.split(',')[1]
        
        try:
            image_bytes = base64.b64decode(image_data)
            logger.info(f"Decoded image size: {len(image_bytes)} bytes")
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Invalid base64: {str(e)}")
        
        nparr = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise HTTPException(status_code=400, detail="Invalid image format")
        
        logger.info(f"Decoded image shape: {img.shape}")
        
        result = analyze_image(img)
        return JSONResponse(content=result)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    
    # Pre-load models at startup
    logger.info("="*50)
    logger.info("EdenMind Face Sentiment Analysis Service v2.2.0")
    logger.info("="*50)
    logger.info("Initializing models...")
    
    try:
        get_face_detector()
        logger.info("✓ Face detector ready!")
        
        logger.info("Loading emotion model (downloading if needed)...")
        get_emotion_model()
        logger.info("✓ Emotion model ready!")
        
        logger.info("="*50)
        logger.info("All models loaded successfully!")
        logger.info("="*50)
    except Exception as e:
        logger.error(f"Failed to initialize: {e}")
        logger.error(traceback.format_exc())
    
    uvicorn.run(app, host="0.0.0.0", port=9000)
