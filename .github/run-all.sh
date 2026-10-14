#!/usr/bin/env bash
# ============================================================
#  Saare Java programs compile karke chalaata hai aur ek bada
#  markdown report banata hai. GitHub Actions isko call karta hai.
#  Aapke kisi .java file ko chhuta nahi - sirf build/ me output.
# ============================================================
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$ROOT/build"
REPORT="$BUILD/output-report.md"
TIMEOUT="${TIMEOUT:-5}"
RUN_GUI="${RUN_GUI:-false}"

rm -rf "$BUILD"
mkdir -p "$BUILD"
: > "$BUILD/results.tsv"

# ---------------------------------------------------------------- helpers ---
sample_input() {
  case "$1" in
    *Programs/Factorial.java)            printf '5\n' ;;
    *Programs/PrimeCheck.java)           printf '17\n' ;;
    *Programs/SumOfNaturalNumbers.java)  printf '10\n' ;;
    *Programs/ReverseArray.java)         printf '5\n10\n20\n30\n40\n50\n' ;;
    *Programs/MaxMinFinder.java)         printf '5\n12\n99\n4\n47\n3\n' ;;
    *Programs/MatrixAddition.java)       printf '2\n2\n1\n2\n3\n4\n5\n6\n7\n8\n' ;;
    *Programs/MatrixMultiplication.java) printf '2\n2\n2\n2\n1\n2\n3\n4\n5\n6\n7\n8\n' ;;
    *sandglass_pattern.java)             printf '5\n' ;;
    *Employee/Main.java)                 printf '101\nAbhijeet Kumar\nIT Department\n55000\n' ;;
    *)                                   printf '5\n1\n2\n3\n4\n5\nAbhijeet\nIT\n50000\n0\n' ;;
  esac
}

safe_id() { printf '%s' "$1" | sed 's/\.java$//' | tr '/' '_' | tr -c 'A-Za-z0-9_-' '_'; }

# Git Bash me javac/java native Windows binaries hain - unhe POSIX path
# (/c/Users/...) nahi, Windows path chahiye.
# GitHub Actions (Linux) pe ye kuch nahi karta, wahan path wahi rehta hai.
native_path() {
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$1"
  else
    printf '%s' "$1"
  fi
}

# Jis class me sach me main() hai wo dhoondho
# (Kruskal's\Graph.java jaise cases me file aur class ka naam alag hota hai)
find_main_class() {
  local outdir="$1" cls
  while IFS= read -r cls; do
    if javap -cp "$(native_path "$outdir")" "$cls" 2>/dev/null | grep -q 'public static void main'; then
      printf '%s' "$cls"
      return 0
    fi
  done < <(cd "$outdir" && find . -name '*.class' | sed 's|^\./||; s|\.class$||; s|/|.|g')
  return 1
}

# ------------------------------------------------------------- main loop ---
total=0; ok=0; failed=0; timeouts=0; skipped=0; compilefail=0
BODY=""

while IFS= read -r file; do
  rel="${file#"$ROOT"/}"
  total=$((total + 1))
  id="$(safe_id "$rel")"
  outdir="$BUILD/$id"
  mkdir -p "$outdir"

  # ---- compile ----
  if ! javac -nowarn -d "$(native_path "$outdir")" "$(native_path "$file")" > "$BUILD/$id.err" 2>&1; then
    compilefail=$((compilefail + 1))
    failed=$((failed + 1))
    printf '%s\t%s\t%s\n' "$rel" "COMPILE ERROR" "-" >> "$BUILD/results.tsv"
    BODY+=$'\n'"### $rel"$'\n\n'"**COMPILE ERROR**"$'\n\n''```'$'\n'"$(cat "$BUILD/$id.err")"$'\n''```'$'\n'
    continue
  fi

  fqcn="$(find_main_class "$outdir" || true)"
  if [ -z "$fqcn" ]; then
    failed=$((failed + 1))
    printf '%s\t%s\t%s\n' "$rel" "NO main()" "-" >> "$BUILD/results.tsv"
    BODY+=$'\n'"### $rel"$'\n\n'"**No main method found**"$'\n'
    continue
  fi

  # ---- GUI program? headless server pe nahi khulega ----
  if grep -qE 'javax\.swing|java\.awt' "$file" && [ "$RUN_GUI" != "true" ]; then
    skipped=$((skipped + 1))
    printf '%s\t%s\t%s\n' "$rel" "SKIPPED (GUI)" "$fqcn" >> "$BUILD/results.tsv"
    BODY+=$'\n'"### $rel"$'\n\n'"_GUI program (window khulti hai) - headless runner pe skip._"$'\n'
    continue
  fi

  # ---- run ----
  sample_input "$rel" > "$BUILD/$id.in"
  out_file="$BUILD/$id.out"

  timeout "$TIMEOUT" java -Djava.awt.headless=true -cp "$(native_path "$outdir")" "$fqcn" \
      < "$BUILD/$id.in" > "$out_file" 2>&1
  code=$?

  if [ "$code" -eq 124 ]; then
    status="TIME-LIMIT"; timeouts=$((timeouts + 1))
  elif [ "$code" -ne 0 ]; then
    status="RUNTIME ERROR"; failed=$((failed + 1))
  else
    status="OK"; ok=$((ok + 1))
  fi

  printf '%s\t%s\t%s\n' "$rel" "$status" "$fqcn" >> "$BUILD/results.tsv"

  body="$(cat "$out_file")"
  if [ ${#body} -gt 3000 ]; then
    body="${body:0:3000}"$'\n\n'"_... (aur baaki chhoda gaya)_"
  fi

  BODY+=$'\n'"### $rel"$'\n'"_class: \`$fqcn\` - **$status**_"$'\n\n''```'$'\n'"$body"$'\n''```'$'\n'
done < <(find "$ROOT" -name '*.java' -not -path '*/.git/*' -not -path "$BUILD/*" | sort)

# ------------------------------------------------------------- report -------
{
  echo "# Java Practice Programs - Output Report"
  echo
  echo "| Item | Value |"
  echo "|---|---|"
  echo "| Generated | $(date -u '+%d-%m-%Y %H:%M:%S UTC') |"
  echo "| Total programs | $total |"
  echo "| Compiled OK | $((total - compilefail)) |"
  echo "| Ran OK | $ok |"
  echo "| Runtime errors | $((failed - compilefail)) |"
  echo "| Time limit hit | $timeouts |"
  echo "| Skipped (GUI) | $skipped |"
  echo "| Time limit per program | ${TIMEOUT}s |"
  echo
  echo "## Status of every program"
  echo
  echo '| # | File | Status | Main class |'
  echo '|---|---|---|---|'
  awk -F'\t' '{printf "| %d | `%s` | %s | `%s` |\n", NR, $1, $2, $3}' "$BUILD/results.tsv"
  echo
  echo "## Output of every program"
  printf '%s' "$BODY"
} > "$REPORT"

# GitHub Actions me ye summary turant dikh jaati hai
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  cat "$REPORT" >> "$GITHUB_STEP_SUMMARY"
fi

echo "----------------------------------------------------------"
echo " Total programs : $total"
echo " Compiled OK    : $((total - compilefail))"
echo " Ran OK         : $ok"
echo " Runtime errors : $((failed - compilefail))"
echo " Time limit hit : $timeouts"
echo " Skipped (GUI)  : $skipped"
echo " Report         : $REPORT"
echo "----------------------------------------------------------"