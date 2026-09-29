FROM eclipse-temurin:21-jdk

WORKDIR /app

RUN apt-get update && apt-get install -y wget unzip python3 && rm -rf /var/lib/apt/lists/*

RUN wget https://services.gradle.org/distributions/gradle-8.10-bin.zip && \
    unzip gradle-8.10-bin.zip && \
    mv gradle-8.10 /opt/gradle && \
    rm gradle-8.10-bin.zip

ENV PATH="/opt/gradle/bin:${PATH}"

COPY . .

CMD ["gradle", "run", "-Pheadless"]
