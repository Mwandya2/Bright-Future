# ── Build ───────────────────────────────────────────────────────
# Maven and a JDK are only needed to compile; they are thrown away
# so the deployed image stays small.
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build

# Dependencies first: this layer is cached and only re-downloads when
# pom.xml actually changes, which makes redeploys much faster.
COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src
RUN mvn -B clean package -DskipTests

# ── Run ─────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jre
WORKDIR /app

# Never run as root in a container.
RUN useradd -r -u 1001 brightfuture
USER brightfuture

COPY --from=build /build/target/*.jar app.jar

# Render provides PORT; Spring reads it via SERVER_PORT in render.yaml.
EXPOSE 8080

# Container-aware heap sizing: the JVM otherwise assumes it can use the
# whole host's memory and gets OOM-killed on a small instance.
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75 -XX:+UseSerialGC"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
