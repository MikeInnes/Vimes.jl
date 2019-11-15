# Vimes

[![Build Status](https://travis-ci.org/MikeInnes/Vimes.jl.svg?branch=master)](https://travis-ci.org/MikeInnes/Vimes.jl)
[![Codecov](https://codecov.io/gh/MikeInnes/Vimes.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/MikeInnes/Vimes.jl)

> ‘Quis custodiet ipsos custodies? Your grace.’ \
> ‘I know that one,’ said Vimes. 'Who watches the watchmen? Me, Mr Pessimal.’ \
> ‘Ah, but who watches you, your grace?’ said the inspector, with a brief smile. \
> ‘I do that, too.'

```julia
] add https://github.com/MikeInnes/Vimes.jl
] add https://github.com/MikeInnes/CSTParser.jl#location
```

Simulating a good programmer may be AI-complete, but simulating a bad one is much easier. That's what Vimes does; it makes random, but plausible-looking, changes to your code. Then it runs your test suite. If your tests fail, you're good; if they don't, then the tests are probably missing something important.

Usage:

```julia
julia> using Vimes; Vimes.go("../JSON.jl", procs=4) # run 4 tests in parallel
[ Info: (4) Ran 1 tests, precision 100.00%
[ Info: (1) Ran 2 tests, precision 100.00%
...
[ Info: (2) Ran 35 tests, precision 97.14%
```

Vimes reports the percentage of runs where the tests failed as the precision of the test suite (i.e. 100% is the best possible precision).

In the project folder (here `../JSON.jl`), a `.vimes` folder will appear with a `.diff` file for every patch found, like this:

```diff
@@ -19,7 +19,7 @@ end
 function Base.push!(v::PushVector, i)
     v.l += 1
-    if v.l > length(v.v)
+    if !(v.l > length(v.v))
         resize!(v.v, v.l * 2)
     end
     v.v[v.l] = i
```

## Patches

Vimes is powered by the library of patches in `src/library.jl`. It's easy to make a new patch; it's just a function which takes an expression and returns either a new expression or `nothing`. For example, replacing numeric constants can be done by

```julia
function numbers(x)
  x isa Number || return
  return rand(typeof(x))
end
```

Note that you do not need to search for numbers inside expressions, since Vimes will automatically apply this function to the whole source tree.

Vimes comes with a set of default patches, `Vimes.defaults`. You can supply your own set of patches entirely, or extend the defaults with

```julia
Vimes.go(".", [Vimes.defaults..., numbers])
```
