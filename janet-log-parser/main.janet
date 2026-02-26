#!/usr/bin/env janet

# Very small log parser / summarizer for a made‑up log format.
# This is intentionally simple and a bit "manual", as you might
# see in a small homework project rather than a library.
#
# Expected log line format:
#   2026-02-26 12:34:56 INFO auth User alice logged in
#
# Fields (space separated):
#   1: date        (YYYY-MM-DD)
#   2: time        (HH:MM:SS)
#   3: level       (INFO, WARN, ERROR, DEBUG)
#   4: component   (a single word, like "auth" or "api")
#   5+: message    (rest of the line)

(def levels
  @["DEBUG" "INFO" "WARN" "ERROR"])

(defn parse-line [line]
  (let [line (string/trim line)]
    (if (= "" line)
      nil
      (let [parts (string/split " " line)]
        (when (< (length parts) 5)
          (errorf "Bad log line (expected at least 5 fields): %q" line))
        (let [date (get parts 0)
              time (get parts 1)
              level (get parts 2)
              component (get parts 3)
              message (string/join (slice parts 4) " ")]
          @{ :date date
             :time time
             :level level
             :component component
             :message message
             :raw line })))))

(defn load-log-file [path]
  (def text (slurp path))
  (def lines (string/split "\n" text))
  (var out @[])
  (each l lines
    (def entry (parse-line l))
    (when entry
      (array/push out entry)))
  out)

(defn summarize [entries]
  (var total 0)
  (var level-counts @{})
  (var component-counts @{})
  (var first-ts nil)
  (var last-ts nil)

  (defn bump [tbl key]
    (put tbl key (inc (get tbl key 0))))

  (each e entries
    (++ total)
    (def lvl (get e :level))
    (def comp (get e :component))
    (bump level-counts lvl)
    (bump component-counts comp)
    (def ts (string (get e :date) " " (get e :time)))
    (when (or (nil? first-ts) (< ts first-ts))
      (set first-ts ts))
    (when (or (nil? last-ts) (> ts last-ts))
      (set last-ts ts)))

  @{ :total total
     :level-counts level-counts
     :component-counts component-counts
     :first-ts first-ts
     :last-ts last-ts })

(defn print-summary [summary]
  (print "=== Log summary ===")
  (printf "Total lines: %d" (get summary :total))
  (def first-ts (get summary :first-ts))
  (when first-ts
    (printf "First timestamp: %s" first-ts))
  (def last-ts (get summary :last-ts))
  (when last-ts
    (printf "Last timestamp: %s" last-ts))
  (print "")
  (print "Per level:")
  (each k levels
    (printf "  %s: %d" k (get-in summary [:level-counts k] 0)))
  (print "")
  (print "Per component:")
  (each [k v] (pairs (get summary :component-counts))
    (printf "  %s: %d" k v)))

(defn filter-by-level [entries level]
  (var out @[])
  (each e entries
    (when (= (get e :level) level)
      (array/push out e)))
  out)

(defn print-entries [entries]
  (each e entries
    (print (get e :raw))))

(defn usage []
  (print "Usage:")
  (print "  janet main.janet <logfile> summary")
  (print "  janet main.janet <logfile> filter <LEVEL>")
  (print "")
  (print "Examples:")
  (print "  janet main.janet example.log summary")
  (print "  janet main.janet example.log filter ERROR")
  (error "bad arguments"))

(defn main [& args]
  (when (< (length args) 3)
    (usage))

  (def script (get args 0))
  (def logfile (get args 1))
  (def command (get args 2))

  (def entries (load-log-file logfile))

  (match command
    "summary"
    (print-summary (summarize entries))

    "filter"
    (do
      (when (< (length args) 4)
        (print "Missing level for filter command.")
        (usage))
      (def lvl (get args 3))
      (if (not (some |(= lvl $) levels))
        (do
          (printf "Unknown level %q, expected one of: %q" lvl levels)
          (error "unknown level"))
        (print-entries (filter-by-level entries lvl))))

    _
    (do
      (printf "Unknown command %q" command)
      (usage))))

