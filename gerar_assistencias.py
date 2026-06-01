"""
gerar_assistencias.py
Converte assistencias.txt -> assistencias.json
Rodado automaticamente pelo ATUALIZAR_PORTAL.bat
"""
import json
from pathlib import Path

TXT_FILE  = Path(__file__).parent / "assistencias.txt"
JSON_FILE = Path(__file__).parent / "assistencias.json"

def parse(txt_path):
    if not txt_path.exists():
        return []

    resultado = []
    bloco = {}
    campos = {"MARCA": "marca", "NOME": "nome", "ENDERECO": "endereco",
              "TELEFONE": "telefone", "GARANTIA": "garantia"}

    for linha in txt_path.read_text(encoding="utf-8").splitlines():
        linha = linha.strip()
        if not linha or linha.startswith("#"):
            continue
        if linha == "---":
            if bloco.get("nome") and bloco.get("marca"):
                if "id" not in bloco:
                    import hashlib
                    bloco["id"] = hashlib.md5(
                        (bloco.get("marca","") + bloco.get("nome","")).encode()
                    ).hexdigest()[:12]
                resultado.append(bloco)
            bloco = {}
            continue
        if ":" in linha:
            chave, _, valor = linha.partition(":")
            chave = chave.strip().upper()
            valor = valor.strip()
            if chave in campos:
                bloco[campos[chave]] = valor

    # Último bloco sem ---
    if bloco.get("nome") and bloco.get("marca"):
        if "id" not in bloco:
            import hashlib
            bloco["id"] = hashlib.md5(
                (bloco.get("marca","") + bloco.get("nome","")).encode()
            ).hexdigest()[:12]
        resultado.append(bloco)

    return resultado

if __name__ == "__main__":
    lista = parse(TXT_FILE)
    JSON_FILE.write_text(
        json.dumps(lista, ensure_ascii=False, indent=2),
        encoding="utf-8"
    )
    print(f"  {len(lista)} assistencia(s) convertida(s) -> assistencias.json")
