# Execução — Alex, Carlos e Guilherme

Na pasta `leilao-japones`:

```bash
docker compose build
# Somente agentes Jason
docker compose run --rm simulacao gradle run -Pversao=a -Pm=5 --console=plain
# Agentes Jason e artefato CArtAgO
docker compose run --rm simulacao gradle run -Pversao=ae -Pm=5 --console=plain
# Testes dos protocolos e equivalência
./executar-experimentos.sh --validar
# Bateria com 24 simulações e exportação CSV
./executar-experimentos.sh
```

Parâmetros: `-Pm=1..100`, `-Pversao=a|ae`, `-Pinicio=100`, `-Ppasso=50` e
`-Pvalores=450,520,590,660,730` (exatamente um valor por participante).
Sem `valores`, usa-se `450 + 70*i`, com `i` começando em zero.
O parâmetro legado `-Pheadless` é desnecessário: a execução já ocorre sem GUI.

Os resultados são armazenados em subpastas datadas de `resultados/`, no computador
anfitrião. Os fontes são montados no container; alterações de agentes não exigem
reconstruir a imagem. Não execute baterias simultâneas no mesmo diretório.

Consulte [README.md](README.md) para as regras, convenção de empate, arquiteturas
e interpretação das métricas. Nenhum relatório acadêmico é produzido pelos scripts.
