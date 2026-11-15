# Estado actual de Kefera

Este documento describe el estado funcional y técnico del proyecto Kefera, diferenciando las funcionalidades implementadas, las pruebas realizadas y las mejoras que quedan pendientes.

## 1. Componentes del proyecto

El proyecto está compuesto por:

- **Frontend:** aplicación móvil desarrollada con Flutter.
- **Backend:** API REST desarrollada con Java y Spring Boot.
- **Base de datos:** PostgreSQL.
- **Análisis de datos:** scripts Python con Pandas, NumPy y Scikit-learn.
- **Documentación:** entregas académicas, guías de prueba y documentación técnica.

La aplicación permite consultar el catálogo de productos y dispone de funcionalidades relacionadas con mesas, sesiones, pedidos y división de cuenta.

## 2. División de cuenta

La pantalla `DivisionCuentaPage` permite:

- Introducir el número de mesa y su capacidad.
- Añadir y eliminar comensales.
- Asignar cada producto a uno o varios comensales.
- Repartir el importe de un producto entre las personas que lo comparten.
- Calcular los importes correspondientes a cada participante.

El reparto se calcula en Flutter y contempla la distribución de los céntimos sobrantes para evitar diferencias en los importes.

### Persistencia

Se ha incorporado persistencia mediante el endpoint:

`/api/cuentas-compartidas/mesa/{numeroMesa}`

El backend almacena los participantes y las asignaciones en la tabla `kefera.cuentas_compartidas`, utilizando la sesión abierta de la mesa como referencia.

La información se puede recuperar al volver a configurar la misma mesa y se actualiza cuando se modifican los participantes o las asignaciones.

Para habilitar esta funcionalidad en una base de datos nueva es necesario ejecutar la migración:

`kefera/baseDatos/schema/34_schema_cuentas_compartidas.sql`

### Limitaciones

La persistencia guarda el reparto, pero no implica que exista sincronización en tiempo real entre dispositivos. El carrito continúa siendo local en Flutter, por lo que cada dispositivo necesita disponer del mismo contenido para representar el mismo pedido.

El reparto de consumiciones tampoco equivale a un sistema de cobro individual integrado. El pago real debe realizarse mediante el flujo de pago del establecimiento.

## 3. Sistema de recomendaciones

Existe un endpoint:

`/api/recomendaciones/{id}`

En la implementación actual se devuelven hasta tres productos distintos del producto consultado, pero todavía no se utiliza el modelo de Machine Learning desarrollado en la Entrega 3.

El experimento K-Means se mantiene como una prueba de concepto independiente. Su integración en el backend queda como una mejora futura.

## 4. Datos y Machine Learning

El proyecto dispone de datos de catálogo con información como nombre, categoría, precio, calorías y tiempo estimado de preparación.

Se ha desarrollado un flujo de preparación de datos con tres capas:

- **Raw:** datos de entrada del catálogo.
- **Silver:** datos limpiados y transformados.
- **Gold:** conjunto preparado para el análisis y el entrenamiento.

El dataset Gold contiene 155 productos.

Sobre este conjunto se ha realizado un experimento de segmentación no supervisada con K-Means, utilizando precio, calorías y tiempo de preparación.

La evaluación se ha realizado comparando el modelo con un baseline basado en tramos de precio. El modelo K-Means ha obtenido un coeficiente Silhouette de 0,697 frente a 0,295 del baseline en el conjunto de prueba.

Estos resultados describen la separación de los grupos del catálogo y no demuestran preferencias reales de clientes ni predicen ventas.

## 5. Pruebas realizadas

Durante la revisión del proyecto se han realizado las siguientes comprobaciones:

- Compilación del backend mediante Maven Wrapper.
- Arranque de Spring Boot.
- Consulta de mesas y sesiones mediante la API.
- Pruebas de creación, consulta y eliminación de cuentas compartidas.
- Instalación de dependencias del frontend Flutter.
- Análisis estático del frontend.
- Compilación de APK en modo debug, comprobada por el usuario.
- Ejecución del proceso de preparación del dataset.
- Entrenamiento y evaluación del modelo K-Means.

El análisis estático de Flutter mostró advertencias e información de mantenimiento, pero no errores de análisis.

Estas comprobaciones no equivalen a una validación integral de todos los flujos de la aplicación en producción.

## 6. Mejoras pendientes

Las principales líneas de evolución del proyecto son:

1. Incorporar sincronización en tiempo real de los pedidos y carritos entre dispositivos.
2. Integrar el reparto de cuenta con el flujo de pedidos y pagos.
3. Integrar el resultado del modelo K-Means en el endpoint de recomendaciones.
4. Evaluar las recomendaciones con datos reales de pedidos y comportamiento de clientes.
5. Ampliar las pruebas funcionales de la aplicación en distintos dispositivos.

## 7. Conclusión

Kefera combina una aplicación móvil, un backend y una base de datos relacional con un flujo de análisis de datos y un primer experimento de Machine Learning.

Durante el desarrollo se han ampliado funcionalidades como la división de cuenta con persistencia por sesión de mesa y se ha preparado un conjunto de datos para experimentar con técnicas de segmentación.

El resultado es una primera versión funcional y ampliable, con limitaciones identificadas y una base técnica sobre la que continuar desarrollando el producto.