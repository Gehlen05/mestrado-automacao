#!/usr/bin/env python3
"""Gera configurações equivalentes, sem sobrescrever os programas dos agentes."""
import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parent

def gerar(m=5, versao="a", inicio=100, passo=50, valores=None):
    if not 1 <= m <= 100 or inicio < 0 or passo <= 0:
        raise ValueError("Use 1 <= m <= 100, inicio >= 0 e passo > 0")
    valores = valores if valores is not None else [450 + 70 * i for i in range(m)]
    if len(valores) != m or any(v < 0 or v > 1000000 for v in valores):
        raise ValueError("Informe exatamente m valores inteiros entre 0 e 1000000")
    if inicio > 1000000 or passo > 1000000:
        raise ValueError("inicio e passo devem ser <= 1000000")
    out = ROOT / "build/generated"
    out.mkdir(parents=True, exist_ok=True)
    nomes = [f"participante_{i+1}" for i in range(m)]
    if versao == "a":
        agentes = "\n".join(f"    {n} participante.asl [beliefs=\"valoracao({v})\"];" for n, v in zip(nomes, valores))
        texto = f'''MAS leilao_japones {{
  agents:
    leiloeiro [beliefs="participantes([{','.join(nomes)}]),inicio({inicio}),passo({passo})"];
{agentes}
    monitor;
  aslSourcePath: "src/agt";
}}
'''
        destino = out / "leilao.mas2j"
    else:
        agentes = "\n".join(f"  agent {n} : participante_ae.asl {{ beliefs: valoracao({v})\n    focus: sala.leilao\n  }}" for n, v in zip(nomes, valores))
        texto = f'''mas leilao_japones {{
{agentes}
  agent leiloeiro : leiloeiro_ae.asl {{
    focus: sala.leilao
  }}
  agent monitor : monitor_ae.asl {{
    focus: sala.leilao
  }}
  workspace sala {{
    artifact leilao: ambiente.Leilao({m},{inicio},{passo})
  }}
  asl-path: src/agt
  platform: cartago
            jacamo.platform.EnvironmentWebInspector("false")
}}
'''
        destino = out / "leilao.jcm"
    destino.write_text(texto)
    return destino

if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("m", type=int, nargs="?", default=5)
    p.add_argument("--versao", choices=["a", "ae"], default="a")
    p.add_argument("--inicio", type=int, default=100)
    p.add_argument("--passo", type=int, default=50)
    p.add_argument("--valores", default="")
    args = p.parse_args()
    try:
        valores = [int(v) for v in args.valores.split(",")] if args.valores else None
        print(gerar(args.m, args.versao, args.inicio, args.passo, valores))
    except ValueError as e:
        p.error(str(e))
