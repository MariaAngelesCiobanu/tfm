# Prueba manual - División de cuenta por consumiciones

## Preparación
1. Ejecutar Kefera y añadir varios productos al carrito.
2. Desde `PAGAR CUENTA` elegir `DIVIDIR CUENTA`.
3. Introducir un número de mesa y una capacidad.

## Caso de prueba
- Mesa: 4
- Capacidad: 4
- Comensales: Ana, Luis y Marta
- Producto A: 12,00 € asignado a Ana y Luis
- Producto B: 5,00 € asignado solo a Marta
- Producto C: 9,00 € asignado a Ana, Luis y Marta

Resultado esperado:
- Ana: 6,00 € + 3,00 € = 9,00 €
- Luis: 6,00 € + 3,00 € = 9,00 €
- Marta: 5,00 € + 3,00 € = 8,00 €
- Total: 26,00 €

## Validaciones
- No se pueden añadir más personas que la capacidad indicada.
- No se pueden añadir nombres vacíos ni duplicados.
- Se puede seleccionar a más de una persona por producto.
- No se permite mostrar el resumen hasta que todos los productos tengan al menos un comensal asignado.
- El reparto se ajusta al céntimo para que la suma de las partes coincida con el total de cada producto.

## Alcance conocido
Los participantes y asignaciones viven en el estado de la pantalla Flutter. No se guardan todavía en PostgreSQL ni se comparten entre móviles. El número de mesa y la capacidad se introducen manualmente, no se consultan aún desde la API de mesas.
