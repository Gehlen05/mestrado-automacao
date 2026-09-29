{ include("$jacamo/templates/common-cartago.asl") }
// O monitor registra-se após estabelecer foco, evitando perder o resultado.
+rodada(0, _) <- monitorPronto.
+resultado(G, P, R, N)
    <- .print("RESULTADO|", G, "|", P, "|", R, "|", N);
       .stopMAS.
