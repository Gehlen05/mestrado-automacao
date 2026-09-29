#!/usr/bin/env python3
"""Executa simulações reais e salva dados brutos; não produz relatório."""
import argparse
import csv
import re
import subprocess
import time
from datetime import datetime
from pathlib import Path
from gerar_participantes import ROOT, gerar

RESULTADO = re.compile(r"RESULTADO\|\"?(participante_\d+|ninguem)\"?\|(\d+)\|(\d+)\|(\d+)")
DECISAO = re.compile(r"DECISAO\|(participante_\d+)\|(\d+)\|(ficar|sair)")

def executar(versao, valores, inicio, passo, classpath, log):
    config = gerar(len(valores), versao, inicio, passo, valores)
    main = "jason.infra.local.RunLocalMAS" if versao == "a" else "jacamo.infra.JaCaMoLauncher"
    cmd = ["java", "-Djava.awt.headless=true",
           "-Djava.util.logging.config.file=" + str(ROOT / "logging-headless.properties"),
           "-cp", classpath, main, str(config), "--log-conf", str(ROOT / "logging-headless.properties")]
    start = time.perf_counter()
    try:
        r = subprocess.run(cmd, cwd=ROOT, text=True, stdout=subprocess.PIPE,
                           stderr=subprocess.STDOUT, timeout=45)
        output, code = r.stdout, r.returncode
    except subprocess.TimeoutExpired as e:
        output = e.stdout or b""
        if isinstance(output, bytes): output = output.decode(errors="replace")
        code = 124
    elapsed = round((time.perf_counter() - start) * 1000)
    log.write_text(output)
    matches = RESULTADO.findall(output)
    if code != 0 or len(matches) != 1 or re.search(r"SEVERE|Exception|ERROR|No applicable plan|Could not|Action failed|No failure event", output):
        raise RuntimeError(f"Execução inválida (código {code}); consulte {log}")
    winner, price, rounds, decisions = matches[0]
    price, rounds, decisions = map(int, (price, rounds, decisions))
    # Invariantes verificadas no histórico de decisões real de cada agente.
    history = DECISAO.findall(output)
    if len(history) != decisions: raise AssertionError("Contagem de decisões inconsistente")
    exited, seen = set(), set()
    for name, raw_price, decision in history:
        value = valores[int(name.split("_")[1]) - 1]
        current = int(raw_price)
        if name in exited or (name, current) in seen:
            raise AssertionError("Reentrada ou resposta duplicada")
        if current < inicio or (current - inicio) % passo:
            raise AssertionError("Preço fora da sequência")
        if (decision == "ficar") != (current < value):
            raise AssertionError("Decisão incompatível com a valoração")
        seen.add((name, current))
        if decision == "sair": exited.add(name)
    if price != inicio + (rounds - 1) * passo:
        raise AssertionError("Preço final incompatível com as rodadas")
    return winner, price, rounds, decisions, elapsed

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--validar", action="store_true", help="Executa casos com resultados esperados")
    parser.add_argument("--repeticoes", type=int, default=3)
    args = parser.parse_args()
    if args.repeticoes < 1: parser.error("repeticoes deve ser positiva")
    subprocess.run(["gradle", "preparar", "--console=plain", "--no-daemon"], cwd=ROOT, check=True)
    classpath = (ROOT / "build/runtime-classpath.txt").read_text()
    # Casos de borda incluem empate e salto que elimina todos: sem venda.
    cases = [
        ("normal", [450,520,590,660,730], 100,50, ("participante_5",700,13,55)),
        ("unico", [450],100,50,("participante_1",100,1,1)),
        ("sem_interesse", [50,100],100,50,("ninguem",100,1,2)),
        ("empate", [200,200],100,50,("ninguem",200,3,6)),
        ("saida_definitiva", [100,200,350],100,50,("participante_3",200,3,7)),
        ("passo_grande", [120,140],100,50,("ninguem",150,2,4)),
        ("inicio_zero", [0,10],0,1,("participante_2",0,1,2)),
        ("cem_agentes", list(range(101,201)),100,1,("participante_100",199,100,5149)),
    ] if args.validar else [(f"m{m}", [450+70*i for i in range(m)],100,50,None) for m in (2,5,10,15)]
    out = ROOT / "resultados" / (datetime.now().strftime("%Y%m%d-%H%M%S-%f") + ("-validacao" if args.validar else "-experimentos"))
    out.mkdir(parents=True)
    failures = 0
    with (out / "metricas.csv").open("w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["cenario","versao","participantes","repeticao","status","ganhador","preco_final","rodadas","decisoes","tempo_processo_ms","valoracoes","inicio","passo"])
        for case, values, start, step, expected in cases:
            for rep in range(1, (1 if args.validar else args.repeticoes) + 1):
                pair = []
                for version in ("a", "ae"):
                    log = out / f"{case}-{version}-{rep}.log"
                    try:
                        result = executar(version, values, start, step, classpath, log)
                        if expected is not None and result[:4] != expected:
                            raise AssertionError(f"Esperado {expected}, recebido {result[:4]}")
                        pair.append(result[:4])
                        writer.writerow([case,version,len(values),rep,"ok",*result, str(values),start,step])
                        print(f"OK {case} {version}: {result}", flush=True)
                    except (RuntimeError, AssertionError) as e:
                        failures += 1
                        writer.writerow([case,version,len(values),rep,"erro","","","","","",str(values),start,step])
                        print(f"ERRO {case} {version}: {e}", flush=True)
                    file.flush()
                if len(pair) == 2 and pair[0] != pair[1]:
                    failures += 1
                    print(f"ERRO: versões divergiram em {case}: {pair}", flush=True)
    print(f"Dados brutos: {out}")
    raise SystemExit(1 if failures else 0)

if __name__ == "__main__": main()
