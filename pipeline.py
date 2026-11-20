import duckdb
from pathlib import Path

BASE = Path(__file__).resolve().parent
CSV = BASE / "datos" / "inscripciones.csv"
DB = BASE / "tp_instituto.duckdb"
SQL = BASE / "sql"


def leer_sql(archivo):
    texto = (SQL / archivo).read_text(encoding="utf-8")
    return texto.replace("{CSV}", str(CSV))


def extraer_y_cargar():
    con = duckdb.connect(str(DB))
    con.execute(leer_sql("extract.sql"))
    filas = con.execute("SELECT COUNT(*) FROM raw_inscripciones").fetchone()[0]
    con.close()
    return filas


def validar():
    con = duckdb.connect(str(DB))
    con.execute(leer_sql("validar.sql"))
    validos = con.execute("SELECT COUNT(*) FROM validos").fetchone()[0]
    rechazados = con.execute("SELECT COUNT(*) FROM rechazados").fetchone()[0]
    con.close()
    return validos, rechazados


def limpiar():
    con = duckdb.connect(str(DB))
    con.execute(leer_sql("limpiar.sql"))
    filas = con.execute("SELECT COUNT(*) FROM rechazados_limpios").fetchone()[0]
    con.close()
    return filas


def unir():
    con = duckdb.connect(str(DB))
    con.execute(leer_sql("unir.sql"))
    filas = con.execute("SELECT COUNT(*) FROM tabla_final").fetchone()[0]
    con.close()
    return filas


def consultas():
    con = duckdb.connect(str(DB))
    con.execute(leer_sql("consultas.sql"))
    con.close()


if __name__ == "__main__":
    print("Filas cargadas:", extraer_y_cargar())
    validos, rechazados = validar()
    print("Validos:", validos, "| Rechazados:", rechazados)
    print("Rechazados limpios:", limpiar())
    print("Filas en tabla_final:", unir())
    consultas()
    print("Consultas guardadas en las tablas consulta_1 ... consulta_5")
