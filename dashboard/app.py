from flask import Flask, render_template, jsonify
from pathlib import Path
import csv

app = Flask(__name__)

# Rutas del proyecto
RUTA_DASHBOARD = Path(__file__).resolve().parent
RUTA_PROYECTO = RUTA_DASHBOARD.parent
RUTA_CSV = RUTA_PROYECTO / "data" / "almacenamiento.csv"


def cargar_mediciones():
    """Carga el historial generado por monitor-almacenamiento.ps1."""

    if not RUTA_CSV.exists():
        return []

    mediciones = []

    with open(RUTA_CSV, "r", encoding="utf-8-sig", newline="") as archivo:
        lector = csv.DictReader(archivo)

        for fila in lector:
            try:
                mediciones.append({
                    "fecha": fila["Fecha"],
                    "archivos": int(fila["Archivos"]),
                    "biblioteca": float(fila["BibliotecaGB"].replace(",", ".")),
                    "usado": float(fila["DiscoUsadoGB"].replace(",", ".")),
                    "libre": float(fila["DiscoLibreGB"].replace(",", ".")),
                    "estado": fila["Estado"]
                })
            except (ValueError, KeyError):
                continue

    return mediciones


@app.route("/")
def inicio():
    return render_template("index.html")


@app.route("/api/almacenamiento")
def almacenamiento():
    mediciones = cargar_mediciones()

    if not mediciones:
        return jsonify({
            "disponible": False,
            "historial": []
        })

    return jsonify({
        "disponible": True,
        "actual": mediciones[-1],
        "historial": mediciones
    })


if __name__ == "__main__":
    print("Immich Homelab Dashboard")
    print("http://localhost:5000")
    app.run(host="127.0.0.1", port=5000, debug=True)