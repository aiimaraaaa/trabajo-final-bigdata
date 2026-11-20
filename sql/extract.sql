-- Etapa 1: extraer el CSV original y cargarlo TAL CUAL en DuckDB (sin cambiar nada).
-- {CSV} es reemplazado por pipeline.py con la ruta absoluta de datos/inscripciones.csv.
CREATE OR REPLACE TABLE raw_inscripciones AS
SELECT * FROM read_csv_auto('{CSV}');
