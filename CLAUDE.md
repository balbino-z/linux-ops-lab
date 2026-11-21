# CLAUDE.md

## Who I am and how to work with me
I'm Vinícius, an IT Operations professional (24/7 Global Command Center) moving into Cloud Operations / SRE.
This repository is part of my public portfolio. I must be able to explain and defend every line in a job interview.

- Explain options and trade-offs BEFORE writing code; let me choose.
- Work in small steps, in branches, with small Conventional Commits (feat, fix, docs, ci, refactor, test, chore).
- After each step, ask me one question to check I understood.
- English for code, comments, docs and commits.

## Project
Reproducible Linux troubleshooting scenarios on a disposable Ubuntu 24.04 machine with real systemd (Docker).
Each scenario has a symptom README, `break.sh`, `check.sh` and a `RUNBOOK.md` that **I** write after solving.

## Hard rules for this repository
- NEVER reveal the cause or the fix of a scenario, and NEVER write or edit a `RUNBOOK.md`, unless I explicitly ask after solving it.
  When I'm stuck, give one hint at a time, from general to specific.
- `check.sh` tests outcomes (it works and keeps working), never one specific fix.
- Scenarios only touch the lab container. Disk scenarios use the 64 MB `/srv/data` volume.
- Every script is shellcheck-clean, uses `set -euo pipefail` where it makes sense, and is idempotent.
- A new scenario is done only when `tests/harness.sh <id>` passes (clean passes, broken fails).

## Commands
./lab up · ./lab break <id> · ./lab check <id> · ./lab reset · ./tests/harness.sh [id] · shellcheck lab tests/*.sh scenarios/*/*.sh
