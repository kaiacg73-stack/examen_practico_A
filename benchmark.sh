#!/bin/bash
# benchmark.sh - Primer parcial ICD. Uso: sudo bash benchmark.sh
# Genera escritura.csv y lectura.csv con el formato DISPOSITIVO;BS;Tiempo;Tasa
export LC_ALL=C                         # punto decimal y salida de dd en ingles
declare -A DIR=( [HDD]=/mnt/HDD [SDD]=/mnt/SDD [RAID5]=/mnt/RAID )
BLOQUES="1 2 4 8 16 32 64 128 256"      # tamanos de bloque en KiB
TAM_KIB=1048576                         # 1 GiB = 1048576 KiB

echo "DISPOSITIVO;BS;Tiempo;Tasa" > escritura.csv
echo "DISPOSITIVO;BS;Tiempo;Tasa" > lectura.csv

limpiar() { sync; echo 3 > /proc/sys/vm/drop_caches; }   # vacia la cache de RAM
ahora()   { date +%s.%N; }                                 # segundos con decimales
fila()    { awk -v d=$1 -v b=$2 -v a=$3 -v z=$4 -v m=$5 \
            'BEGIN { t = z - a; printf "%s;%s;%.3f;%.2f\n", d, b, t, m / t }'; }

for dev in HDD SDD RAID5; do
    ruta=${DIR[$dev]}
    mountpoint -q "$ruta" || { echo "ERROR: $ruta no esta montado"; continue; }
    for k in $BLOQUES; do
        f=$ruta/$(printf "BlockSize%03dk_FileSize1Gib.txt" $k)
        count=$(( TAM_KIB / k ))
        # Escritura: crear el fichero de 1 GiB con bloques de k KiB
        limpiar; t0=$(ahora)
        dd if=/dev/zero of=$f bs=${k}k count=$count conv=fdatasync status=none
        t1=$(ahora); fila $dev ${k}k $t0 $t1 $((TAM_KIB/1024)) >> escritura.csv
        # Lectura: leer el mismo fichero con el mismo bloque
        limpiar; t0=$(ahora)
        dd if=$f of=/dev/null bs=${k}k status=none
        t1=$(ahora); fila $dev ${k}k $t0 $t1 $((TAM_KIB/1024)) >> lectura.csv
        echo "$dev  bs=${k}k  hecho"
    done
done
cat escritura.csv; echo; cat lectura.csv
