# Tiny Janet log parser

This is a small homework‑style Janet project that parses and summarizes
simple log files.

The format is deliberately uncomplicated:

```
2026-02-26 12:34:56 INFO auth User alice logged in
^^^^ ^^^^^ ^^^^^^^ ^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^
date time  level   comp message
```

- `date`: `YYYY-MM-DD`
- `time`: `HH:MM:SS`
- `level`: one of `DEBUG`, `INFO`, `WARN`, `ERROR`
- `component`: one word (like `auth`, `web`, `db`)
- `message`: rest of the line

## Files

- `main.janet` – CLI program that:
  - reads a log file
  - parses each line into a small table
  - prints a summary (counts per level/component, first/last timestamp)
  - or filters lines by a given level
- `example.log` – small sample log to play with

## Running

From the project root of the repo:

```bash
cd janet-log-parser
janet main.janet example.log summary
```

Or to only see errors:

```bash
janet main.janet example.log filter INFO
```

The code tries to stay straightforward and a bit manual on purpose,
so it is easier to read as a first Janet homework project.

