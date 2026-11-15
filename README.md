# TFM - Kefera | Máster en Data Science e Inteligencia Artificial

Este repositorio reúne el proyecto de aplicación Kefera y las entregas académicas del TFM. La aplicación original se conserva dentro de `kefera/`; la documentación, los datos de análisis y los experimentos del TFM se encuentran en la raíz.

## 1. Estructura del proyecto

```text
TFM_Kefera_Completo/
├── kefera/
│   ├── frontend/
│   ├── backend/
│   └── baseDatos/
│       ├── schema/
│       └── seed/
├── docs/
│   ├── estado_actual_kefera.md
│   ├── ajuste_cuenta_por_sesion.md
│   ├── prueba_division_cuenta.md
│   └── entregas/
│       ├── 01_ideas_producto.md
│       ├── 02_datos_y_preparacion.md
│       └── 03_machine_learning.md
├── data/
│   ├── raw/
│   ├── silver/
│   └── gold/
├── src/
│   ├── 01_preparar_datos.py
│   └── 02_entrenar_modelo.py
├── results/
├── requirements.txt
└── README.md
```

## 2. Entregas incluidas

- **Entrega 1:** propuesta inicial de Kefera.
- **Entrega 2:** fuentes de datos del catálogo y preparación Bronze/Raw → Silver → Gold.
- **Entrega 3:** experimento de segmentación no supervisada del catálogo mediante baseline y K-Means.
- **División de cuenta:** asignación de consumiciones a uno o varios comensales, con persistencia por sesión de mesa.

## 3. Tecnologías utilizadas

- Flutter y Dart para el frontend.
- Java y Spring Boot para el backend.
- PostgreSQL para la base de datos.
- Python, Pandas, NumPy y Scikit-learn para el análisis de datos y Machine Learning.
- Maven Wrapper para gestionar la compilación del backend.

## 4. Configuración del backend

### Requisitos

- Java 21.
- PostgreSQL.
- Una base de datos PostgreSQL llamada `kefera`.

### Preparación de la base de datos

1. Crear la base de datos `kefera`.
2. Ejecutar los scripts SQL de `kefera/baseDatos/schema/` en el orden correspondiente.
3. Ejecutar los scripts de datos iniciales de `kefera/baseDatos/seed/`.
4. Ejecutar la migración adicional `34_schema_cuentas_compartidas.sql` para habilitar la persistencia de la división de cuenta.

### Configuración de credenciales

En `kefera/backend/src/main/resources/application.properties` se utiliza la variable de entorno `DB_PASSWORD` para evitar guardar contraseñas directamente en el código.

Antes de iniciar el backend, configurar la contraseña del usuario PostgreSQL:

```powershell
$env:DB_PASSWORD = Read-Host "Introduce tu contraseña de PostgreSQL"
```


### Arranque del backend

Desde la carpeta `kefera/backend`:

```powershell
.\mvnw.cmd spring-boot:run
```

El backend se ejecuta en:

`http://localhost:8080`

## 5. Configuración del frontend

### Requisitos

- Flutter SDK.
- Dart SDK.
- Android Studio o un dispositivo Android configurado.

Desde `kefera/frontend`, ejecutar:

```bash
flutter pub get
flutter run
```

Para generar una APK de depuración:

```bash
flutter build apk --debug
```

## 6. Reproducir el flujo de datos y Machine Learning

Desde la raíz del repositorio, instalar las dependencias:

```bash
pip install -r requirements.txt
```

Ejecutar la preparación de datos:

```bash
python src/01_preparar_datos.py
```

Este proceso genera los conjuntos Silver y Gold a partir de los datos Raw.

A continuación, entrenar y evaluar el modelo:

```bash
python src/02_entrenar_modelo.py
```

Los resultados se guardan en `results/`:

- `metricas_modelo.json`: métricas de evaluación y comparación.
- `asignacion_clusters_test.csv`: asignación de los productos del conjunto de prueba a los grupos.

## 7. División de cuenta y recomendaciones

La pantalla de división de cuenta permite introducir el número de mesa y su capacidad, añadir comensales y asignar cada producto a una o varias personas.

El estado de participantes y asignaciones se persiste mediante:

`/api/cuentas-compartidas/mesa/{numeroMesa}`

La información se almacena en la tabla `kefera.cuentas_compartidas`, relacionada con la sesión de la mesa.

El importe de cada producto se reparte entre las personas que lo comparten. El cálculo se realiza en Flutter y se guarda en PostgreSQL.

Esta funcionalidad todavía no dispone de sincronización en tiempo real ni de un carrito común servido desde el backend. El cobro real debe realizarse mediante el flujo de pago del establecimiento.

También existe un endpoint básico de recomendaciones (`/api/recomendaciones/{id}`), pero todavía no consume el modelo de Machine Learning.

## 8. Alcance y limitaciones del modelo

El experimento de la Entrega 3 agrupa productos por precio, calorías y tiempo de preparación. Se trata de una prueba de concepto basada en las características del catálogo.

El modelo K-Means obtuvo un coeficiente Silhouette de 0,697, frente a 0,295 del baseline basado en tramos de precio, en el conjunto de prueba.

Estos resultados describen la separación de los grupos del catálogo, pero no predicen ventas ni representan preferencias reales de clientes.

La integración del modelo en el endpoint de recomendaciones queda pendiente de validación con datos reales.

## 9. Consideraciones de seguridad y reproducción

Las credenciales de PostgreSQL no se incluyen en el repositorio. Cada persona que quiera ejecutar el proyecto debe configurar sus propias credenciales mediante variables de entorno.

Para reproducir el proyecto en otro ordenador es necesario preparar previamente PostgreSQL, ejecutar los scripts SQL y configurar los requisitos de Java, Flutter y Python.

La carpeta `kefera/` conserva el código de la aplicación, mientras que los scripts, datos y documentos del TFM se mantienen separados para facilitar su revisión.