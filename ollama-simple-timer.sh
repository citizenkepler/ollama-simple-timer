#!/bin/sh

# --- defaults ---
REPS=3
OUT="output.$(date +%Y-%m-%d.%H:%M:%S).csv"
PROMPT="Describe Yourself"
MODEL=""
DWELL=3

usage() {
    cat <<EOF
Usage: $0 -n REPS -d DWELL-o OUTFILE -p PROMPT -m MODEL 

Options:
  -n REPS     Number of repetitions per model (default: $REPS)
  -o OUTFILE  Output CSV file (default: output.YYYY.MM.DD.hh.mm.ss.csv)
  -p PROMPT   Prompt text to send into each ollama run (default: "$PROMPT")
  -m MODEL    Test only this specific model (default: all models from 'ollama list')
  -d SEC      Dwell time in seconds between tests (default $DWELL)
  -h          Show this help and exit

Notes:
  * Uses POSIX 'time -p' and parses the 'real' line.
  * Suppresses all output from the ollama pipeline.
EOF
}

# --- show help if no arguments ---
if [ $# -eq 0 ]; then
    usage
    exit 0
fi

# --- parse options ---
while getopts "n:o:p:m:d:h" opt; do
    case "$opt" in
        n) REPS=$OPTARG ;;
        o) OUT=$OPTARG ;;
        p) PROMPT=$OPTARG ;;
        m) MODEL=$OPTARG ;;
        d) DWELL=$OPTARG ;;
        h) usage; exit 0 ;;
        \?) usage >&2; exit 2 ;;
    esac
done

# --- validate REPS ---
case "$REPS" in
    ''|*[!0-9]*)
        echo "Error: REPS must be a positive integer" >&2
        exit 2
        ;;
esac

if [ "$REPS" -le 0 ]; then
    echo "Error: REPS must be > 0" >&2
    exit 2
fi

# --- determine model list ---
if [ -n "$MODEL" ]; then
    MODEL_LIST=$MODEL
else
    MODEL_LIST=$(ollama list | awk 'NR>1{print $1}' | sort)
fi

# --- header row ---
{
    printf "Model"
    i=1
    while [ "$i" -le "$REPS" ]; do
        printf ",Run%d" "$i"
        i=$((i + 1))
    done
    printf ",Average\n"

    # --- data rows ---
    echo "$MODEL_LIST" | while IFS= read -r model; do
        [ -z "$model" ] && continue
        row=$model
        sum=0

        i=1
        while [ "$i" -le "$REPS" ]; do
            secs=$({ time -p sh -c 'echo "$2" | ollama run "$1" >/dev/null 2>/dev/null' sh "$model" "$PROMPT"; } 2>&1 \
                   | awk '/^real[[:space:]]/{print $2; exit}')
            row="$row,$secs"
            sum=$(awk -v s="$sum" -v x="$secs" 'BEGIN{print s + x}')
            i=$((i + 1))
            sleep $DWELL
        done

        avg=$(awk -v s="$sum" -v n="$REPS" 'BEGIN{if(n>0){printf "%.6f", s/n}else{print "NA"}}')
        row="$row,$avg"
        printf "%s\n" "$row"
    done
} | tee "$OUT"

echo "wrote: $OUT"