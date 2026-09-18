package ambiente;

import jason.asSyntax.ASSyntax;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Structure;
import jason.environment.Environment;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.time.Instant;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.DoubleAdder;
import java.util.logging.Logger;

/** Ambiente e coletor de metricas dos experimentos do Contract Net Protocol. */
public class ContratoEnvironment extends Environment {

    private static final Logger LOG = Logger.getLogger(ContratoEnvironment.class.getName());
    private final AtomicInteger mensagens = new AtomicInteger();
    private final AtomicInteger propostas = new AtomicInteger();
    private final AtomicInteger recusas = new AtomicInteger();
    private final AtomicInteger concluidos = new AtomicInteger();
    private final AtomicInteger falhas = new AtomicInteger();
    private final DoubleAdder valorContratado = new DoubleAdder();

    private int n;
    private int m;
    private int i;
    private int totalEsperado;
    private long inicio;
    private boolean resumoGravado;

    @Override
    public void init(String[] args) {
        super.init(args);
        n = Integer.parseInt(args[0]);
        m = Integer.parseInt(args[1]);
        i = Integer.parseInt(args[2]);
        totalEsperado = n * i;
        inicio = System.nanoTime();
        addPercept(ASSyntax.createLiteral("configuracao",
                ASSyntax.createNumber(n), ASSyntax.createNumber(m),
                ASSyntax.createNumber(i)));
        int porTipo = m / 3;
        int resto = m % 3;
        adicionarParticipantes("vendedor_botao", porTipo + (resto > 0 ? 1 : 0));
        adicionarParticipantes("vendedor_linha", porTipo + (resto > 1 ? 1 : 0));
        adicionarParticipantes("vendedor_ziper", porTipo);
        LOG.info(String.format("Experimento iniciado: n=%d, m=%d, i=%d", n, m, i));
    }

    private void adicionarParticipantes(String prefixo, int quantidade) {
        for (int indice = 1; indice <= quantidade; indice++) {
            String nome = quantidade == 1 ? prefixo : prefixo + indice;
            addPercept(ASSyntax.createLiteral("participante", ASSyntax.createAtom(nome)));
        }
    }

    @Override
    public synchronized boolean executeAction(String agente, Structure acao) {
        try {
            switch (acao.getFunctor()) {
                case "registrar_mensagens" -> mensagens.addAndGet(numeroInteiro(acao, 0));
                case "registrar_mensagem" -> mensagens.incrementAndGet();
                case "registrar_proposta" -> propostas.incrementAndGet();
                case "registrar_recusa" -> recusas.incrementAndGet();
                case "registrar_inicio" -> { /* o inicio global ja foi registrado */ }
                case "registrar_resultado" -> registrarResultado(acao);
                default -> LOG.fine(agente + " executou " + acao);
            }
            return true;
        } catch (Exception e) {
            LOG.severe("Erro ao registrar " + acao + ": " + e.getMessage());
            return false;
        }
    }

    private void registrarResultado(Structure acao) throws Exception {
        String status = acao.getTerm(2).toString();
        double valor = numero(acao, 3);
        if ("sucesso".equals(status)) {
            concluidos.incrementAndGet();
            valorContratado.add(valor);
        } else {
            falhas.incrementAndGet();
        }
        if (!resumoGravado && concluidos.get() + falhas.get() >= totalEsperado) {
            resumoGravado = true;
            gravarResumo();
        }
    }

    private void gravarResumo() throws IOException {
        long tempoMs = (System.nanoTime() - inicio) / 1_000_000;
        double media = concluidos.get() == 0 ? 0 : valorContratado.sum() / concluidos.get();
        Path diretorio = Path.of("resultados");
        Path arquivo = diretorio.resolve("metricas.csv");
        Files.createDirectories(diretorio);
        if (Files.notExists(arquivo)) {
            Files.writeString(arquivo,
                    "data,n,m,i,total_cnp,concluidos,falhas,mensagens,propostas,recusas,tempo_ms,preco_medio\n",
                    StandardCharsets.UTF_8, StandardOpenOption.CREATE);
        }
        String linha = String.format(Locale.US,
                "%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%.2f%n",
                Instant.now(), n, m, i, totalEsperado, concluidos.get(), falhas.get(),
                mensagens.get(), propostas.get(), recusas.get(), tempoMs, media);
        Files.writeString(arquivo, linha, StandardCharsets.UTF_8,
                StandardOpenOption.CREATE, StandardOpenOption.APPEND);
        LOG.info("Metricas gravadas em " + arquivo.toAbsolutePath());
    }

    private int numeroInteiro(Structure acao, int indice) throws Exception {
        return (int) numero(acao, indice);
    }

    private double numero(Structure acao, int indice) throws Exception {
        return ((NumberTerm) acao.getTerm(indice)).solve();
    }
}
