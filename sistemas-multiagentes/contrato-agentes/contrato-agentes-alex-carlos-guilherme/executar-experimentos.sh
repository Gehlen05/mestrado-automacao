#!/usr/bin/env bash
set -euo pipefail

# Varia um parametro por vez e mantem os outros em uma configuracao de base.
for n in 2 10 50 100 199; do
  docker compose run --rm simulacao gradle run -Pheadless -Pn="$n" -Pm=10 -Pi=3 --no-daemon --console=plain
done

for m in 2 10 25 49; do
  docker compose run --rm simulacao gradle run -Pheadless -Pn=10 -Pm="$m" -Pi=3 --no-daemon --console=plain
done

for i in 1 3 5 9; do
  docker compose run --rm simulacao gradle run -Pheadless -Pn=10 -Pm=10 -Pi="$i" --no-daemon --console=plain
done

echo "Experimentos concluidos. Resultados em resultados/metricas.csv"
