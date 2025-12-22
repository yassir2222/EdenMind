# Face Sentiment Analysis Service

This service provides real-time facial emotion detection for the EdenMind mental health application.

## 🎯 Features

- **Real-time Emotion Detection**: Analyzes facial expressions using DeepFace
- **7 Emotion Categories**: Happy, Sad, Angry, Anxious, Stressed, Excited, Neutral
- **Empathetic Response Generation**: Provides mood-appropriate chatbot messages
- **Privacy-First**: No images are stored - only emotion data is processed

## 🛠 Technology Stack

- **Framework**: FastAPI (Python)
- **AI Model**: DeepFace with OpenCV
- **Image Processing**: OpenCV, Pillow, NumPy

## 📋 Prerequisites

- Python 3.10+
- pip

## 🚀 Running Locally

### Option 1: Direct Python

```bash
# Navigate to this directory
cd Face-Sentiment-Analyse

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the service
python main.py
```

The service will be available at `http://localhost:8000`

### Option 2: Docker

```bash
# Build the image
docker build -t edenmind-face-sentiment .

# Run the container
docker run -p 8000:8000 edenmind-face-sentiment
```

## 📡 API Endpoints

### Health Check
```
GET /health
```

### Analyze Emotion (File Upload)
```
POST /analyze
Content-Type: multipart/form-data
Body: file=<image_file>
```

### Analyze Emotion (Base64)
```
POST /analyze-base64
Content-Type: application/json
Body: {
    "image": "<base64_encoded_image>"
}
```

### Response Format
```json
{
    "success": true,
    "emotion": "Happy",
    "rawEmotion": "happy",
    "confidence": 85.5,
    "allEmotions": {
        "happy": 85.5,
        "sad": 2.1,
        "angry": 1.2,
        "neutral": 8.3,
        "fear": 0.5,
        "surprise": 1.9,
        "disgust": 0.5
    },
    "empatheticMessage": "It's wonderful to see you're in good spirits!..."
}
```

## 🔗 Integration with EdenMind

1. **Flutter App** → Captures image via camera
2. **Face Sentiment Service** → Analyzes emotion
3. **Flutter App** → Saves mood to Spring Boot backend
4. **Spring Boot** → Updates user context for chatbot
5. **Chatbot** → Provides empathetic, mood-aware responses

## 📝 Emotion Mapping

| DeepFace Emotion | EdenMind Mood |
|-----------------|---------------|
| happy | Happy |
| sad | Sad |
| angry | Angry |
| fear | Anxious |
| disgust | Stressed |
| surprise | Excited |
| neutral | Neutral |
