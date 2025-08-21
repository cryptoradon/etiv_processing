#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 <process_name1> [process_name2] [...]"
  echo "Tip: Quote names with spaces, e.g. \"MCR Main thread\""
  exit 1
fi

# System info
CORE_COUNT=$(nproc)
TOTAL_RAM=$(free -m | awk '/Mem:/ {print $2}')
GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n1 2>/dev/null || echo "N/A")
TOTAL_GPU_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n1 2>/dev/null || echo 0)

# Combine process names into a label
PROCESS_LABEL=$(echo "$@" | tr ' ' '_' | tr -s '_')
LOGFILE="proc_${PROCESS_LABEL}_usage_sm_$(date +%Y%m%d_%H%M%S).csv"

# Header
{
  echo "# Process Names: $@"
  echo "# CPU Cores: $CORE_COUNT"
  echo "# Total System RAM (MB): $TOTAL_RAM"
  echo "# GPU Model: $GPU_NAME"
  echo "# Total GPU Memory (MiB): $TOTAL_GPU_MEM"
  echo "Time,Process_Name,PID,CPU_Usage(%),Memory_Usage(%),GPU_Mem_Used_by_PID(MiB)"
} > "$LOGFILE"

# Monitoring loop
while true; do
    TIME=$(date +%T)

    FOUND=false

    for PROC_NAME in "$@"; do
        # Find all PIDs whose full command line contains the process name
        PIDS=$(ps -eo pid,cmd | awk -v name="$PROC_NAME" '$0 ~ name {print $1}')

        [ -z "$PIDS" ] && continue
        FOUND=true

        for PID in $PIDS; do
            # CPU and memory usage
            CPU_MEM=$(ps -p $PID -o %cpu,%mem --no-headers 2>/dev/null | awk '{print $1","$2}')
            [ -z "$CPU_MEM" ] && continue

            # GPU memory used by this PID (compute only)
            GPU_MEM=$(nvidia-smi --query-compute-apps=pid,used_gpu_memory --format=csv,noheader,nounits | grep "^$PID" | awk -F, '{print $2}' | xargs)
            [ -z "$GPU_MEM" ] && GPU_MEM=0

            echo "$TIME,\"$PROC_NAME\",$PID,$CPU_MEM,$GPU_MEM" >> "$LOGFILE"
        done
    done

    if ! $FOUND; then
        echo "No matching processes found. Exiting."
        break
    fi

    sleep 1
done

echo "Monitoring stopped. Log saved to $LOGFILE"
