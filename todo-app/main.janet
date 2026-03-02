(import string)
(import os)

(def data-file "tasks.txt")

(defn parse-task-line [line]
  (def line (string/trim line))
  (if (= "" line)
    nil
    (let [parts (string/split "|" line)]
      (when (< (length parts) 3)
        (errorf "Bad task line: %q" line))
      (def id (scan-number (get parts 0)))
      (def done (= (get parts 1) "1"))
      (def title (string/join (slice parts 2) "|"))
      @{:id id :done done :title title})))

(defn task->line [t]
  (string (get t :id) "|" (if (get t :done) "1" "0") "|" (get t :title)))

(defn load-tasks []
  (if (os/stat data-file)
    (let [lines (string/split "\n" (slurp data-file))
          out @[]]
      (each l lines
        (def t (parse-task-line l))
        (when t (array/push out t)))
      out)
    @[]))

(defn save-tasks [tasks]
  (var lines @[])
  (each t tasks
    (array/push lines (task->line t)))
  (spit data-file (string/join lines "\n")))

(defn next-id [tasks]
  (var m 0)
  (each t tasks
    (when (> (get t :id) m)
      (set m (get t :id))))
  (+ m 1))

(defn list-tasks []
  (def tasks (load-tasks))
  (if (= 0 (length tasks))
    (print "No tasks.")
    (each t tasks
      (printf "%d. [%s] %s"
              (get t :id)
              (if (get t :done) "x" " ")
              (get t :title)))))

(defn add-task [title]
  (def tasks (load-tasks))
  (def id (next-id tasks))
  (array/push tasks @{:id id :title title :done false})
  (save-tasks tasks)
  (print "Task added."))

(defn complete-task [id]
  (def tasks (load-tasks))
  (var found false)
  (each t tasks
    (when (= (get t :id) id)
      (put t :done true)
      (set found true)))
  (save-tasks tasks)
  (if found
    (print "Task marked as done.")
    (print "No task with that id.")))

(defn usage []
  (print "Usage:")
  (print "  janet main.janet list")
  (print "  janet main.janet add \"Task name\"")
  (print "  janet main.janet done <id>")
  (error "bad arguments"))

(defn main [& args]
  (when (< (length args) 2) (usage))
  (def cmd (get args 1))
  (cond
    (= cmd "list") (list-tasks)
    (= cmd "add")
    (do
      (when (< (length args) 3) (usage))
      (add-task (get args 2)))
    (= cmd "done")
    (do
      (when (< (length args) 3) (usage))
      (complete-task (scan-number (get args 2))))
    true (usage)))