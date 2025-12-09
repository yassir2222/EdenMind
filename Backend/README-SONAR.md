# Local SonarQube Integration

This guide explains how to run a local SonarQube server and perform code analysis for the EdenMind project.

## Prerequisites

- Docker Desktop installed and running.
- Java 17+ installed.
- Maven installed (or use the wrapper `mvnw`).

## 1. Start SonarQube Server

Run the following command in the `Backend` directory (where `docker-compose.yml` is located):

```bash
docker-compose up -d
```

Wait a minute for the server to start. You can check the logs with `docker-compose logs -f sonarqube`.

Access the dashboard at: [http://localhost:9000](http://localhost:9000)
- **Login**: `admin`
- **Password**: `admin` (You will be prompted to change it on first login).

## 2. Analyze Backend (Spring Boot)

Run the Maven command to build and analyze:

```bash
./mvnw clean verify sonar:sonar -Dsonar.login=admin -Dsonar.password=admin
```

> **Note**: If you changed the password, update `-Dsonar.password` accordingly. Alternatively, generate a token in SonarQube (User > My Account > Security) and use `-Dsonar.token=YOUR_TOKEN` instead of login/password.

## 3. Analyze Frontend (Flutter)

Ensure you have the `sonar-scanner` CLI installed or use a Docker container for the scanner.

If you have `sonar-scanner` installed locally path, run this in `app-v2/eden_mind_app`:

```bash
sonar-scanner \
  -Dsonar.projectKey=eden-mind-flutter \
  -Dsonar.sources=lib \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=admin \
  -Dsonar.password=admin
```

## 4. Stop Server

To stop the SonarQube server and free up resources:

```bash
docker-compose down
```
