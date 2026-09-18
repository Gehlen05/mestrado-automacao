FROM gradle:8.10-jdk21

WORKDIR /app

RUN chown gradle:gradle /app

# Mantem os arquivos pertencendo ao usuario nao privilegiado da imagem.
COPY --chown=gradle:gradle . .

USER gradle

CMD ["gradle", "run", "-Pheadless", "--no-daemon", "--console=plain"]
