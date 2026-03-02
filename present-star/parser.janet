(use spork gp/data/schema)

(defmacro </>
  "Captures one elemnt"
  [el]
  ~(fn ,(symbol el) [& c] [,el ;c]))

(defn parse-deck
  "Parses deck string"
  [str]
  (defn <footer/>
    [& fm-arr]
    (def h (table ;(flatten fm-arr)))
    [:footer
     [:h1 (h "title")]
     [:span (h "date")]
     [:span (h "author")]])
  (defn <a/>
    [label href]
    [:a {:href href :target "_blank"} label])
  (defn <img/>
    [alt src]
    [:img {:src src :alt alt}])
  (def grammar
    ~{:eol (+ "\n" "\r\n")
      :2eol (* :eol :eol)
      :rest (cmt '(to -1) ,(</> :error))
      :div "---"
      :kv (group (* '(some (if-not (+ :eol ":") 1)) ":" :s* '(to :eol)))
      :frontmatter (cmt (some (* :kv :eol)) ,<footer/>)
      :slide-end (+ (* (? :eol) :div (? :eol)) -1)
      :h1 (cmt (* "#" :s* '(to (+ :eol -1))) ,(</> :h1))
      :h2 (cmt (* "##" :s* '(to (+ :eol -1))) ,(</> :h2))
      :li (cmt (* "*" :s* '(to (+ :eol -1))) ,(</> :li))
      :li-a (cmt (cmt (* "*" :s* '(some (if-not (+ :eol "[") 1)) "[" '(to "]") "]" (+ :eol -1)) ,<a/>) ,(</> :li))
      :ul (cmt (some (* (+ :li-a :li) (? :eol))) ,(</> :ul))
      :img (cmt (* "!" :s* '(some (if-not (+ :eol "[") 1)) "[" '(to "]") "]" (+ :eol -1)) ,<img/>)
      :quote (cmt (* ">" :s* '(to (+ :eol -1))) ,(</> :quote))
      :slide (cmt (* (some (* (+ :h2 :h1 :ul :img :quote) (? :eol))) :slide-end) ,(</> :section))
      :slides (some :slide)
      :main (* :frontmatter :div :eol :slides)})
  (def [f & s] (peg/match grammar str))
  [:main ;s f])


# --- Demo: Multi-criteria log query (no runtime required) ---

(def demo-logs
  [
    {:date "2026-01-01" :time "10:00:00" :level "INFO"  :component "web" :message "Server started"}
    {:date "2026-01-01" :time "10:05:00" :level "ERROR" :component "db"  :message "Connection failed"}
    {:date "2026-01-01" :time "10:10:00" :level "DEBUG" :component "web" :message "User login attempt"}
    {:date "2026-01-01" :time "10:15:00" :level "ERROR" :component "web" :message "Timeout error"}
  ])

(defn query-logs [level component]
  (filter
    (fn [log]
      (and
        (or (nil? level) (= (get log :level) level))
        (or (nil? component) (= (get log :component) component))))
    demo-logs))

# Example usage (optional - can stay, doesn't need to be run)
# (print (query-logs "ERROR" nil))
# (print (query-logs "ERROR" "web"))