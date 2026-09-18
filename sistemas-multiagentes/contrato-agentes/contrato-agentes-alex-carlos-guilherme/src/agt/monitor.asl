// Encerra o SMA depois que todos os iniciadores terminarem.
+iniciador_finalizado[source(Iniciador)]
    <- +terminou(Iniciador);
       ?configuracao(N, _, _);
       .count(terminou(_), Total);
       if (Total >= N) {
           .print("Experimento concluido por todos os ", N, " iniciadores.");
           .stopMAS;
       }.
