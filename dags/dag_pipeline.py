import sys
from datetime import datetime
from pathlib import Path

# Permite importar pipeline.py, que esta en la carpeta del proyecto (una arriba de dags/)
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import pipeline

try:  # Airflow 3
    from airflow.sdk import DAG
    from airflow.providers.standard.operators.python import PythonOperator
except ImportError:  # Airflow 2
    from airflow import DAG
    from airflow.operators.python import PythonOperator


with DAG(
    dag_id="pipeline_inscripciones",
    description="ETL del Instituto Horizonte: inscripciones y notas",
    schedule="0 2 * * *",  # minuto 0, hora 2, todos los dias: 2:00 AM
    start_date=datetime(2024, 1, 1),
    catchup=False,
) as dag:

    extraer_y_cargar = PythonOperator(
        task_id="extraer_y_cargar",
        python_callable=pipeline.extraer_y_cargar,
    )

    validar = PythonOperator(
        task_id="validar",
        python_callable=pipeline.validar,
    )

    limpiar = PythonOperator(
        task_id="limpiar",
        python_callable=pipeline.limpiar,
    )

    unir = PythonOperator(
        task_id="unir",
        python_callable=pipeline.unir,
    )

    consultas = PythonOperator(
        task_id="consultas",
        python_callable=pipeline.consultas,
    )

    extraer_y_cargar >> validar >> limpiar >> unir >> consultas
