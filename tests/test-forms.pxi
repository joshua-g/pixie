(ns pixie.tests.test-forms
  (require pixie.test :as t))

(t/deftest test-when
  (t/assert= (when false :never) nil)
  (t/assert= (when nil :never) nil)
  (t/assert= (when (= 3 4) :never) nil)

  (t/assert= (when true :always) :always)
  (t/assert= (when (+ 3 4) :always) :always)
  (t/assert= (when {} :always) :always)

  (let [c (atom 0)]
    (when (= 3 3)
      (swap! c inc)
      (swap! c inc)
      (swap! c inc))
    (t/assert= @c 3)))

(t/deftest test-when-not
  (t/assert= (when-not false :always) :always)
  (t/assert= (when-not nil :always) :always)
  (t/assert= (when-not (= 3 4) :always) :always)

  (t/assert= (when-not true :never) nil)
  (t/assert= (when-not (+ 3 4) :never) nil)
  (t/assert= (when-not {} :never) nil)

  (let [c (atom 0)]
    (when-not (= 3 4)
      (swap! c inc)
      (swap! c inc)
      (swap! c inc))
    (t/assert= @c 3)))

(t/deftest test-when-let
  (t/assert= (when-let [v false] :never) nil)
  (t/assert= (when-let [v nil] :never) nil)
  (t/assert= (when-let [v (= 3 4)] :never) nil)

  (t/assert= (when-let [v true] :always) :always)
  (t/assert= (when-let [v (+ 3 4)] :always) :always)
  (t/assert= (when-let [v {}] :always) :always)

  (let [c (atom 0)]
    (when-let [v @c]
      (swap! c inc)
      (swap! c inc)
      (swap! c inc))
    (t/assert= @c 3)))

(t/deftest test-if-let
  (t/assert= (if-let [v false] :yay :nay) :nay)
  (t/assert= (if-let [v false] :yay) nil)
  (t/assert= (if-let [v nil] :yay :nay) :nay)
  (t/assert= (if-let [v nil] :yay) nil)
  (t/assert= (if-let [v (= 3 4)] :yay :nay) :nay)
  (t/assert= (if-let [v (= 3 4)] :yay) nil)

  (t/assert= (if-let [v true] :yay :nay) :yay)
  (t/assert= (if-let [v true] :yay) :yay)
  (t/assset= (if-let [v (+ 3 4)] v :nay) 7)
  (t/assset= (if-let [v (+ 3 4)] v) 7)
  (t/assert= (if-let [v {}] v :nay) {})
  (t/assert= (if-let [v {}] v) {}))
