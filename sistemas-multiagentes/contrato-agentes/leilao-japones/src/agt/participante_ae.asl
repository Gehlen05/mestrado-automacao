{ include("$jacamo/templates/common-cartago.asl") }
// O foco é configurado no .jcm antes do registro.
+rodada(0, _) <- registrar.
+rodada(R, P) : R > 0 & valoracao(V) & P < V & not desistiu
    <- responder(R, "ficar").
+rodada(R, P) : R > 0 & valoracao(V) & P >= V & not desistiu
    <- +desistiu; responder(R, "sair").
