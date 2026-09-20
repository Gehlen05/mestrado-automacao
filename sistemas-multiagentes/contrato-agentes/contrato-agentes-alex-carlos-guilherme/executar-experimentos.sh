#!/usr/bin/env bash
set -euo pipefail

REPETICOES=10

# Varia n
for n in 2 10 50 100 199; do
  for rep in $(seq 1 "$REPETICOES"); do
    echo "Executando n=$n, m=10, i=3 | repeticao $rep/$REPETICOES"

    docker compose run --rm simulacao \
      gradle run \
      -Pheadless \
      -Pn="$n" \
      -Pm=10 \
      -Pi=3 \
      -Prep="$rep" \
      --no-daemon \
      --console=plain
  done
done

# Varia m
for m in 2 10 25 49; do
  for rep in $(seq 1 "$REPETICOES"); do
    echo "Executando n=10, m=$m, i=3 | repeticao $rep/$REPETICOES"

    docker compose run --rm simulacao \
      gradle run \
      -Pheadless \
      -Pn=10 \
      -Pm="$m" \
      -Pi=3 \
      -Prep="$rep" \
      --no-daemon \
      --console=plain
  done
done

# Varia i
for i in 1 3 5 9; do
  for rep in $(seq 1 "$REPETICOES"); do
    echo "Executando n=10, m=10, i=$i | repeticao $rep/$REPETICOES"

    docker compose run --rm simulacao \
      gradle run \
      -Pheadless \
      -Pn=10 \
      -Pm=10 \
      -Pi="$i" \
      -Prep="$rep" \
      --no-daemon \
      --console=plain
  done
done

echo "Experimentos concluidos."
echo "Cada configuracao foi executada $REPETICOES vezes."
echo "Resultados em resultados/metricas.csv"