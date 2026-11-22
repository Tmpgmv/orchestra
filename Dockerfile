FROM eclipse-temurin:25-jre

WORKDIR /app

# Копируем собранный JAR
COPY target/sentiment-app-0.0.1-SNAPSHOT.jar app.jar

# Указываем Inference4j использовать этот путь для кэша моделей
ENV INFERENCE4J_CACHE_DIR=/app/model-cache

EXPOSE 8080

ENTRYPOINT ["java", "--enable-native-access=ALL-UNNAMED", "-jar", "app.jar"]