# Ollama Simple Timmer 
A simple script that times how long each of the installed ollama models takes to respond to a prompt

```
Usage: ./ollama-simple-timer.sh -n REPS -d DWELL -m MODEL -p PROMPT -o OUTFILE

Options:
  -n REPS     Number of repetitions per model (default: 3)
  -d SEC      Dwell time in seconds between tests (default 3)
  -m MODEL    Test only this specific model (default: all models from 'ollama list')
  -p PROMPT   Prompt text to send into each ollama run (default: "Describe Yourself")
  -o OUTFILE  Output CSV file (default: output.YYYY.MM.DD.hh.mm.ss.csv)
  -h          Show this help and exit

Notes:
  * Uses POSIX 'time -p' and parses the 'real' line.
  * Suppresses all output from the ollama pipeline.
```

Output CSV

```
Model,Run1,Run2,Run3,Average
deepseek-r1:70b,81.69,33.87,31.93,49.163333
deepseek-v2:16b,16.39,9.26,10.42,12.023333
gemma3:1b,102.97,123.78,142.98,123.243333
gemma3:270m,6.88,9.48,16.43,10.930000
gemma3:27b,122.46,99.63,106.21,109.433333
gemma3:4b,87.14,118.82,83.10,96.353333
gpt-oss:120b,158.55,122.88,151.03,144.153333
gpt-oss:20b,91.66,69.21,70.13,77.000000
```

