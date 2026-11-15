# 🏺 KEFERA
### De una idea de digitalización hostelera a un proyecto de Data Science & Artificial Intelligence

**Proyecto Final de Máster — Tercera entrega**

**Autora:** María Ángeles Ciobanu  
**Formación:** Máster en Data Science & Artificial Intelligence

---

## 🌟 El origen de Kefera: ¿por qué elegí este proyecto?

Kefera nace de la idea de desarrollar una solución tecnológica para el sector de la hostelería, un ámbito en el que todavía existen procesos que pueden simplificarse y mejorarse mediante la digitalización.

Desde el principio, mi intención fue crear algo más que una carta digital. Quería desarrollar una herramienta que mejorase la experiencia del cliente y facilitase determinadas tareas del restaurante.

Una de las funcionalidades que más me motivó fue la posibilidad de dividir la cuenta entre los comensales según los productos que había consumido cada persona. Es una situación muy habitual cuando se comparte una comida y que, en muchas ocasiones, termina convirtiéndose en un proceso incómodo o poco práctico.

A partir de esa idea comenzó a tomar forma Kefera: una plataforma que integra carta digital, acceso mediante QR, gestión de productos, mesas, pedidos y división de cuenta.

## 💡 ¿Por qué he decidido continuar con Kefera?

He decidido seguir desarrollando Kefera porque considero que tiene potencial para evolucionar y porque ya existe una base tecnológica sobre la que seguir construyendo.

No quería dejar el proyecto únicamente como una aplicación funcional. Quería explorar qué más podía aportar la tecnología y, especialmente, cómo los datos podían ayudar a entender mejor el funcionamiento de un negocio.

Creo que Kefera es una buena oportunidad para unir dos aspectos que me interesan especialmente: el desarrollo de soluciones tecnológicas y el análisis de información para obtener conocimiento útil.

Un restaurante genera información constantemente: productos consultados, pedidos realizados, precios, categorías, tiempos de preparación y preferencias de consumo. Toda esa información puede convertirse en una herramienta para comprender el negocio y apoyar la toma de decisiones.

Por eso, continuar con Kefera me permite pasar de desarrollar una aplicación que resuelve necesidades operativas a explorar cómo esa misma aplicación puede convertirse en una fuente de información y conocimiento.

## 🎓 ¿Cómo se conecta Kefera con el Máster en Data Science & Artificial Intelligence?

El Máster en Data Science & Artificial Intelligence me ha permitido ampliar la perspectiva del proyecto.

Hasta ahora, Kefera estaba principalmente enfocada en el desarrollo de una aplicación y en la gestión de sus funcionalidades. Con el máster he podido incorporar una nueva dimensión: el tratamiento, análisis y aprovechamiento de los datos.

La conexión entre ambos ámbitos se refleja en diferentes partes del proyecto:

| Área del máster | Aplicación en Kefera |
|---|---|
| Python | Desarrollo de scripts para preparar y procesar datos |
| NumPy y Pandas | Limpieza, transformación y análisis del catálogo |
| SQL y bases de datos | Almacenamiento y organización de la información |
| Análisis exploratorio | Comprensión de las características de los productos |
| Visualización de datos | Representación de resultados e indicadores |
| Machine Learning | Segmentación de productos mediante K-Means |
| Inteligencia Artificial | Exploración de futuras funcionalidades inteligentes |

De esta manera, el proyecto permite aplicar conocimientos de programación, bases de datos, análisis de datos y aprendizaje automático dentro de un mismo contexto.

## 📊 De la aplicación al análisis de datos

Uno de los objetivos de esta evolución ha sido aprovechar el catálogo de productos de Kefera para construir un pequeño flujo de trabajo de Data Science.

El proceso se organiza en tres etapas:

- **Raw:** datos originales del catálogo.
- **Silver:** datos depurados y preparados.
- **Gold:** datos finales para el análisis y modelado.

Se han desarrollado scripts en Python para limpiar, transformar y preparar la información, así como un experimento de Machine Learning basado en K-Means.

### Resultados del experimento

El modelo utiliza variables como el precio, las calorías y el tiempo de preparación para explorar agrupaciones de productos con características similares.

| Indicador | Resultado |
|---|---:|
| Productos procesados | 155 |
| Algoritmo | K-Means |
| Número de clusters | 3 |
| Silhouette Score baseline | 0,295 |
| Silhouette Score K-Means | 0,697 |

