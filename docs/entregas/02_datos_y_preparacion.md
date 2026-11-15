# Entrega 02 - Datos y preparación

## 1. Qué datos necesita el producto

Kefera necesita información del catálogo para mostrar los productos y facilitar que el cliente elija qué consumir. Para esta primera fase analítica, cada fila representa un producto del menú. Los campos principales son nombre, categoría, precio, calorías y tiempo estimado de preparación. La descripción se conserva como información complementaria.

Los datos imprescindibles para el análisis son el precio, las calorías y el tiempo de preparación. La categoría y el nombre permiten identificar y mostrar el producto. En esta entrega se trabaja con el catálogo disponible en el proyecto, no con un histórico de ventas: Kefera todavía no dispone en este repositorio de suficientes pedidos reales para estudiar hábitos de compra.

## 2. Fuentes reales y viabilidad

La fuente utilizada son los datos propios del proyecto Kefera, incluidos en los scripts SQL de `kefera/baseDatos/seed/` y definidos en el esquema `kefera/baseDatos/schema/03_schema_menu.sql`. Son los datos del catálogo que la aplicación utiliza para representar su oferta gastronómica.

La adquisición es reproducible porque los registros están almacenados en los ficheros SQL del repositorio. Para esta entrega se ha extraído una copia tabular en `data/raw/catalogo_productos_kefera.csv`. El catálogo tiene cobertura de varias categorías del menú y puede actualizarse cuando se modifiquen los scripts SQL.

La principal limitación es que estos datos describen productos, pero no contienen todavía un histórico real de ventas ni asociaciones entre productos comprados en una misma mesa. Como alternativa futura, cuando Kefera acumule pedidos reales, se podrán incorporar las tablas `pedidos` y `detalle_pedido` para enriquecer el análisis.

## 3. Uso, privacidad y datos personales

El catálogo contiene información comercial de los productos y no incluye nombres, teléfonos, correos ni otros datos personales de clientes. Por tanto, no es necesario tratar datos personales para el análisis realizado.

Los datos proceden del propio proyecto Kefera. Se utilizarán únicamente los campos necesarios para describir y comparar productos. Si en futuras fases se incorporan pedidos o clientes, se trabajará con identificadores seudonimizados y se excluirán los datos personales que no sean necesarios.

## 4. Del dato bruto al dato utilizable

Se ha seguido un flujo sencillo y reproducible:

| Capa | Contenido |
|---|---|
| **Bronze / Raw** | `data/raw/catalogo_productos_kefera.csv`. Copia tabular de los registros de producto procedentes de los SQL de semillas de Kefera. Se conserva el contenido original de los campos extraídos. |
| **Silver** | `data/silver/catalogo_limpio.csv`. Se normalizan espacios y tipos numéricos, se conservan productos activos, se eliminan duplicados por identificador de categoría y nombre, se descartan precios nulos o no válidos y se imputan calorías y tiempo de preparación con la mediana de cada categoría (o la mediana global si no hay datos suficientes). |
| **Gold** | `data/gold/catalogo_gold.csv`. Una fila por producto válido, con identificador interno generado para el conjunto, nombre, categoría, precio, calorías y tiempo de preparación. Este conjunto se utiliza en la siguiente fase para segmentar productos y explorar posibles recomendaciones de productos similares. |

El proceso se reproduce ejecutando `python src/01_preparar_datos.py` desde la carpeta raíz del paquete. En esta extracción se parte de 163 registros del catálogo y se obtiene un Gold de 155 productos tras filtrar y limpiar.

## 5. Riesgos y limitaciones

El catálogo es relativamente pequeño y algunos productos no tienen información nutricional o de preparación, por lo que se han imputado valores y esto puede afectar a los grupos obtenidos. Tampoco hay todavía histórico de compras, valoraciones ni preferencias reales de clientes; por eso las recomendaciones de esta fase se basan en características del producto y no en hábitos observados. Cuando Kefera disponga de pedidos reales, será conveniente volver a entrenar y validar el sistema con esos datos.