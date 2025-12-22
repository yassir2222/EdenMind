# EdenMind

EdenMind is a comprehensive mental health application designed to help users manage their well-being through therapy, meditation, mood tracking, and relaxation games.

## 🌟 Features

-   **Authentication**: Secure login and signup powered by Spring Security and JWT.
-   **Mood Log**: Track daily emotions and visualize mood trends over time.
-   **🆕 Face Sentiment Analysis**: AI-powered facial emotion detection via camera to automatically detect and log your mood, enabling personalized chatbot conversations.
-   **AI Chatbot**: A therapeutic chatbot powered by RAG (Retrieval-Augmented Generation) to provide supportive conversations using LangChain4j and OpenAI. Now with mood-aware responses!
-   **Meditation**: Guided meditation sessions with timers and playback controls.
-   **Relaxation Games**:
    -   *Breathing Game*: Guided breathing exercises for stress relief.
    -   *Distortion Hunter*: A game to identify and challenge cognitive distortions.
-   **Music**: A calm music player for relaxation.
-   **Profile**: User profile management.

## 🛠 Technology Stack

### Frontend (Mobile App)
-   **Framework**: [Flutter](https://flutter.dev/)
-   **Language**: Dart
-   **Key Libraries**: `provider` (State Management), `flutter_animate`, `just_audio` (Music), `fl_chart` (Charts).

### Backend (API)
-   **Framework**: [Spring Boot](https://spring.io/projects/spring-boot) (Java 17)
-   **AI/LLM**: [LangChain4j](https://github.com/langchain4j/langchain4j)
-   **Security**: Spring Security, JWT (JSON Web Tokens).
-   **Database**: MySQL & PostgreSQL (for SonarQube).
-   **Tools**: Maven, Lombok.

### Infrastructure & Tools
-   **Containerization**: Docker & Docker Compose.

-   **Code Quality**: SonarQube.

## 🚀 Getting Started

### Prerequisites
-   [Docker Desktop](https://www.docker.com/products/docker-desktop)
-   [Java 17 JDK](https://adoptium.net/)
-   [Flutter SDK](https://docs.flutter.dev/get-started/install)

### 1. Backend Setup

1.  **Start Infrastructure**:
    Navigate to the root directory (or `Backend` if strictly regarding backend services) and start the Database:
    ```bash
    docker-compose up -d
    ```
    *(Note: Ensure you have the correct `docker-compose.yml` for MySQL/PostgreSQL. If the database is running locally or elsewhere, update `application.properties` accordingly.)*

2.  **Run Spring Boot App**:
    Navigate to the `Backend` folder:
    ```bash
    ./mvnw spring-boot:run
    ```

### 2. Face Sentiment Service Setup (Optional)

1.  **Navigate to the Face-Sentiment-Analyse folder**:
    ```bash
    cd Face-Sentiment-Analyse
    ```

2.  **Create and activate virtual environment**:
    ```bash
    python -m venv venv
    # Windows:
    .\venv\Scripts\activate
    # Linux/Mac:
    source venv/bin/activate
    ```

3.  **Install dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

4.  **Run the service**:
    ```bash
    python main.py
    ```
    The service will be available at `http://localhost:8000`

### 3. Frontend Setup

1.  **Install Dependencies**:
    Navigate to the `app-v2/eden_mind_app` folder:
    ```bash
    flutter pub get
    ```

2.  **Run the App**:
    Ensure an emulator or device is connected:
    ```bash
    flutter run
    ```

## 📂 Project Structure

-   `app-v2/eden_mind_app`: The Flutter mobile application source code.
    -   `lib/features`: Contains feature-specific code (auth, games, music, face_sentiment, etc.).
-   `Backend`: The Spring Boot backend source code.
    -   `src/main/java`: Java source files (Controllers, Services, Entities).
    -   `src/main/resources`: Configuration files and RAG documents.
-   `Face-Sentiment-Analyse`: Python FastAPI service for facial emotion detection.
    -   Uses DeepFace for AI-powered emotion recognition.

## 🎯 Face Sentiment Analysis Flow

```
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│   Flutter App   │────▶│  Face Sentiment API  │────▶│  Emotion Result │
│  (Camera Input) │     │   (Python/FastAPI)   │     │   + Message     │
└─────────────────┘     └──────────────────────┘     └────────┬────────┘
                                                              │
                        ┌──────────────────────┐              │
                        │   Spring Boot API    │◀─────────────┘
                        │   (Save Mood Log)    │
                        └──────────┬───────────┘
                                   │
                        ┌──────────▼───────────┐
                        │   AI Chatbot (RAG)   │
                        │ Mood-Aware Response  │
                        └──────────────────────┘
```
