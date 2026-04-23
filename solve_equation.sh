#!/usr/bin/env bash
# solve_equation.sh — Finds a set of unique digits (1-9) satisfying an equation
# with the given operators and target result.

echo "==============================="
echo "  Equation Solver (digits 1-9)"
echo "==============================="

while true; do
  echo ""
  echo "Enter operators separated by spaces (e.g.: + - *):"
  read -r ops_input

  read -ra OPS <<< "$ops_input"
  NUM_OPS=${#OPS[@]}

  # Validate operators
  valid=true
  for op in "${OPS[@]}"; do
    if [[ "$op" != "+" && "$op" != "-" && "$op" != "*" ]]; then
      echo "Error: Invalid operator '$op'. Only +, -, * are supported."
      valid=false
      break
    fi
  done
  [[ "$valid" == false ]] && continue

  echo "Enter the target result:"
  read -r TARGET

  echo ""
  echo "Searching for a solution to: _ ${OPS[*]// / _ } _ = $TARGET"
  echo "(using distinct digits 1-9)"
  echo ""

  python3 - <<PYEOF
import itertools

ops    = "${ops_input}".split()
n      = len(ops) + 1
target = float("${TARGET}")
if target == int(target):
    target = int(target)

found = False
for perm in itertools.permutations(range(1, 10), n):
    expr = str(perm[0])
    for i, op in enumerate(ops):
        expr += op + str(perm[i+1])
    result = eval(expr)
    if result == target:
        eq_parts = [str(perm[0])]
        for i, op in enumerate(ops):
            eq_parts += [op, str(perm[i+1])]
        print("Solution found: " + " ".join(eq_parts) + " = " + str(target))
        found = True
        break

if not found:
    print("No solution found with unique digits 1-9 for the given operators and target.")
PYEOF

  echo ""
  echo "Press Enter to solve another, or N to quit:"
  read -r again
  if [[ "${again,,}" == "n" ]]; then
    echo "Goodbye!"
    break
  fi

done
