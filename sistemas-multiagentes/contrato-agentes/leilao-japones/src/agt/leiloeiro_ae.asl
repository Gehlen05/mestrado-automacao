{ include("$jacamo/templates/common-cartago.asl") }
// O artefato coordena as rodadas; o leiloeiro acompanha o preço público.
+rodada(R, P) : R > 0 <- .print("RODADA|", R, "|", P).
