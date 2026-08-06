#!/usr/bin/env bash
# Full production run. Timing goes single-threaded on purpose; everything else
# uses a healthy but not greedy slice of the machine.
set -u
cd "$(dirname "$0")"
THREADS=${THREADS:-48}
mkdir -p data logs

run() {
  local name=$1; shift
  local nt=$1; shift
  echo "=== $name (threads=$nt) start $(date '+%F %T') ==="
  julia --project=. -t "$nt" "scripts/$name.jl" > "logs/$name.log" 2>&1
  echo "=== $name exit=$? end $(date '+%F %T') ==="
}

run virial     "$THREADS"
run nterms     "$THREADS"
run errors     "$THREADS"
run softening  "$THREADS"
run evolution  "$THREADS"
run relaxation "$THREADS"
run animations "$THREADS"
run timing     1

echo "ALL DONE $(date '+%F %T')"
ls -la data/
