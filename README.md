# ServiceDiscoveryApplication

Eureka server for the scaler-project workspace. Every other service registers with it and finds its peers by name
(`user-auth-service`, `product-catalog-service`, `cart-service`, ...), so start it first.

Spring Boot 3.5, Java 17, Spring Cloud Netflix Eureka Server. It listens on `8761` and does not register with itself
(`register-with-eureka=false`, `fetch-registry=false`). The dashboard is at <http://localhost:8761>, the registry
as JSON at `http://localhost:8761/eureka/apps` (send `Accept: application/json`), and health at `/actuator/health`.

## Run

| How | Command |
|---|---|
| Whole stack (monorepo root) | `make up` starts it with the other services; `make status` lists what registered |
| This service only | `make up` (or `make run`), foreground on `:8761` |
| As a container | `make docker-up`, stopped by `make docker-down` |
| Maven | `./mvnw spring-boot:run` |

`make help` lists the rest (`jar`, `test`, `clean`). Registered instances show up on the dashboard within about 30 seconds.

### Run in Docker

The `Dockerfile` (multi-stage: JDK build, JRE runtime, non-root, health check on `/actuator/health`) builds only
this service. The registry needs no database or broker, so there is nothing else to point it at:

```bash
docker build -t service-discovery .
docker run --rm -p 8761:8761 service-discovery
```

Services running on the host register at `http://localhost:8761/eureka/` as usual. Services in other containers use
`host.docker.internal:8761` (their `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE`). The root Makefile starts Eureka as a jar
on the same port, so run one or the other.

## Configuration

| Variable | Default | Meaning |
|---|---|---|
| `SERVER_PORT` | `8761` | HTTP port. The services look for the registry on 8761, so change it only together with them. |

`make run` and `./mvnw spring-boot:run` also read a gitignored `.env` (template `.env.example`, unquoted values).
`.env` is excluded from the Docker image (`.dockerignore`).
