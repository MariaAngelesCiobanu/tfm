"""
Entrega 03 - Segmentación de productos para recomendaciones Kefera.
Baseline: tres tramos de precio definidos con los cuantiles del entrenamiento.
Modelo: KMeans (k=3), usando precio, calorías y tiempo de preparación.
"""
from pathlib import Path
import json
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score

ROOT = Path(__file__).resolve().parents[1]
GOLD = ROOT / "data/gold/catalogo_gold.csv"
RESULTS = ROOT / "results"
RESULTS.mkdir(exist_ok=True)

df = pd.read_csv(GOLD)
features = ["precio", "calorias", "tiempo_preparacion"]
X = df[features]

X_train, X_test = train_test_split(X, test_size=0.20, random_state=42)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Baseline sencillo: agrupar por tres tramos de precio.
q1, q2 = X_train["precio"].quantile([1/3, 2/3])
baseline = pd.cut(
    X_test["precio"],
    bins=[-float("inf"), q1, q2, float("inf")],
    labels=False
)
baseline_silhouette = silhouette_score(X_test_scaled, baseline)

# Alternativa ML: KMeans con tres grupos.
model = KMeans(n_clusters=3, random_state=42, n_init=20)
model.fit(X_train_scaled)
clusters = model.predict(X_test_scaled)
kmeans_silhouette = silhouette_score(X_test_scaled, clusters)

out = df.loc[X_test.index].copy()
out["cluster_kmeans"] = clusters
out.to_csv(RESULTS / "asignacion_clusters_test.csv", index=False, encoding="utf-8-sig")

metrics = {
    "n_productos": int(len(df)),
    "n_train": int(len(X_train)),
    "n_test": int(len(X_test)),
    "baseline_silhouette": round(float(baseline_silhouette), 3),
    "kmeans_silhouette": round(float(kmeans_silhouette), 3),
    "kmeans_k": 3,
    "random_state": 42
}
(RESULTS / "metricas_modelo.json").write_text(
    json.dumps(metrics, ensure_ascii=False, indent=2), encoding="utf-8"
)
print(json.dumps(metrics, ensure_ascii=False, indent=2))
