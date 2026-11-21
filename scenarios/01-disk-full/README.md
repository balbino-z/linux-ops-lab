# Uploads fail with "No space left on device"

## The ticket
> **P2 · opened 09:12** — Since this morning users can't upload files. The app writes uploads to `/srv/data/uploads`
> and now fails with `No space left on device`. Nobody changed anything. The data volume is small but it has always been enough.

## Your job
1. Restore the service: a new file can be written to `/srv/data/uploads`.
2. Make sure it **stays** fixed — the problem must not come back a minute later.
3. Write `RUNBOOK.md` in this folder: symptom → diagnosis → root cause → fix → prevention.

```bash
./lab break 01     # start the incident
./lab shell        # investigate as the "ops" user (sudo works)
./lab check 01     # PASS when it is really fixed
```

Do not open `break.sh` before you finish — it gives the answer away.

## Hints (open one at a time, only if stuck)

<details><summary>Hint 1</summary>

Start by measuring, not guessing: how full is each filesystem, and which directories are the biggest?
</details>

<details><summary>Hint 2</summary>

Deleting a file does not always give the space back. Who is still holding it open?
</details>

<details><summary>Hint 3</summary>

If something keeps writing, cleaning up only buys you a few seconds. What is writing, and is it a service?
</details>
