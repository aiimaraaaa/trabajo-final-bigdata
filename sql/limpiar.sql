-- Etapa 3: limpiar los rechazados y guardar lo recuperado en rechazados_limpios.
-- Se corrige lo que se puede corregir:
--   * nombre: sin espacios sobrantes y con la primera letra de cada palabra en mayuscula
--   * fecha: DD/MM/YYYY pasa a fecha real (DATE)
--   * notas: valores de 20 a 100 son notas con el punto decimal perdido (42 -> 4.2)
--   * condicion: en minusculas y sin espacios; si falta, se deduce de nota_final (>= 6 aprobado)
-- Solo quedan en rechazados_limpios los registros que, ya corregidos, cumplen todas las reglas.

CREATE OR REPLACE TABLE rechazados_limpios AS
WITH limpio AS (
    SELECT
        id_inscripcion,
        id_alumno,
        array_to_string(
            list_transform(
                string_split(lower(regexp_replace(trim(nombre_alumno), '\s+', ' ', 'g')), ' '),
                lambda palabra: concat(upper(palabra[1]), palabra[2:])
            ), ' ') AS nombre_alumno,
        carrera,
        materia,
        CAST(coalesce(try_strptime(fecha_inscripcion, '%Y-%m-%d'),
                      try_strptime(fecha_inscripcion, '%d/%m/%Y')) AS DATE) AS fecha_inscripcion,
        CASE WHEN nota_parcial > 10 AND nota_parcial <= 100 THEN round(nota_parcial / 10, 1)
             ELSE nota_parcial END AS nota_parcial,
        CASE WHEN nota_final > 10 AND nota_final <= 100 THEN round(nota_final / 10, 1)
             ELSE nota_final END AS nota_final,
        lower(trim(condicion)) AS condicion_texto,
        motivo_rechazo
    FROM rechazados
),
con_condicion AS (
    SELECT *,
        CASE WHEN condicion_texto IN ('aprobado', 'desaprobado') THEN condicion_texto
             WHEN nota_final >= 6 THEN 'aprobado'
             WHEN nota_final < 6 THEN 'desaprobado'
        END AS condicion
    FROM limpio
)
SELECT id_inscripcion, id_alumno, nombre_alumno, carrera, materia,
       fecha_inscripcion, nota_parcial, nota_final, condicion, motivo_rechazo
FROM con_condicion
WHERE id_inscripcion IS NOT NULL
  AND id_alumno > 0
  AND nombre_alumno <> ''
  AND carrera IS NOT NULL
  AND materia IS NOT NULL
  AND fecha_inscripcion IS NOT NULL
  AND nota_parcial BETWEEN 1 AND 10
  AND nota_final BETWEEN 1 AND 10
  AND condicion IS NOT NULL
  AND (nota_final >= 6) = (condicion = 'aprobado');
