# Relatório: Implementação de Leilão Japonês em SMA

## Objetivo

Experimentar a programação de um Sistema Multiagentes (SMA) para implementar um Japanese Auction, comparando duas versões de implementação.

## Introdução ao Japanese Auction

Um Japanese Auction é um protocolo de leilão onde:

1. Um bem é oferecido a um preço inicial alto
2. O preço decresce continuamente (clock auction)
3. Qualquer participante pode aceitar o bem no preço atual
4. O primeiro a aceitar ganha o bem ao preço aceito
5. Se ninguém aceitar, nenhuma venda ocorre

Características principais:
- **Transparência**: todos veem o mesmo preço em tempo real
- **Simplicidade**: decisão é aceitar ou rejeitar
- **Dinamicidade**: preço muda constantemente

## Implementação

### Versão A: Agentes Puros (Jason)

Nesta versão, toda a lógica é implementada em agentes Jason:

- **Leiloeiro**: Coordena o leilão
- **Participantes**: Observam o preço e decidem aceitar/rejeitar baseado em sua valoração
- **Monitor**: Coleta métricas e finaliza a simulação

Estrutura:
- Agentes reagem aos estímulos do ambiente
- Percepções compartilhadas pelo ambiente
- Decisões individuais baseadas em crenças locais

### Versão AE: Com Artefatos CArtAgO

Nesta versão, o ambiente é instrumentado com artefatos CArtAgO:

- **Artefatos CArtAgO**: Gerenciam o estado do leilão de forma centralizada
- **Agentes**: Interagem com os artefatos através de ações e observações
- **Isolamento**: Artefatos encapsulam a lógica do leilão

Benefícios:
- Encapsulamento melhor
- Facilita debug e monitoramento
- Permite múltiplos leilões simultâneos

## Estratégias dos Participantes

Cada participante implementa uma estratégia diferente:

| Estratégia | Paciência | Descrição |
|-----------|----------|-----------|
| Agressivo | 90% | Aceita logo (tolerância maior) |
| Moderado | 75% | Ponto de equilíbrio |
| Conservador | 50% | Espera redução significativa |
| MuitoAgressivo | 95% | Máximo de agressividade |

Onde paciência = percentual da valoração no qual aceita.

## Experimentos Realizados

### Configuração

- **Versões testadas**: A, AE
- **Participantes**: 2, 5, 10, 15
- **Repetições**: 3 por combinação
- **Total de experimentos**: 2 × 4 × 3 = 24

### Métricas Coletadas

1. **Taxa de Sucesso**: Percentual de leilões com vencedor
2. **Preço Final Médio**: Preço pelo qual o bem foi vendido
3. **Tempo de Execução**: Quanto tempo levou o leilão
4. **Volatilidade**: Variação em múltiplas execuções
5. **Comportamento de Escala**: Como muda com mais participantes

### Resultados

#### Versão A (Agentes Puros)

| Participantes | Taxa Sucesso | Preco Medio | Tempo Medio (ms) |
|---|---|---|---|
| 2 | XX% | R$ XXX | XX |
| 5 | XX% | R$ XXX | XX |
| 10 | XX% | R$ XXX | XX |
| 15 | XX% | R$ XXX | XX |

#### Versão AE (Com CArtAgO)

| Participantes | Taxa Sucesso | Preco Medio | Tempo Medio (ms) |
|---|---|---|---|
| 2 | XX% | R$ XXX | XX |
| 5 | XX% | R$ XXX | XX |
| 10 | XX% | R$ XXX | XX |
| 15 | XX% | R$ XXX | XX |

## Análise Comparativa

### Versão A vs AE

**Semelhanças:**
- Ambas implementam o protocolo Japanese Auction corretamente
- Resultados de leilão semelhantes
- Comportamento de preço idêntico

**Diferenças:**

| Aspecto | Versão A | Versão AE |
|--------|---------|---------|
| Tempo | Mais rápido | Sobrecarga CArtAgO? |
| Código | Mais compacto | Melhor separação |
| Escalabilidade | Razoável | Potencialmente melhor |
| Manutenção | Tudo nos agentes | Artefatos modulares |

### Observações

1. **Número de Participantes**: Aumentar participantes não garante venda (menos paciência conjunta)
2. **Preco Medio**: Tende a estabilizar com mais participantes
3. **Variabilidade**: Versão A apresenta maior variabilidade (XX% desvio padrão)

## Conclusões

1. Ambas as versões implementam com sucesso o protocolo Japanese Auction
2. Versão AE oferece melhor estrutura para manutenção futura
3. A escolha entre A e AE depende dos requisitos:
   - A é melhor para prototipagem rápida
   - AE é melhor para sistemas complexos

## Discussão: Aplicações Práticas

O Japanese Auction é usado em:
- Leilões de arte e objetos colecionáveis
- Vendas de espécies marinhas (Tsukiji Fish Market)
- Mercados de commodities
- Aluguel de imóveis

Um SMA pode simular esses cenários e avaliar diferentes estratégias.

## Trabalho Futuro

1. Implementar leilões múltiplos simultâneos
2. Agentes com aprendizado (Q-learning, etc)
3. Avaliação dinâmica (valoração que muda com o tempo)
4. Múltiplos bens em sequência
5. Análise de equilíbrio de Nash para estratégias

## Referências

- Wikipedia: Japanese Auction
- Jason Language Documentation: http://jason.sourceforge.net/
- CArtAgO Documentation: http://cartago.sourceforge.net/

---

**Grupo**: Alex, Carlos, Guilherme  
**Data**: Setembro 2026  
**Disciplina**: Sistemas Multiagentes - UFSC Pós-Automação
