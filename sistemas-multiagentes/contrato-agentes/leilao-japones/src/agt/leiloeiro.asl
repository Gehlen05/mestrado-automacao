// Toda a coordenação da versão A está neste agente Jason.
!iniciar.
+!iniciar : participantes(Ags) & inicio(P)
    <- +decisoes(0); !rodada(Ags, P, 1).

+!rodada(Ags, P, R)
    <- .print("RODADA|", R, "|", P, "|", Ags);
       !consultar(Ags, P, [], Restantes);
       !avaliar(Restantes, P, R).

+!consultar([], P, Ac, Ac).
+!consultar([Ag|Cauda], P, Ac, Restantes)
    <- .send(Ag, askOne, decisao(P, D), decisao(P, D), 5000);
       ?decisoes(N); -+decisoes(N+1);
       .print("DECISAO|", Ag, "|", P, "|", D);
       !acumular(D, Ag, Ac, Novos);
       !consultar(Cauda, P, Novos, Restantes).
+!acumular(ficar, Ag, Ac, [Ag|Ac]).
+!acumular(sair, Ag, Ac, Ac).

+!avaliar([], P, R) <- !concluir(ninguem, P, R).
+!avaliar([G], P, R) <- !concluir(G, P, R).
+!avaliar([A,B|Cauda], P, R) : passo(S)
    <- !rodada([A,B|Cauda], P+S, R+1).
+!concluir(G, P, R) : decisoes(N)
    <- .send(monitor, tell, resultado(G, P, R, N)).
