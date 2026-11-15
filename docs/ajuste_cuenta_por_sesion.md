# Ajuste de cuenta compartida por sesión

La versión anterior guardaba el reparto por número de mesa. La estructura real de Kefera dispone de `mesas` y `sesiones_mesa`; por ello, esta versión lo asocia a `id_sesion`.

El backend resuelve la sesión que tenga estado `ABIERTA` y `fecha_cierre IS NULL` para el número de mesa solicitado. GET, PUT y DELETE trabajan sobre esa sesión. La tabla nueva usa `id_sesion` como clave primaria y clave foránea a `kefera.sesiones_mesa` con `ON DELETE CASCADE`.

Antes de probar, ejecutar `kefera/baseDatos/schema/07_schema_cuentas_compartidas.sql` en la base de datos `kefera`. No se modifica la tabla existente `division_cuentas`.

Limitaciones que siguen vigentes: la capacidad se introduce desde la pantalla; la aplicación Flutter usa el carrito local y las asignaciones guardan el índice del producto, por lo que los dispositivos deben tener el mismo carrito y orden de productos. No hay actualización en tiempo real ni cobro individual. El backend aún debe compilarse y probarse en el equipo de desarrollo.
