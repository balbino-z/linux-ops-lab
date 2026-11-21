# Learnings log

> Drafted by me at the end of every session; AI only fixes structure and English. If I can't explain it, I didn't learn it yet.

## 2026-11-21 — Scenario 01: disk full
**What I built / solved:** I solved my first Linux incident: uploads failing because the `/srv/data` volume was full.
**What I learned (explain like in an interview):** I start by confirming the impact with a realistic test, then go from general to specific: `df -h` shows which filesystem is full, `du -sh` shows which directory, `ls -lh` which file, and `lsof` plus `systemctl status` show which process and service are writing. Deleting a file that a process still has open does not free disk space; the space comes back only when the process closes it, and `lsof +L1` lists those files. `systemctl stop` turns a service off now, and `systemctl disable` stops it from starting at boot.
**What broke and how I diagnosed it:** `touch` worked even with the disk full, because it creates an empty file. After `rm`, `df` still showed 100%, and `lsof +L1` showed the deleted file still open by the service.
**What I still don't fully understand:** a bit of everything, since I'm new to Linux, but I can now repeat this diagnosis on my own.
**Next step:** Scenario 02 and the first version of my troubleshooting method doc.
