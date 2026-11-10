# graficas.py - Uso: python3 graficas.py  (en la carpeta de los CSV)
import csv
import matplotlib
matplotlib.use("Agg")                     # genera PNG sin abrir ventanas
import matplotlib.pyplot as plt

for op in ["escritura", "lectura"]:
    datos = {}                            # {dispositivo: [(bs, tiempo, tasa), ...]}
    with open(op + ".csv") as fh:
        for f in csv.DictReader(fh, delimiter=";"):
            datos.setdefault(f["DISPOSITIVO"], []).append(
                (f["BS"], float(f["Tiempo"]), float(f["Tasa"])))
    for col, i, uni in [("Tasa", 2, "MiB/s"), ("Tiempo", 1, "s")]:
        plt.figure(figsize=(9, 5))
        for dev, filas in datos.items():
            plt.plot([x[0] for x in filas], [x[i] for x in filas], marker="o", label=dev)
            for x in filas:               # etiqueta con el valor en cada punto
                plt.annotate(f"{x[i]:.0f}", (x[0], x[i]), fontsize=7,
                             textcoords="offset points", xytext=(0, 5), ha="center")
        plt.yscale("log")
        plt.xlabel("Tamaño de bloque (bs)")
        plt.ylabel(f"{col} ({uni})")
        plt.title(f"{col} de {op} de un fichero de 1 GiB")
        plt.grid(True, which="both", alpha=0.3)
        plt.legend()
        plt.savefig(f"{op}_{col.lower()}.png", dpi=150, bbox_inches="tight")
        print("Generada", f"{op}_{col.lower()}.png")
