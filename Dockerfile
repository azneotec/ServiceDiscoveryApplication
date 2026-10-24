# Builds and runs only the Eureka server (ServiceDiscoveryApplication). It needs no database or broker.
#
#   docker build -t service-discovery .
#   docker run --rm -p 8761:8761 service-discovery

# --- build stage: compile the jar; dependencies are cached in their own layer, so a source-only change is fast
FROM eclipse-temurin:17-jdk AS build
WORKDIR /build
COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN ./mvnw -q -B dependency:go-offline
COPY src src
RUN ./mvnw -q -B package -DskipTests

# --- runtime stage: JRE only, non-root
FROM eclipse-temurin:17-jre
RUN groupadd --system app && useradd --system --gid app --no-create-home app
WORKDIR /app
COPY --from=build /build/target/ServiceDiscoveryApplication-0.0.1-SNAPSHOT.jar app.jar
USER app

# Everything is configured through environment variables; the registry has no addresses of its own to override.
#   SERVER_PORT                                       default 8761 (change EXPOSE and the port mapping with it)
# Clients reach it at http://<host>:8761/eureka/; from another container use the container's name or
# host.docker.internal when the port is published on the host.
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75"
EXPOSE 8761

HEALTHCHECK --interval=15s --timeout=3s --start-period=60s --retries=5 \
  CMD curl -fs http://localhost:${SERVER_PORT:-8761}/actuator/health | grep -q '"UP"' || exit 1

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]
