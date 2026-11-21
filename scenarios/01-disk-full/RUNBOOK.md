# Runbook: Uploads fail with "No space left on device"

| | |
|---|---|
| **Severity** | P2: uploads were down for every user, but the rest of the site kept working |
| **Symptom** | Users could not upload files; the app failed with `No space left on device` when writing to `/srv/data/uploads` |
| **Time to resolve (mine)** | About 10 minutes of hands-on work (first scenario, guided) |

## 1. Confirm the impact
I reproduced the error as the web server user, writing a real 1 MB file:

```bash
sudo -u www-data dd if=/dev/zero of=/srv/data/uploads/test.bin bs=1M count=1
# dd: error writing '/srv/data/uploads/test.bin': No space left on device
```

My first test, `touch`, succeeded and fooled me: it creates an **empty** file, which needs no data space.
A good test does what the user really does, so I switched to `dd`.

## 2. Diagnosis by layers
| Layer | Command | What I saw | Conclusion |
|---|---|---|---|
| Filesystems | `df -h` | `/srv/data` 64M size, 64M used, 100% | Only the data volume is full, not the whole server |
| Directories | `sudo du -sh /srv/data/*` | `logs` 64M, `uploads` 0 | The uploads are not the problem; the logs are |
| Files | `ls -lh /srv/data/logs` | `report-worker-debug.log`, 64M, owner `www-data` | A single debug log filled the volume |
| Process | `sudo lsof /srv/data/logs/report-worker-debug.log` | PID 191 (`bash`) has the file open | Something is still writing to it |
| Service | `systemctl status 191` | `report-worker.service`, `enabled`, running for 20 min, 20 min of CPU time | A service writes nonstop (100% of one CPU core) and starts on boot |
| Test: delete | `sudo rm` the log, then `df -h /srv/data` and `sudo lsof +L1` | Still 100%; the file shows as `(deleted)` but open | Deleting does not free space while a process holds the file |

## 3. Root cause
The `report-worker` service had debug logging enabled and wrote to `/srv/data/logs/report-worker-debug.log` nonstop (100% of one CPU core), until it filled the 64 MB `/srv/data` volume. Because the service was `enabled` and running, deleting the file did not free the space: the process kept the deleted file open.

## 4. Fix
```bash
sudo systemctl stop report-worker      # stop the writer now; the process closes the file and the space is released
sudo systemctl disable report-worker   # stop it from starting again on the next boot (it was "enabled")
sudo rm /srv/data/uploads/test.bin     # clean up my test files
```

`stop` turns the service off now; `disable` removes its automatic start at boot. I needed both.

**In production** I would not stop a service blindly, because it may be important:
- To free the space immediately without stopping the service: `sudo truncate -s 0 /srv/data/logs/report-worker-debug.log` (empties the file while it stays open).
- Then fix the cause: turn off debug logging in the service configuration and restart it.

## 5. Verification
```bash
df -h /srv/data                        # usage back to ~0%
systemctl is-active report-worker      # inactive
systemctl is-enabled report-worker     # disabled
sudo -u www-data dd if=/dev/zero of=/srv/data/uploads/test.bin bs=1M count=1   # 1 MB written
./lab check 01                         # PASS (it also checks that the disk stays healthy for 15 s)
```

## 6. Prevention
- **No debug logging in production** unless someone is actively investigating, and with an end date.
- **logrotate** for every application log: rotate, compress and cap the size, so a log can never grow forever.
- **Disk alert at 80%** on every volume (Grafana, Zabbix or Datadog), so the team acts before users notice.
- **Runbook habit:** use `truncate` instead of `rm` on a log that a process is still writing.

## 7. What I learned / what tripped me up
- `touch` passed even with the disk full, because an empty file needs no data space. Test with real data.
- `rm` did not free any space, because the process still had the file open. `lsof +L1` shows those deleted-but-open files.
- The service is called *"Nightly report worker"*, but it was running all the time. Trust the data, not the name.