Este experimento representa una primera aproximación al uso de Machine Learning dentro del proyecto. No se presenta como un recomendador integrado en la aplicación, sino como una prueba de concepto que permite estudiar el potencial de los datos del catálogo.

## 🚀 ¿Hacia dónde quiero llevar Kefera?

Mi intención es que Kefera pueda seguir creciendo y que el análisis de datos tenga cada vez más protagonismo.

Algunas de las líneas de evolución que considero interesantes son:

- Analizar los productos más solicitados y las preferencias de los clientes.
- Identificar patrones de consumo y comportamiento.
- Crear cuadros de mando con indicadores relevantes para el restaurante.
- Estudiar la evolución de las ventas y el rendimiento de los productos.
- Explorar modelos de Machine Learning que permitan obtener información de mayor valor.
- Investigar futuras funcionalidades de recomendación y personalización.

Estas posibilidades permitirían que Kefera no solo facilitase la gestión diaria de un restaurante, sino que también ayudase a comprender su actividad y tomar decisiones basadas en datos.

---

## 🏛️ Descripción general del proyecto

Kefera es una plataforma digital para la gestión y experiencia gastronómica que combina una aplicación Flutter, un backend desarrollado con Spring Boot, una base de datos PostgreSQL y un flujo de trabajo de Data Science en Python.

### Funcionalidades principales

**Frontend**
- Aplicación desarrollada con Flutter y Dart.
- Carta digital y navegación por categorías.
- Consulta de productos.
- Carrito de compra.
- Gestión del flujo de pedidos y pagos.
- División de cuenta entre comensales.

**Backend**
- API REST con Java y Spring Boot.
- Arquitectura organizada en controladores, servicios, repositorios y entidades.
- Gestión de mesas y sesiones.
- Persistencia de cuentas compartidas.

**Base de datos**
- PostgreSQL.
- Scripts de creación de esquemas.
- Scripts de inicialización y carga de datos.

**Data Science**
- Preparación y transformación de datos.
- Pipeline Raw, Silver y Gold.
- Análisis del catálogo.
- Segmentación de productos mediante K-Means.

## 🛠️ Tecnologías utilizadas

| Área | Tecnologías |
|---|---|
| Frontend | Flutter, Dart |
| Backend | Java, Spring Boot, Maven |
| Base de datos | PostgreSQL, SQL |
| Data Science | Python, Pandas, NumPy |
| Machine Learning | Scikit-learn, K-Means |
| Herramientas | Visual Studio Code, Git, GitHub |

## 📁 Estructura del proyecto

```text
TFM_Kefera_Entrega/
│
├── data/
│   ├── raw/
│   ├── silver/
│   └── gold/
│
├── docs/
│   └── entregas/
│
├── kefera/
│   ├── backend/
│   ├── frontend/
│   └── baseDatos/
│       ├── schema/
│       └── seed/
│
├── results/
├── src/
│   ├── 01_preparar_datos.py
│   └── 02_entrenar_modelo.py
│
├── requirements.txt
└── README.md
```

## ⚙️ Instalación y ejecución

### 1. Base de datos

Crear una base de datos PostgreSQL llamada `kefera` y ejecutar los scripts SQL de `kefera/baseDatos/schema/` en el orden correspondiente.

Después, ejecutar los scripts de inicialización de `kefera/baseDatos/seed/`.

### 2. Backend

Desde `kefera/backend`, configurar la variable de entorno `DB_PASSWORD` con la contraseña del usuario de PostgreSQL.

En PowerShell:

```powershell
$env:DB_PASSWORD = Read-Host "Contraseña de PostgreSQL"
```

Iniciar el servidor:

```powershell
.\mvnw.cmd spring-boot:run
```

El backend utiliza el puerto `8080`.

### 3. Frontend

Desde `kefera/frontend`:

```bash
flutter pub get
flutter run
```

### 4. Data Science

Desde la raíz del proyecto:

```bash
python -m venv .venv
pip install -r requirements.txt
```

Ejecutar los scripts:

```bash
python src/01_preparar_datos.py
python src/02_entrenar_modelo.py
```

Los resultados se almacenan en `results/`.

## 📚 Documentación

En `docs/` se encuentra la documentación técnica y académica del proyecto, incluyendo las entregas de producto, preparación de datos, Machine Learning, estado actual y pruebas funcionales.
