// Vende somente botoes. Estrategia: preco aleatorio em uma faixa ampla.
+solicitar_proposta(Id, botao)[source(Comprador)] : .random(R)
    <- Valor = 250 + R * 250;
       registrar_proposta; registrar_mensagem;
       +oferta(Id, botao, Valor)[source(Comprador)];
       .send(Comprador, tell, proposta(Id, botao, Valor)).
+solicitar_proposta(Id, Outro)[source(Comprador)] : Outro \== botao
    <- registrar_recusa; registrar_mensagem;
       .send(Comprador, tell, recusa(Id, Outro)).
+proposta_aceita(Id, Produto, Valor)[source(Comprador)]
    : oferta(Id, Produto, Valor)[source(Comprador)]
    <- .print("Separando lote de botoes do CNP ", Id);
       registrar_mensagem;
       .send(Comprador, tell, servico_concluido(Id, Produto, Valor));
       -oferta(Id, Produto, Valor)[source(Comprador)].
+proposta_rejeitada(Id, Produto, Valor)[source(Comprador)]
    <- -oferta(Id, Produto, Valor)[source(Comprador)].
