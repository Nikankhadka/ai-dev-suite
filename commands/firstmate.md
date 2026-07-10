---
description: Launch a firstmate tmux orchestration session for parallel agent crew
argument-hint: <objective>
agent: build
subtask: false
---

# Firstmate

Launch or attach to a firstmate orchestrated tmux session for: $ARGUMENTS

Firstmate is not a CLI tool. It is an orchestrator directory cloned to `~/firstmate` that uses tmux to run parallel agent sessions. Prerequisites: tmux, treehouse CLI, no-mistakes CLI, gh auth.

## Guard

Check that the firstmate home exists:

```
test -d ~/firstmate || { echo "firstmate not found at ~/firstmate - clone it first: git clone https://github.com/kunchenguid/firstmate ~/firstmate"; exit 1; }
```

Check that tmux is installed:

```
command -v tmux >/dev/null || { echo "tmux is required - install it: brew install tmux"; exit 1; }
```

## Usage

Read the firstmate README for the current setup and session types:

```
cat ~/firstmate/README.md
```

Then launch a firstmate session:

```
tmux new-session -s firstmate -c ~/firstmate
```

Or if a session already exists, attach to it:

```
tmux attach-session -t firstmate
```

Within the tmux session, follow the firstmate instructions for setting up parallel agent worktrees and orchestrating the crew.

Firstmate detects treehouse and no-mistakes automatically if they are on PATH.

(End of file - total 35 lines)
