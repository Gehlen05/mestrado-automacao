// Vende somente ziperes. Estrategia economica, com menor variacao de preco.
+solicitar_proposta(Id, ziper)[source(Comprador)] : .random(R)
    <- Valor = 400 + R * 200;
       registrar_proposta; registrar_mensagem;
       +oferta(Id, ziper, Valor)[source(Comprador)];
       .send(Comprador, tell, proposta(Id, ziper, Valor)).
+solicitar_proposta(Id, Outro)[source(Comprador)] : Outro \== ziper
    <- registrar_recusa; registrar_mensagem;
       .send(Comprador, tell, recusa(Id, Outro)).
+proposta_aceita(Id, Produto, Valor)[source(Comprador)]
    : oferta(Id, Produto, Valor)[source(Comprador)]
    <- .print("Separando lote de ziperes do CNP ", Id);
       registrar_mensagem;
       .send(Comprador, tell, servico_concluido(Id, Produto, Valor));
       -oferta(Id, Produto, Valor)[source(Comprador)].
+proposta_rejeitada(Id, Produto, Valor)[source(Comprador)]
    <- -oferta(Id, Produto, Valor)[source(Comprador)].
