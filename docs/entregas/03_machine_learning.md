# Entrega 03 - Machine Learning

## 1. Qué problema resuelve el modelo

En el backend existe un endpoint `/api/recomendaciones/{id}`, pero la implementación revisada devuelve los primeros tres productos disponibles y no aplica actualmente un algoritmo de recomendación. Por eso, esta entrega plantea y evalúa un primer experimento de segmentación del catálogo como prueba de concepto analítica. La integración del resultado del modelo en el endpoint queda como trabajo posterior.

El problema se plantea como **segmentación no supervisada**. El resultado lo utilizaría el cliente al consultar un producto y también podría servir al establecimiento para organizar y analizar su carta.

La división de cuenta sigue siendo una funcionalidad independiente del modelo de Machine Learning. En la versión revisada del frontend, `DivisionCuentaPage` permite registrar a los comensales y asignar cada producto a una o varias personas, repartiendo el importe correspondiente cuando un producto es compartido. Esta funcionalidad se encuentra implementada en la aplicación, aunque el cobro real debe realizarse mediante el flujo de pago del establecimiento.

## 2. Datos de entrada y salida

Se parte del dataset Gold de la Entrega 2 (`data/gold/catalogo_gold.csv`). Las variables de entrada son:

- `precio`: precio del producto en euros.
- `calorias`: valor calórico registrado en el catálogo.
- `tiempo_preparacion`: tiempo estimado de preparación en minutos.

La salida es `cluster_kmeans`, un identificador de grupo (0, 1 o 2). Como posible integración posterior, el backend podría consultar el grupo del producto y mostrar otros productos del mismo grupo. Esta integración no se considera implementada en esta entrega.

No se utilizan el nombre, el identificador ni la categoría como variables de entrada, para evitar que el algoritmo se limite a reproducir las categorías ya definidas en el menú. No existe una variable objetivo supervisada. El principal riesgo de calidad es que los valores imputados en la Entrega 2 pueden influir en la distancia entre productos. También debe recordarse que el catálogo no contiene información de clientes ni de compras reales.

## 3. Baseline y selección de modelos

Se ha establecido un baseline sencillo que divide los productos en tres tramos de precio (bajo, medio y alto), utilizando los terciles calculados únicamente con los datos de entrenamiento.

Como alternativa se ha probado **K-Means con tres grupos**, utilizando las variables precio, calorías y tiempo de preparación. Antes del entrenamiento se aplica `StandardScaler`, ajustado solo con el conjunto de entrenamiento, para que las escalas de las variables sean comparables.

Se ha elegido K-Means porque es un método sencillo de segmentación y permite asignar nuevos productos a un grupo mediante `predict`. No se busca utilizar un algoritmo complejo, sino comprobar si las características conjuntas permiten obtener grupos más coherentes que una separación basada únicamente en el precio.

## 4. Validación y evaluación

Se ha separado el conjunto Gold en entrenamiento (80 %) y prueba (20 %), con `random_state=42`. El escalador y el modelo se ajustan exclusivamente con entrenamiento; después se asignan los productos de prueba a los grupos. De esta forma se evita utilizar información del conjunto de prueba durante el ajuste.

Como se trata de segmentación sin etiquetas reales, se utiliza el **coeficiente Silhouette**: cuanto más alto, mejor separados y cohesionados están los grupos. En el conjunto de prueba se han obtenido estos resultados:

| Enfoque | Silhouette (test) |
|---|---:|
| Baseline: tres tramos de precio | 0.295 |
| K-Means (k=3) | 0.697 |

En esta primera prueba, K-Means obtiene un valor Silhouette superior al baseline. El resultado sugiere que combinar precio, calorías y tiempo de preparación produce una segmentación más definida que utilizar solo el precio.

El resultado debe interpretarse con cautela: el conjunto contiene 155 productos, la muestra de prueba es de 31 productos y el catálogo fue creado para el proyecto. La métrica mide separación geométrica, no demuestra que los clientes vayan a aceptar las recomendaciones.

## 5. Decisión y uso en el producto

Para esta prueba de concepto se selecciona K-Means con tres grupos, porque obtiene una mejor puntuación Silhouette en la muestra de prueba que el baseline utilizado. La salida del experimento es un identificador de grupo para cada producto. El backend todavía no consume esta salida; integrarla y comprobar su utilidad con usuarios o pedidos reales será un siguiente paso.

Esta recomendación sería complementaria a la funcionalidad principal de Kefera. No sustituye ni modifica la división de cuenta. Antes de utilizarla en un entorno real, habría que contrastarla con pedidos, valoraciones o pruebas con usuarios. Cuando se disponga de histórico de ventas, se podrá evaluar un recomendador basado en productos que se compran conjuntamente y comparar sus resultados con este primer enfoque.

## Reproducibilidad

Desde la raíz del paquete:

```bash
pip install -r requirements.txt
python src/01_preparar_datos.py
python src/02_entrenar_modelo.py
```

El script de Machine Learning genera `results/metricas_modelo.json` y `results/asignacion_clusters_test.csv`. El dataset Gold utilizado es `data/gold/catalogo_gold.csv`.