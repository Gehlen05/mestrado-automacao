# Leilão Japonês — Trabalho Prático de Sistemas Multiagentes

Implementações em Jason (A) e Jason + CArtAgO (AE), com JaCaMo 1.3.0 e Java 21.

## Regras

O preço parte de 100 e sobe em passos de 50, configuráveis. Cada participante
permanece enquanto o preço é menor que sua valoração e desiste ao atingir esse
valor. Quem saiu não volta. Após as decisões da rodada, o único restante compra
pelo preço exibido. O preço só avança quando todos os ativos responderam.

Usamos rodadas discretas, sem intervalo fixo de relógio. Se todos desistirem na
mesma rodada (empate ou incremento grande), o leilão termina sem venda. Essa é
uma convenção explícita para o caso limite da discretização; não há desempate
pela velocidade dos agentes. Com um único interessado inicial, ele vence no
preço inicial. A entrada de novos participantes após o início não é permitida.

Referência: https://en.wikipedia.org/wiki/Japanese_auction

## Arquiteturas

- **A:** somente agentes programados em Jason. `leiloeiro.asl` mantém a lista
  dos ativos, consulta cada um por `askOne`, remove desistentes, aumenta o preço
  e comunica o resultado ao monitor. `participante.asl` decide pela valoração.
  Não usa ambiente Java personalizado nem artefato.
- **AE:** `ambiente.Leilao` é um artefato CArtAgO real. Controla inscrições,
  rodadas, respostas únicas, exclusão definitiva e resultado. Os participantes
  observam `rodada` e executam `responder`; o artefato usa a identidade de quem
  chamou a operação. O leiloeiro acompanha o preço e o monitor observa o resultado.
  O início aguarda todos os participantes e o monitor estarem prontos.

As duas versões recebem as mesmas valorações e aplicam a mesma estratégia.
O padrão é `450,520,590,660,730`; não se usam mais os fatores de paciência do
protótipo de preço decrescente. A quantidade pode variar de 1 a 100.

## Executar

```bash
docker compose build
docker compose run --rm simulacao gradle run -Pversao=a --console=plain
docker compose run --rm simulacao gradle run -Pversao=ae --console=plain
```

Exemplo com valores explícitos:

```bash
docker compose run --rm simulacao gradle run -Pversao=ae -Pm=3 -Pvalores=100,200,350 -Pinicio=100 -Ppasso=50 --console=plain
```

Também é possível usar `gradle run` localmente com Java 21, Gradle 8.10 e Python 3.
O Gradle gera a configuração em `build/generated` a cada execução. Execute uma
simulação por vez no mesmo diretório, pois esses arquivos são compartilhados.
`leilao-japones.mas2j` permite iniciar diretamente a versão A padrão no Jason.

## Validação e dados brutos

```bash
./executar-experimentos.sh --validar
./executar-experimentos.sh
```

A validação executa oito cenários em ambas as versões, incluindo venda normal,
um participante, ausência de interessados, empate, desistência definitiva,
incremento grande, preço zero e 100 participantes. Confere os resultados esperados,
as decisões, a ausência de reentrada e a equivalência entre A e AE.

A bateria padrão executa A e AE com 2, 5, 10 e 15 participantes, três vezes cada
(24 execuções). Use `--repeticoes N` para mudar. Cada execução tem limite de 45 s;
falhas e ausência de resultado são registradas como erro, nunca como sucesso.

Cada bateria cria uma pasta datada em `resultados/`, com logs completos e
`metricas.csv`: cenário, versão, quantidade, repetição, status, vencedor, preço,
rodadas, decisões, tempo de processo, valorações, preço inicial e incremento.
`tempo_processo_ms` inclui a inicialização e o encerramento da JVM/SMA, mas não
compilação nem download de dependências. Não equivale à duração exclusiva do leilão.
A contagem de decisões não é uma contagem de mensagens: A usa comunicação entre
agentes; AE usa operações e propriedades observáveis.

Esses arquivos são dados brutos para análise. O relatório acadêmico não é gerado.
O arquivo `RELATORIO-TEMPLATE.md` é um modelo anterior, preservado sem atualização;
suas afirmações não devem ser tratadas como resultados da implementação atual.
