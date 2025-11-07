# Etapa 1: build (usa imagem com Maven + Java)
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

# copia só o pom primeiro pra aproveitar cache
COPY pom.xml .
# baixa dependências
RUN mvn -B dependency:go-offline

# agora copia o código
COPY src ./src

# builda o projeto (sem testes pra ficar mais rápido)
RUN mvn -B -DskipTests clean package

# Etapa 2: runtime (imagem menor só com Java)
FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app

# copia o que o Quarkus gera na pasta target/quarkus-app
COPY --from=build /app/target/quarkus-app/ /app/

# Railway costuma setar PORT, então já deixa exposto
ENV PORT=8080
EXPOSE 8080

# executa o quarkus-run.jar
CMD ["java", "-jar", "quarkus-run.jar"]
