# ==============================================================================
# Rehearsal Backend Dockerfile
# Optimized multi-stage build for free cloud hosting (Render, Koyeb, Railway)
# Lightweight memory footprint (< 400MB) using Eclipse Temurin 21 JRE & SerialGC
# ==============================================================================

# Stage 1: Build Jar
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app

# Copy gradle wrapper and dependency descriptors first to leverage Docker layer caching
COPY gradlew .
COPY gradle/ gradle/
COPY build.gradle settings.gradle ./

# Fix line endings and permissions on gradlew
RUN tr -d '\r' < gradlew > gradlew_unix && mv gradlew_unix gradlew && chmod +x gradlew

# Download dependencies
RUN ./gradlew dependencies --no-daemon || true

# Copy source code and build executable jar
COPY src/ src/
RUN ./gradlew bootJar -x test --no-daemon

# Stage 2: Ultra-Lightweight Production Runtime
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Create non-root user for security
RUN addgroup -S rehearsal && adduser -S rehearsal -G rehearsal
USER rehearsal

# Copy fat jar from builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

# Cloud providers dynamically provide $PORT (defaults to 8080)
ENV PORT=8080
EXPOSE 8080

# Tune JVM for free tier containers (512MB RAM limit):
# - SerialGC uses significantly less native memory overhead than G1GC
# - -Xmx384m sets max heap to 384MB, leaving plenty of room for JVM metaspace and Alpine OS
ENTRYPOINT ["java", "-XX:+UseSerialGC", "-Xmx384m", "-Xms128m", "-Dserver.port=${PORT}", "-jar", "app.jar"]
