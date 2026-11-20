# Informe: pipeline ETL de inscripciones y notas (Instituto Superior Horizonte)

El pipeline lee `datos/inscripciones.csv` (2575 filas, sin modificarlo), lo carga en DuckDB, valida con 14 reglas, recupera lo rechazado y deja una `tabla_final` de **2500 inscripciones** únicas y con tipos correctos. Se ejecuta con Airflow todos los días a las 2:00 AM (`0 2 * * *`).

## 1. Problemas encontrados

| Problema | Registros | Cómo se resolvió |
|---|---:|---|
| `id_inscripcion` repetido (copias exactas) | 75 | Se conserva una sola fila por id |
| Fecha en formato `DD/MM/YYYY` | 257 | Se convierte a `DATE` (ningún valor tiene el 2.º número mayor a 12, así que es día/mes) |
| Nota parcial fuera de rango (20 a 99) | 131 | Se había perdido el punto decimal: 42 pasa a 4,2 |
| Nota final fuera de rango (20 a 99) | 154 | Igual: se divide por 10 |
| `condicion` vacía | 155 | Se deduce de `nota_final` (>= 6 aprobado) |
| `condicion` con mayúsculas o espacios | 128 | Minúsculas y sin espacios |
| Nombre con espacios sobrantes | 138 | Se quitan los espacios |
| Nombre todo en mayúsculas | 207 | Primera letra de cada palabra en mayúscula |

## 2. Registros rechazados por regla

Se rechazaron **1075** registros de 2575. Un registro puede fallar más de una regla (164 fallan más de una), por eso la suma de la tabla es mayor.

| Regla | Rechazados | Regla | Rechazados |
|---|---:|---|---:|
| `id_inscripcion_nulo` | 0 | `nombre_alumno_en_mayusculas` | 207 |
| `id_inscripcion_duplicado` | 75 | `fecha_formato_invalido` | 257 |
| `id_alumno_no_positivo` | 0 | `nota_parcial_fuera_de_rango` | 131 |
| `nombre_alumno_nulo` | 0 | `nota_final_fuera_de_rango` | 154 |
| `carrera_nula` | 0 | `condicion_nula` | 155 |
| `materia_nula` | 0 | `condicion_no_permitida` | 128 |
| `nombre_alumno_con_espacios` | 138 | `condicion_inconsistente_con_nota_final` | 0 |

Conciliación: 2575 cargados = 1500 válidos + 1075 rechazados. Los 1075 rechazados se recuperaron (1075 en `rechazados_limpios`). Al unir se descartan las 75 copias repetidas: 2500 filas en `tabla_final` = 2575 − 75.

## 3. Respuestas a las preguntas de negocio

1. **Nota final promedio por materia:** Estadistica 6,06; Matematica 6,05; Sistemas Operativos 6,05; Base de Datos 5,99; Ingles Tecnico 5,98; Python para Datos 5,96; Programacion 1 5,83; Redes 1 5,76.
2. **Porcentaje de aprobación por carrera:** Analista de Datos 53,83 %; Tecnicatura en Redes 49,56 %; Tecnicatura en Software 44,22 %.
3. **Top 5 de alumnos por promedio de nota final (mínimo 5 inscripciones):** alumno 244 (8,52); alumno 157 (7,90); alumno 15 (7,89); alumno 58 (7,88); alumno 245 (7,85) (el alumno 340 también tiene 7,85: se desempató por `id_alumno`).
4. **Inscripciones por mes (enero a junio de 2024):** 2024-01: 114; 2024-02: 102; 2024-03: 98; 2024-04: 109; 2024-05: 103; 2024-06: 119.
5. **Materia con más desaprobados:** Matematica (293 desaprobados).
