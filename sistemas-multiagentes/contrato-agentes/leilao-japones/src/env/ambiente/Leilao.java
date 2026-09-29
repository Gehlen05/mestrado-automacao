package ambiente;

import cartago.Artifact;
import cartago.OPERATION;
import java.util.LinkedHashSet;
import java.util.Set;

/** Relógio ascendente discreto. Cada rodada espera uma decisão por agente ativo. */
public class Leilao extends Artifact {
    private int quantidade, preco, passo, rodada, decisoes;
    private boolean monitor, encerrado;
    private final Set<String> inscritos = new LinkedHashSet<>();
    private final Set<String> ativos = new LinkedHashSet<>();
    private final Set<String> pendentes = new LinkedHashSet<>();

    void init(int quantidade, int preco, int passo) {
        if (quantidade < 1 || preco < 0 || passo < 1) throw new IllegalArgumentException();
        this.quantidade = quantidade;
        this.preco = preco;
        this.passo = passo;
        defineObsProperty("rodada", 0, preco);
    }

    @OPERATION void registrar() {
        String agente = getCurrentOpAgentId().getAgentName();
        if (!agente.matches("participante_[1-9][0-9]*") ||
            Integer.parseInt(agente.substring(13)) > quantidade ||
            rodada != 0 || !inscritos.add(agente)) {
            failed("registro invalido"); return;
        }
        ativos.add(agente);
        iniciarSePronto();
    }

    @OPERATION void monitorPronto() {
        if (!getCurrentOpAgentId().getAgentName().equals("monitor")) {
            failed("apenas monitor"); return;
        }
        monitor = true;
        iniciarSePronto();
    }

    private void iniciarSePronto() {
        if (monitor && inscritos.size() == quantidade && rodada == 0) publicarRodada();
    }

    private void publicarRodada() {
        rodada++;
        pendentes.clear();
        pendentes.addAll(ativos);
        getObsProperty("rodada").updateValues(rodada, preco);
    }

    @OPERATION void responder(int numeroRodada, String decisao) {
        String agente = getCurrentOpAgentId().getAgentName();
        if (encerrado || numeroRodada != rodada || !pendentes.contains(agente) ||
            !(decisao.equals("ficar") || decisao.equals("sair"))) {
            failed("resposta invalida, repetida ou fora de rodada"); return;
        }
        pendentes.remove(agente);
        decisoes++;
        if (decisao.equals("sair")) ativos.remove(agente);
        System.out.println("DECISAO|" + agente + "|" + preco + "|" + decisao);
        if (pendentes.isEmpty()) {
            if (ativos.size() <= 1) {
                encerrado = true;
                String ganhador = ativos.isEmpty() ? "ninguem" : ativos.iterator().next();
                defineObsProperty("resultado", ganhador, preco, rodada, decisoes);
            } else {
                preco = Math.addExact(preco, passo);
                publicarRodada();
            }
        }
    }
}
