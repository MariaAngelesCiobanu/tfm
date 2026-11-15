"""
Entrega 02 - Preparación de datos Kefera.
Entrada: data/raw/catalogo_productos_kefera.csv
Salidas: data/silver/catalogo_limpio.csv y data/gold/catalogo_gold.csv
"""
from pathlib import Path
import pandas as pd
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data/raw/catalogo_productos_kefera.csv"
SILVER = ROOT / "data/silver/catalogo_limpio.csv"
GOLD = ROOT / "data/gold/catalogo_gold.csv"

df = pd.read_csv(RAW)
df["nombre"] = df["nombre"].astype(str).str.strip()
df["categoria"] = df["categoria"].astype(str).str.strip()

for col in ["precio", "calorias", "tiempo_preparacion"]:
    df[col] = pd.to_numeric(df[col], errors="coerce")

# Solo productos activos, con nombre y precio válido.
df = df[df["activo"].astype(str).str.lower().isin(["true", "1"])]
df = df.dropna(subset=["nombre", "precio"])
df = df[df["precio"] > 0]
df = df.drop_duplicates(subset=["id_categoria", "nombre"], keep="first")

# Imputación: mediana por categoría; si no existe, mediana global.
for col in ["calorias", "tiempo_preparacion"]:
    mediana_categoria = df.groupby("id_categoria")[col].transform("median")
    df[col] = df[col].fillna(mediana_categoria)
    df[col] = df[col].fillna(df[col].median())

df["calorias"] = df["calorias"].clip(lower=0).round().astype(int)
df["tiempo_preparacion"] = df["tiempo_preparacion"].round().astype(int)
df["precio"] = df["precio"].round(2)

silver = df[[
    "id_categoria", "categoria", "nombre", "descripcion",
    "precio", "calorias", "tiempo_preparacion"
]].reset_index(drop=True)
SILVER.parent.mkdir(parents=True, exist_ok=True)
silver.to_csv(SILVER, index=False, encoding="utf-8-sig")

gold = silver[["nombre", "categoria", "precio", "calorias", "tiempo_preparacion"]].copy()
gold.insert(0, "producto_id", np.arange(1, len(gold) + 1))
GOLD.parent.mkdir(parents=True, exist_ok=True)
gold.to_csv(GOLD, index=False, encoding="utf-8-sig")

print(f"Raw: {len(pd.read_csv(RAW))} filas")
print(f"Silver: {len(silver)} filas")
print(f"Gold: {len(gold)} filas")
print("Gold:", GOLD)
