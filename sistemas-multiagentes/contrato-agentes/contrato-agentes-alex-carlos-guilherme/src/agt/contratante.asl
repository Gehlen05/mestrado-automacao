// Cada instancia executa i protocolos CNP em paralelo.
orcamento_maximo(botao, 500).
orcamento_maximo(linha, 350).
orcamento_maximo(ziper, 700).

// Lista ciclica para permitir de um a nove contratos simultaneos.
tipo_servico(1, botao).
tipo_servico(2, linha).
tipo_servico(3, ziper).
tipo_servico(4, botao).
tipo_servico(5, linha).
tipo_servico(6, ziper).
tipo_servico(7, botao).
tipo_servico(8, linha).
tipo_servico(9, ziper).

!iniciar.

+!iniciar
    <- .wait(configuracao(_, _, _));
       ?configuracao(_, M, I);
       -+numero_participantes(M);
       -+quantidade_servicos(I);
       !criar_contratos(1, I).

+!criar_contratos(Id, Total) : Id <= Total
    <- ?tipo_servico(Id, Tipo);
       !!contratar(Id, Tipo);
       !criar_contratos(Id + 1, Total).
+!criar_contratos(Id, Total) : Id > Total.

// !! cria uma intencao independente para cada negociacao.
+!contratar(Id, Servico)
    <- ?numero_participantes(M);
       registrar_inicio(Id, Servico);
       registrar_mensagens(M);
       .findall(P, participante(P), Participantes);
       for (.member(P, Participantes)) {
           .send(P, tell, solicitar_proposta(Id, Servico));
       };
       .print("CNP ", Id, ": solicitando ", Servico);
       .wait({+respostas_completas(Id)}, 10000, _Timeout);
       !selecionar_proposta(Id, Servico).

+proposta(Id, Servico, Valor)[source(Prestador)]
    <- +resposta(Id, Prestador);
       .print("CNP ", Id, ": proposta de ", Prestador, " = R$ ", Valor);
       !verificar_respostas(Id).

+recusa(Id, Servico)[source(Prestador)]
    <- +resposta(Id, Prestador);
       .print("CNP ", Id, ": ", Prestador, " nao oferece ", Servico);
       !verificar_respostas(Id).

+!verificar_respostas(Id)
    : numero_participantes(M) & .count(resposta(Id, _), Quantidade) &
      Quantidade >= M
    <- +respostas_completas(Id).
+!verificar_respostas(_).

+!selecionar_proposta(Id, Servico)
    <- .findall([Valor, Prestador],
                proposta(Id, Servico, Valor)[source(Prestador)], Propostas);
       .sort(Propostas, Ordenadas);
       ?orcamento_maximo(Servico, Limite);
       if (Ordenadas == []) {
           .print("CNP ", Id, ": nenhuma proposta recebida");
           registrar_resultado(Id, Servico, falha, 0);
           !marcar_finalizado(Id);
       } else {
           .nth(0, Ordenadas, [MenorValor, Vencedor]);
           if (MenorValor <= Limite) {
               registrar_mensagem;
               .send(Vencedor, tell, proposta_aceita(Id, Servico, MenorValor));
               .print("CNP ", Id, ": selecionado ", Vencedor,
                      " por R$ ", MenorValor);
           } else {
               .print("CNP ", Id, ": proposta minima acima do orcamento");
               registrar_resultado(Id, Servico, falha, MenorValor);
               !marcar_finalizado(Id);
           };
           for (.member([Valor, Prestador], Ordenadas)) {
               if (Prestador \== Vencedor | MenorValor > Limite) {
                   registrar_mensagem;
                   .send(Prestador, tell, proposta_rejeitada(Id, Servico, Valor));
               };
               -proposta(Id, Servico, Valor)[source(Prestador)];
           };
       }.

+servico_concluido(Id, Servico, Valor)[source(Prestador)]
    <- .print("CNP ", Id, ": ", Servico, " concluido por ", Prestador);
       registrar_resultado(Id, Servico, sucesso, Valor);
       !marcar_finalizado(Id).

+!marcar_finalizado(Id)
    <- +finalizado(Id);
       ?quantidade_servicos(I);
       .count(finalizado(_), Total);
       if (Total == I) {
           .send(monitor, tell, iniciador_finalizado);
       }.
