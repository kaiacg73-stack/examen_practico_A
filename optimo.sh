# optimo.sh - menor bloque que alcanza el 95 % de la tasa maxima. Uso: bash optimo.sh escritura.csv
awk -F';' 'NR > 1 { d[NR] = $1; b[NR] = $2; t[NR] = $4; if ($4 > m[$1]) m[$1] = $4 }
  END { for (i = 2; i <= NR; i++)
          if (!(d[i] in o) && t[i] >= 0.95 * m[d[i]]) { o[d[i]] = b[i]; v[d[i]] = t[i] }
        for (x in o) printf "%-6s bs optimo = %-5s %8.2f MiB/s (maximo %.2f)\n", x, o[x], v[x], m[x] }' "$1"
