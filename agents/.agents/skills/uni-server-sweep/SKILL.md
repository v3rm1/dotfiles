---
name: uni-server-sweep
description: Plan, launch, monitor and collect multi-seed JAX MARL training sweeps on the university GPU server (SSH alias `uni-server`, 2× H200 slices, Docker containers, flock-guarded job queues per GPU, MLflow tracking). Use whenever the user wants to run experiments, seeds, ablations, scaling or hyperparameter sweeps for erls or marl_algos, asks "what's running on the server", "is the sweep done", "requeue failed runs", "how much GPU is free", or wants results pulled back for a paper — even if they say "cluster" or "Slurm" (the server has no Slurm).
---

# University server sweeps

## The setup (verified 2026-10-12)

- **Host**: `ssh uni-server`. No Slurm: jobs are plain processes on two GPUs (`NVIDIA H200-35C`, 35 GB slices, ids 0 and 1).
- **Containers**: Docker image `jax_dc`, started via `~/erls/docker/run` (`build`, `start <name> <gpu>`). Long-lived containers exist per project (e.g. `erls-holonic`, `marl-smax`); check with `docker ps`. Inside a container the project lives at `/home/varunrv/projects/<repo>` (the container's home is bind-mounted from `docker_home`); on the host it is `~/erls`, `~/marl_algos`.
- **Tracking**: MLflow on the server; reach it from the laptop with `ssh -N uni-mlflow-tunnel` (forwards `localhost:43210`). Experiments are named per paper (e.g. `erls-aamas2026-main`) and runs carry tags like `paper=`, `suite=`, `scenario=`, `variant=`, `seed=`.
- **Existing patterns** in `~/erls`: `*_lane0.sh`/`*_lane1.sh` (fixed sequential job list pinned to one GPU) and `*_sweep_worker.sh` + `*_queue.txt` + `*_queue.lock` (two workers, one per GPU, popping jobs from a shared queue). Read the newest worker script and copy its conventions rather than inventing new ones.

Always check current state before trusting this section: `ssh uni-server 'nvidia-smi; docker ps; ls ~/erls/*queue*.txt'`.

## Planning a sweep

1. Enumerate the grid explicitly: algorithms/variants × scenarios × the swept parameter × seeds. Default to ≥3 seeds (5 for headline results); a single seed cannot support a claim in the paper.
2. Estimate cost from previous logs of the same algorithm/scenario (wall time per run in `logs/<suite>/*.log`), then total ÷ 2 GPUs. Tell the user the estimate and the number of runs before launching.
3. Check GPU memory headroom with `nvidia-smi`. JAX preallocates; if another job shares a GPU, set `XLA_PYTHON_CLIENT_MEM_FRACTION` accordingly.

## Launching

Use the queue-worker pattern; it load-balances across GPUs and survives uneven run lengths.

1. Write `<suite>_queue.txt` with one job per line (space-separated fields the worker reads, e.g. `<algo> <variant> <config> <param> <seed>`).
2. Copy the latest `*_sweep_worker.sh` to `<suite>_sweep_worker.sh`; change the queue/lock names, the `python3 scripts/train.py ...` overrides, `--experiment`, `--tags` (always include `suite=<suite>` and `seed=`), and the log directory `logs/<suite>/`. Keep the XLA_FLAGS line as is.
3. Copy the files to the server (`scp` or `rsync` into `~/erls/`), then start one worker per GPU inside the project's container in a detached tmux session so it survives disconnects:

   ```bash
   ssh uni-server "docker exec -d erls-holonic bash -lc 'cd ~/projects/erls && tmux new -d -s <suite>_g0 \"bash <suite>_sweep_worker.sh 0 2>&1 | tee logs/<suite>/worker_g0.log\"'"
   ```

   Do the same for GPU 1. If other jobs are still running, pass a wait regex as the worker's second argument (use a `[x]` character class so it cannot match itself).

Confirm with the user before launching anything that will occupy both GPUs for hours, or that would kill or delay someone else's running job.

## Monitoring

- Progress: `wc -l <suite>_queue.txt` (jobs left), `grep -c '=== GPU.* done' logs/<suite>/worker_g*.log` (finished), `tail` the newest run log.
- Failures: grep worker logs for `exit=[1-9]`, and run logs for `Traceback`, `RESOURCE_EXHAUSTED`, `nan`. Requeue a failed job by appending its line back to the queue (under `flock`).
- Liveness: `pgrep -af scripts/train.py` inside the container; `nvidia-smi` utilisation near 0 for a long time means a hung or crashed worker.

## Collecting results

Query MLflow by experiment and tags (through the tunnel) with the `mlflow` client in the local project env (`pixi run python`), aggregate per variant/setting across seeds as mean ± std with n, and write a tidy CSV to `results/<suite>.csv` in the local repo. Note any missing seeds explicitly; the `paper-claims-check` skill relies on these numbers.

## Afterwards

Append a dated entry to the project's agent-memory node (`erls_marl/uni-server-compute-infra.md` or the paper node): what ran, where the results are, anything that failed.
