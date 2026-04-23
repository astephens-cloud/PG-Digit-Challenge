# PG-Digit-Challenge
A bash script calculator to help study for the Digit Challenge Assessment

**Situation**
I had to take an online assessment for a P&G position.

**Task**
One of the assessments was a digit challenge, where numbers 1-9 could be used once and only once to make the preseneted expression true. This seemed like a good opportunity to write up a bash script to h                                                                                                                               re selected an acceptable solution.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
Here's the [script]([url](https://github.com/astephens-cloud/PG-Digit-Challenge/blob/main/solve_equation.sh))


Here's a full line-by-line breakdown of the script:

***

## The Shebang & Header

```bash
#!/usr/bin/env bash
```
Tells the OS to run this file using Bash. `env bash` finds the Bash binary wherever it lives on the system, making it more portable than hardcoding `/bin/bash`.

***

## The Banner

```bash
echo "==============================="
echo "  Equation Solver (digits 1-9)"
echo "==============================="
```
Prints a static title block to the terminal. Only runs once, outside the loop.

***

## The Main Loop

```bash
while true; do
```
Creates an infinite loop. The script keeps running until something explicitly breaks out of it (the `break` at the bottom). Every round of operator input → solve → prompt lives inside this loop.

***

## Operator Input

```bash
  echo ""
  echo "Enter operators separated by spaces (e.g.: + - *):"
  read -r ops_input
```
`read -r` reads a line from the user and stores it in `ops_input`. The `-r` flag prevents backslashes from being interpreted as escape characters — good practice for raw user input.

***

## Parsing Operators Into an Array

```bash
  read -ra OPS <<< "$ops_input"
  NUM_OPS=${#OPS[@]}
```
`read -ra OPS` splits `ops_input` by whitespace and loads each token into the array `OPS`. For example, `"+ -"` becomes `OPS=("+" "-")`. `${#OPS[@]}` counts how many elements are in the array (stored in `NUM_OPS`, though it's informational here).

***

## Operator Validation

```bash
  valid=true
  for op in "${OPS[@]}"; do
    if [[ "$op" != "+" && "$op" != "-" && "$op" != "*" ]]; then
      echo "Error: Invalid operator '$op'. Only +, -, * are supported."
      valid=false
      break
    fi
  done
  [[ "$valid" == false ]] && continue
```
Loops through each operator the user typed. If any one of them isn't `+`, `-`, or `*`, it sets `valid=false` and breaks out of the `for` loop early. The last line — `[[ "$valid" == false ]] && continue` — skips the rest of the `while` loop iteration and restarts it from the top, prompting for operators again.

***

## Target Input

```bash
  echo "Enter the target result:"
  read -r TARGET
```
Reads the desired equation result from the user. Same `-r` flag as before.

***

## Display the Equation Shape

```bash
  echo ""
  echo "Searching for a solution to: _ ${OPS[*]// / _ } _ = $TARGET"
  echo "(using distinct digits 1-9)"
  echo ""
```
`${OPS[*]// / _ }` is a Bash parameter expansion that joins all operators with ` _ ` between them — so `("+" "-")` becomes `+ _ -`, and wrapping it with `_ ` and ` _` gives `_ + _ - _ = 4`. This is purely cosmetic to show the equation shape before solving.

***

## The Python Heredoc

```bash
  python3 - <<PYEOF
```
Launches Python 3 and feeds it a block of code inline using a **heredoc** (`<<PYEOF ... PYEOF`). The `-` tells Python to read from stdin. This is the bridge between the Bash shell and Python's math capabilities.

***

## Python: Parse Inputs

```python
ops    = "${ops_input}".split()
n      = len(ops) + 1
target = float("${TARGET}")
if target == int(target):
    target = int(target)
```
`"${ops_input}"` and `"${TARGET}"` are Bash variables injected directly into the Python string at heredoc evaluation time. `.split()` turns the operator string into a Python list. `n` is the number of digit slots needed (always one more than the number of operators). The target is parsed as a float first, then converted to int if it's a whole number (so `4.0` becomes `4` for clean output).

***

## Python: Permutation Search

```python
for perm in itertools.permutations(range(1, 10), n):
```
`itertools.permutations(range(1, 10), n)` generates every ordered selection of `n` distinct digits from 1–9. For example, with `n=2` it tries `(1,2)`, `(1,3)`, `(2,1)`, etc. — 72 combinations. With `n=3` it tries 504 combinations. This guarantees no digit is reused.

***

## Python: Build & Evaluate the Expression

```python
    expr = str(perm[0])
    for i, op in enumerate(ops):
        expr += op + str(perm[i+1])
    result = eval(expr)
```
Assembles a string like `"1+3"` or `"3*7+9"` by concatenating digits and operators alternately. `eval()` hands that string to Python's math engine, which respects standard operator precedence (`*` before `+`/`-`).

***

## Python: Check & Print Result

```python
    if result == target:
        eq_parts = [str(perm[0])]
        for i, op in enumerate(ops):
            eq_parts += [op, str(perm[i+1])]
        print("Solution found: " + " ".join(eq_parts) + " = " + str(target))
        found = True
        break
```
If `result` matches `target`, it rebuilds the equation as a spaced list (e.g. `["1", "+", "3"]`) and joins it for clean output like `1 + 3 = 4`. Then it sets `found = True` and `break`s out of the permutation loop — stopping at the **first** valid solution.

***

## Python: No Solution Fallback

```python
if not found:
    print("No solution found with unique digits 1-9 for the given operators and target.")
```
If the entire permutation space was exhausted with no match, it reports that clearly.

***

## Play Again Prompt

```bash
  echo ""
  echo "Press Enter to solve another, or N to quit:"
  read -r again
  if [[ "${again,,}" == "n" ]]; then
    echo "Goodbye!"
    break
  fi
```
`read -r again` captures the user's response. `${again,,}` lowercases it so both `N` and `n` are accepted. If it matches `"n"`, `break` exits the `while true` loop and the script ends. Any other key (including just Enter, which produces an empty string) continues the loop and starts a fresh round.
