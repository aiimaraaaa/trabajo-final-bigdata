-- Etapa 4: unir validos + rechazados_limpios en tabla_final.
-- Sin ids repetidos (si un id aparece mas de una vez se conserva el de validos)
-- y con los tipos correctos: fecha = DATE, id_alumno = INTEGER, notas = DOUBLE.

CREATE OR REPLACE TABLE tabla_final AS
SELECT id_inscripcion, id_alumno, nombre_alumno, carrera, materia,
       fecha_inscripcion, nota_parcial, nota_final, condicion
FROM (
    SELECT id_inscripcion,
           CAST(id_alumno AS INTEGER) AS id_alumno,
           nombre_alumno,
           carrera,
           materia,
           CAST(fecha_inscripcion AS DATE) AS fecha_inscripcion,
           CAST(nota_parcial AS DOUBLE) AS nota_parcial,
           CAST(nota_final AS DOUBLE) AS nota_final,
           condicion,
           1 AS prioridad
    FROM validos
    UNION ALL
    SELECT id_inscripcion,
           CAST(id_alumno AS INTEGER),
           nombre_alumno,
           carrera,
           materia,
           CAST(fecha_inscripcion AS DATE),
           CAST(nota_parcial AS DOUBLE),
           CAST(nota_final AS DOUBLE),
           condicion,
           2
    FROM rechazados_limpios
)
QUALIFY row_number() OVER (PARTITION BY id_inscripcion ORDER BY prioridad) = 1
ORDER BY id_inscripcion;
