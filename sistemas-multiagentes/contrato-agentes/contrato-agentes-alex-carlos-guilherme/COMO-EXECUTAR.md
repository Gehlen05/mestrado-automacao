# Contrato de agentes — Alex, Carlos e Guilherme

Trabalho de disciplina de mestrado que implementa o Contract Net Protocol (CNP)
em Jason e permite avaliar sua escalabilidade.

Na pasta deste projeto, execute:

```bash
docker compose up --build
```

O primeiro uso baixa as imagens e as dependencias. Nas proximas execucoes, basta:

```bash
docker compose up
```

Para interromper os agentes, pressione `Ctrl+C`. Para remover o container criado:

```bash
docker compose down
```

O volume `gradle-cache` preserva apenas o cache de dependencias do Gradle entre
execucoes. Java, Gradle e Jason permanecem isolados no Docker.

## Configuracao padrao

A execucao padrao usa `n=2` iniciadores, `m=6` participantes e `i=3`
servicos simultaneos por iniciador. Para escolher outros valores:

```bash
docker compose run --rm simulacao gradle run -Pheadless -Pn=10 -Pm=25 -Pi=5 --no-daemon --console=plain
```

As restricoes do enunciado sao verificadas automaticamente:

- `1 < n < 200`;
- `1 < m < 50`;
- `0 < i < 10`.

## Agentes e estrategias

- `contratante`: inicia `i` CNPs paralelos e seleciona o menor preco dentro do
  orcamento;
- `vendedor_botao`: vende somente botoes, com preco aleatorio;
- `vendedor_linha`: vende somente linhas, com preco que cresce conforme a
  demanda recebida;
- `vendedor_ziper`: vende somente ziperes, usando uma estrategia economica;
- `monitor`: encerra o experimento quando todos os iniciadores terminam.

O Gradle distribui os `m` participantes da forma mais uniforme possivel entre
os tres tipos de vendedor.

## Metricas

Ao fim de cada execucao, uma linha e acrescentada a `resultados/metricas.csv`.
Sao registrados `n`, `m`, `i`, total de CNPs, sucessos, falhas, mensagens,
propostas, recusas, tempo total e preco medio.

## Bateria de experimentos

Depois de construir a imagem, execute:

```bash
docker compose build
./executar-experimentos.sh
```

O script varia um parametro por vez:

- `n`: 2, 10, 50, 100 e 199;
- `m`: 2, 10, 25 e 49;
- `i`: 1, 3, 5 e 9.

Para obter medias mais confiaveis, execute o script varias vezes e analise as
linhas acumuladas no CSV.
