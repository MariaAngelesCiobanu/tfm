package com.kefera.backend.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/cuentas-compartidas")
@CrossOrigin(origins = "*")
public class CuentaCompartidaController {

    private final JdbcTemplate jdbc;
    private final ObjectMapper mapper;

    public CuentaCompartidaController(JdbcTemplate jdbc, ObjectMapper mapper) {
        this.jdbc = jdbc;
        this.mapper = mapper;
    }

    // La cuenta se identifica por la sesión ABIERTA de la mesa, no solo por su número.
    private int obtenerSesionAbierta(int numeroMesa) {
        try {
            return jdbc.queryForObject("""
                SELECT s.id_sesion
                FROM kefera.mesas m
                JOIN kefera.sesiones_mesa s ON s.id_mesa = m.id_mesa
                WHERE m.numero_mesa = ?
                  AND UPPER(COALESCE(s.estado, '')) = 'ABIERTA'
                  AND s.fecha_cierre IS NULL
                ORDER BY s.fecha_apertura DESC
                LIMIT 1
                """, Integer.class, numeroMesa);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                "No hay una sesión abierta para la mesa " + numeroMesa);
        }
    }

    @GetMapping("/mesa/{numeroMesa}")
    public Map<String, Object> obtener(@PathVariable int numeroMesa) {
        int idSesion = obtenerSesionAbierta(numeroMesa);
        return jdbc.query(
            "SELECT capacidad, datos, actualizado_en FROM kefera.cuentas_compartidas WHERE id_sesion = ?",
            rs -> {
                if (!rs.next()) {
                    throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "No hay una cuenta compartida guardada para la sesión actual");
                }
                try {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> datos = mapper.readValue(rs.getString("datos"), Map.class);
                    datos.put("numeroMesa", numeroMesa);
                    datos.put("idSesion", idSesion);
                    datos.put("capacidad", rs.getInt("capacidad"));
                    Timestamp actualizado = rs.getTimestamp("actualizado_en");
                    datos.put("actualizadoEn", actualizado == null ? null : actualizado.toString());
                    return datos;
                } catch (Exception e) {
                    throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                        "No se pudo leer la cuenta compartida");
                }
            }, idSesion
        );
    }

    @PutMapping("/mesa/{numeroMesa}")
    public Map<String, Object> guardar(
        @PathVariable int numeroMesa,
        @RequestBody Map<String, Object> payload
    ) {
        if (numeroMesa < 1) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Número de mesa no válido");
        }
        Object capacidadObj = payload.get("capacidad");
        if (!(capacidadObj instanceof Number) || ((Number) capacidadObj).intValue() < 1) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Capacidad no válida");
        }
        int idSesion = obtenerSesionAbierta(numeroMesa);
        try {
            String json = mapper.writeValueAsString(payload);
            int capacidad = ((Number) capacidadObj).intValue();
            jdbc.update("""
                INSERT INTO kefera.cuentas_compartidas (id_sesion, capacidad, datos, actualizado_en)
                VALUES (?, ?, ?::jsonb, ?)
                ON CONFLICT (id_sesion) DO UPDATE
                SET capacidad = EXCLUDED.capacidad,
                    datos = EXCLUDED.datos,
                    actualizado_en = EXCLUDED.actualizado_en
                """, idSesion, capacidad, json, Timestamp.valueOf(LocalDateTime.now()));
            return Map.of("guardado", true, "numeroMesa", numeroMesa,
                "idSesion", idSesion, "capacidad", capacidad);
        } catch (JsonProcessingException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Formato de cuenta no válido");
        }
    }

    @DeleteMapping("/mesa/{numeroMesa}")
    public Map<String, Object> cerrar(@PathVariable int numeroMesa) {
        int idSesion = obtenerSesionAbierta(numeroMesa);
        int borradas = jdbc.update(
            "DELETE FROM kefera.cuentas_compartidas WHERE id_sesion = ?", idSesion);
        return Map.of("cerrada", borradas > 0, "numeroMesa", numeroMesa, "idSesion", idSesion);
    }
}
