-- Etapa 2: validar raw_inscripciones con reglas que tienen nombre.
-- Un registro va a "validos" solo si cumple TODAS las reglas.
-- Si falla alguna, va a "rechazados" y la columna motivo_rechazo lista las reglas que fallo.

CREATE OR REPLACE TEMP TABLE evaluados AS
SELECT
    id_inscripcion,
    id_alumno,
    nombre_alumno,
    carrera,
    materia,
    fecha_inscripcion,
    nota_parcial,
    nota_final,
    condicion,
    nullif(concat_ws('; ',
        -- no nulo
        CASE WHEN id_inscripcion IS NULL OR trim(id_inscripcion) = '' THEN 'id_inscripcion_nulo' END,
        -- no duplicado (se conserva la primera aparicion de cada id)
        CASE WHEN row_number() OVER (PARTITION BY id_inscripcion ORDER BY rowid) > 1 THEN 'id_inscripcion_duplicado' END,
        -- numero > 0
        CASE WHEN id_alumno IS NULL OR id_alumno <= 0 THEN 'id_alumno_no_positivo' END,
        -- no nulo
        CASE WHEN nombre_alumno IS NULL OR trim(nombre_alumno) = '' THEN 'nombre_alumno_nulo' END,
        CASE WHEN carrera IS NULL OR trim(carrera) = '' THEN 'carrera_nula' END,
        CASE WHEN materia IS NULL OR trim(materia) = '' THEN 'materia_nula' END,
        -- formato de texto
        CASE WHEN nombre_alumno <> regexp_replace(trim(nombre_alumno), '\s+', ' ', 'g') THEN 'nombre_alumno_con_espacios' END,
        CASE WHEN nombre_alumno = upper(nombre_alumno) THEN 'nombre_alumno_en_mayusculas' END,
        -- fecha valida (YYYY-MM-DD)
        CASE WHEN try_strptime(fecha_inscripcion, '%Y-%m-%d') IS NULL THEN 'fecha_formato_invalido' END,
        -- notas entre 1 y 10
        CASE WHEN nota_parcial IS NULL OR nota_parcial NOT BETWEEN 1 AND 10 THEN 'nota_parcial_fuera_de_rango' END,
        CASE WHEN nota_final IS NULL OR nota_final NOT BETWEEN 1 AND 10 THEN 'nota_final_fuera_de_rango' END,
        -- valor permitido: aprobado / desaprobado
        CASE WHEN condicion IS NULL THEN 'condicion_nula' END,
        CASE WHEN condicion IS NOT NULL AND condicion NOT IN ('aprobado', 'desaprobado') THEN 'condicion_no_permitida' END,
        -- coherencia: aprobado si nota_final >= 6
        CASE WHEN nota_final BETWEEN 1 AND 10
                  AND lower(trim(condicion)) IN ('aprobado', 'desaprobado')
                  AND (nota_final >= 6) <> (lower(trim(condicion)) = 'aprobado')
             THEN 'condicion_inconsistente_con_nota_final' END
    ), '') AS motivo_rechazo
FROM raw_inscripciones;

CREATE OR REPLACE TABLE validos AS
SELECT id_inscripcion, id_alumno, nombre_alumno, carrera, materia,
       fecha_inscripcion, nota_parcial, nota_final, condicion
FROM evaluados
WHERE motivo_rechazo IS NULL;

CREATE OR REPLACE TABLE rechazados AS
SELECT *
FROM evaluados
WHERE motivo_rechazo IS NOT NULL;
