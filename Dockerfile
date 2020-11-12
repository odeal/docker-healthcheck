FROM maven:3-jdk-8 AS BUILDER
COPY src /tmp/app/src
COPY pom.xml /tmp/app
RUN mvn -f /tmp/app/pom.xml clean package

FROM openjdk:8-jre-alpine

RUN apk add --update curl tzdata && \
    cp /usr/share/zoneinfo/Europe/Istanbul /etc/localtime && \
    echo "Europe/Istanbul" > /etc/timezone && \
    apk del tzdata

COPY --from=BUILDER /tmp/app/target/*.jar /opt/odeal/healthcheck.jar
ENTRYPOINT ["java", "-jar", "/opt/odeal/healthcheck.jar"]
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s CMD curl --fail http://localhost:${bamboo_server_port}/actuator/health || exit 1
EXPOSE 8080