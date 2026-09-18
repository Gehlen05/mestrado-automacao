// Vende somente linhas. Estrategia: preco aumenta conforme a demanda recebida.
solicitacoes_recebidas(0).
+solicitar_proposta(Id, linha)[source(Comprador)]
    : solicitacoes_recebidas(S) & .random(R)
    <- -+solicitacoes_recebidas(S + 1);
       Valor = 150 + S * 10 + R * 150;
       registrar_proposta; registrar_mensagem;
       +oferta(Id, linha, Valor)[source(Comprador)];
       .send(Comprador, tell, proposta(Id, linha, Valor)).
+solicitar_proposta(Id, Outro)[source(Comprador)] : Outro \== linha
    <- registrar_recusa; registrar_mensagem;
       .send(Comprador, tell, recusa(Id, Outro)).
+proposta_aceita(Id, Produto, Valor)[source(Comprador)]
    : oferta(Id, Produto, Valor)[source(Comprador)]
    <- .print("Separando lote de linhas do CNP ", Id);
       registrar_mensagem;
       .send(Comprador, tell, servico_concluido(Id, Produto, Valor));
       -oferta(Id, Produto, Valor)[source(Comprador)].
+proposta_rejeitada(Id, Produto, Valor)[source(Comprador)]
    <- -oferta(Id, Produto, Valor)[source(Comprador)].
