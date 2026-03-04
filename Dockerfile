# Create a stage for resolving and downloading dependencies.
FROM maven:3-eclipse-temurin-17 AS deps

WORKDIR /build

# Arguments maven: Produce exécution errors.
ENV MAVEN_ARGS=" --errors"

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.m2 so that subsequent builds don't have to
# re-download packages.
RUN --mount=type=bind,source=pom.xml,target=pom.xml \
    --mount=type=cache,target=/root/.m2 \
		mvn $MAVEN_ARGS dependency:go-offline -DskipTests

#
# Create a stage for building the application based on the stage with downloaded dependencies.
#
FROM deps AS package

WORKDIR /build

COPY . .

# Arguments maven: Produce exécution errors.
ENV MAVEN_ARGS="--errors"

RUN --mount=type=cache,target=/root/.m2 \
		mvn $MVN_OPTS $MAVEN_ARGS -U clean package
#
# Create a new stage for running the application that contains the minimal
# runtime dependencies for the application.

FROM eclipse-temurin:17-jre-jammy AS final

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    demouser

USER demouser

WORKDIR /apps/demo

# Modele de configuration pour la production
COPY --chown=demouser:demouser application.properties ./config/application.properties

COPY --chown=demouser:demouser --from=package /build/target/*-SNAPSHOT.jar ./app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"," --spring.config.location=config/application.properties"]
