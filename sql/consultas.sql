-- Etapa 5: preguntas de negocio, respondidas con SQL sobre tabla_final.
-- Cada respuesta queda guardada en su propia tabla (consulta_1 ... consulta_5).

-- 1. Cual es la nota final promedio por materia?
CREATE OR REPLACE TABLE consulta_1_nota_promedio_por_materia AS
SELECT materia,
       round(avg(nota_final), 2) AS nota_final_promedio
FROM tabla_final
GROUP BY materia
ORDER BY nota_final_promedio DESC, materia;

-- 2. Cual es el porcentaje de aprobacion por carrera?
CREATE OR REPLACE TABLE consulta_2_aprobacion_por_carrera AS
SELECT carrera,
       count(*) AS inscripciones,
       sum(CASE WHEN condicion = 'aprobado' THEN 1 ELSE 0 END) AS aprobados,
       round(100.0 * sum(CASE WHEN condicion = 'aprobado' THEN 1 ELSE 0 END) / count(*), 2) AS porcentaje_aprobacion
FROM tabla_final
GROUP BY carrera
ORDER BY porcentaje_aprobacion DESC, carrera;

-- 3. Cuales son los 5 alumnos (id_alumno) con mejor promedio de nota final (minimo 5 inscripciones)?
CREATE OR REPLACE TABLE consulta_3_top5_alumnos AS
SELECT id_alumno,
       count(*) AS inscripciones,
       round(avg(nota_final), 2) AS promedio_nota_final
FROM tabla_final
GROUP BY id_alumno
HAVING count(*) >= 5
ORDER BY avg(nota_final) DESC, id_alumno
LIMIT 5;

-- 4. Cuantas inscripciones hubo por mes (primeros 6 meses)?
CREATE OR REPLACE TABLE consulta_4_inscripciones_por_mes AS
SELECT strftime(fecha_inscripcion, '%Y-%m') AS mes,
       count(*) AS inscripciones
FROM tabla_final
GROUP BY mes
ORDER BY mes
LIMIT 6;

-- 5. Que materia tiene mas desaprobados?
CREATE OR REPLACE TABLE consulta_5_materia_con_mas_desaprobados AS
SELECT materia,
       count(*) AS desaprobados
FROM tabla_final
WHERE condicion = 'desaprobado'
GROUP BY materia
ORDER BY desaprobados DESC, materia
LIMIT 1;
