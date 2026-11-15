-- Ejecutar una sola vez en la base de datos Kefera (esquema kefera).
-- Una cuenta compartida pertenece a una sesión concreta de mesa.
-- Al cerrar/eliminar una sesión, PostgreSQL elimina también su reparto guardado.
CREATE TABLE IF NOT EXISTS kefera.cuentas_compartidas (
    id_sesion INTEGER PRIMARY KEY
        REFERENCES kefera.sesiones_mesa(id_sesion) ON DELETE CASCADE,
    capacidad INTEGER NOT NULL CHECK (capacidad > 0),
    datos JSONB NOT NULL,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

