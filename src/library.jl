matches(f, x) = f(x) != nothing

function stringindex(x)
  @capture(x, nextind(str_, i_)) && return :($i + 1)
  @capture(x, prevind(str_, i_)) && return :($i - 1)
  return
end

function integer(x)
  x isa Number && return rand(typeof(x))
  return
end

const defaults = Any[stringindex, integer]
