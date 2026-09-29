// A: a resposta ao askOne é calculada pelo próprio participante.
// O leiloeiro nunca consulta novamente quem saiu.
decisao(P, ficar) :- valoracao(V) & P < V.
decisao(P, sair) :- valoracao(V) & P >= V.
