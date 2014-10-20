# Pixie

## Intro

Pixie is a lightweight lisp suitable for both general use as well as shell scripting. The language is still in a "pre-alpha" phase and as such changes fairly quickly.
The standard library is heavily inspired by Clojure as well as several other functional programming languages. It is written in RPython (http://pypy.readthedocs.org/en/latest/coding-guide.html) and as such supports a fairly fast GC and an amazingly fast tracing JIT.

## Features

Some planned and implemented features:

* Protocols first implementation
* Transducers at-the-bottom (most primitves are based off of reduce)
* Coroutines for transducer inversion of control (transducer to lazy-seq conversion)
* A "good enough" JIT (implemented, tuning still a WIP, but not bad performance today)
* Easy FFI (TODO)
* Pattern matching (TODO)


## FAQ

### So this is written in Python?

It's actually written in the RPython, the same language PyPy is written in. The script `./make-with-jit` will compile Pixie using the PyPy toolchain. After some time, it will produce an executable called `target-c` this executable is a flow blown native interpreter with a JIT, GC, etc. So yes, the guts are written in RPython, just like the guts of most lisp interpreters are written in C. At runtime the only thing that is interpreted is the Pixie bytecode, that is until the JIT kicks in...

### What's this bit about "magical powers"?

First of all, the word "magic" is in quotes as it's partly a play on words, pixies are small, light and often considered to have magical powers. 

However there are a few features of pixie that although may not be uncommon, are perhaps unexpected from a lisp. 

* The JIT makes some things fast. Very fast. Code like the following compiles down to a loop with 6 CPU instructions. While this may not be too impressive for any language that uses a tracing jit, it is faily unique for a language as young as Pixie. 

```clojure

(comment
  This code adds up to 10000 from 0 via calling a function that takes a variable number of arguments. 
  That function then reduces over the argument list to add up all given arguments.)
  
(defn add-fn [& args]
  (reduce -add 0 args))

(loop [x 0]
  (if (eq x 10000)
    x
    (recur (add-fn x 1))))
    
```
  
  
* Inversion of control via stacklets. Most of Pixie makes heavy use of transducers. However there are times when transducers need to be converted into a cons style lazy sequence. For this we make use of stacklets to invert control of the loops. Because of this, any data collection need only define a method for the -reduce protocol and most collections functions will "just work"

```clojure

(def stacklet->lazy-seq
  (fn [f]
    (let [val (f nil)]
      (if (identical? val :end)
        nil
        (cons val (lazy-seq* (fn [] (stacklet->lazy-seq f))))))))

(def sequence
  (fn
    ([data]
       (let [f (create-stacklet
                 (fn [h]
                   (reduce (fn ([h item] (h item) h)) h data)
                   (h :end)))]
          (stacklet->lazy-seq f)))
    ([xform data]
        (let [f (create-stacklet
                 (fn [h]
                   (transduce xform
                              (fn ([] h)
                                ([h item] (h item) h)
                                ([h] (h :end)))
                              data)))]
          (stacklet->lazy-seq f)))))

(comment
  (sequence [1 2 3 4]) now produces '(1 2 3 4))

```

* Math system is fully polymorphic. Math primitives (+,-, etc.) are built off of polymorphic functions that dispatch on the types of the first two arguments. This allows the math system to be extended to complex numbers, matricies, etc. The performance penalty of such a polymorphic call is completely removed by the RPython generated JIT. 

(Planned "magical" Features)

* Influencing the JIT from user code. (Still in research) Eventually it would be nice to allow Pixie to hint to the JIT that certain values are constants, that certain functions are pure, etc. This can all be done from inside RPython, and the plan is to expose parts of that to the user via hints in the Pixie language, to what extent this will be possible is not yet known.

* STM for parallelism. Once STM gets merged into the mainline branch of PyPy, we'll adopt it pretty quickly.

* CSP for concurrency. We already have stacklets, it's not that hard to use them for CSP style concurrency as well. 


## Contributing

Currently there isn't a whole lot that newcomers can help out with, since the entire codebase is in quite a bit of flux, and the main primitives are still under development. However, we do want to have a very open contribution process. If you have a feature you'd like to implement, submit a PR or file an issue and we'll see what we can do.

## Implementation Notes

Although parts of the language may be very close to Clojure (they are both lisps after all), language parity is not a design goal. We will take the features from Clojure or other languages that are suitable to our needs, and feel free to reject those that aren't. Therefore this should not be considered a "Clojure Dialect", but instead a "Clojure inspired lisp".

## Copying

Free use of this software is granted under the terms of the GNU Lesser General Public License (LGPL). For details see the files `COPYING` and `COPYING.LESSER` included with the 0MQ distribution.
