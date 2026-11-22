# ==========================================
# ЭТАП 1: Сборка кастомного JRE через jlink
# ==========================================
FROM eclipse-temurin:25-jdk-jammy AS jre-build

WORKDIR /build
COPY target/sentiment-app-0.0.1-SNAPSHOT.jar app.jar

RUN jdeps --multi-release 25 --print-module-deps --ignore-missing-deps app.jar > modules.txt && \
    jlink --add-modules $(cat modules.txt),java.desktop,java.naming,java.management,java.instrument,jdk.unsupported,java.security.jgss,java.net.http,java.sql \
          --strip-debug \
          --no-man-pages \
          --no-header-files \
          --compress=2 \
          --output /custom-jre

# ==========================================
# ЭТАП 2: Финальный образ на чистом Ubuntu
# ==========================================
FROM ubuntu:jammy

# Устанавливаем только необходимые системные библиотеки для ONNX Runtime
# libstdc++6 — стандартная библиотека C++
# libgomp1 — библиотека OpenMP (часто требуется ONNX)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Копируем кастомный JRE
COPY --from=jre-build /custom-jre /opt/jre

WORKDIR /app
COPY target/sentiment-app-0.0.1-SNAPSHOT.jar app.jar

ENV INFERENCE4J_CACHE_DIR=/app/model-cache
EXPOSE 8080

ENTRYPOINT ["/opt/jre/bin/java", "--enable-native-access=ALL-UNNAMED", "-jar", "app.jar"]