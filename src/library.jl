matches(f, x) = f(x) != nothing

function stringindex(x)
  @capture(x, nextind(str_, i_)) && return :($i + 1)
  @capture(x, prevind(str_, i_)) && return :($i - 1)
  return
end

function integer(x)
  x isa Integer && !(x isa Bool) ? rand(typeof(x)) :
  x isa AbstractFloat ? rand(typeof(x)) * x :
  nothing
end

function rmline(x)
  isexpr(x, :block) || return
  is = findall(x -> x isa Expr, x.args)
  isempty(is) && return
  Expr(:block, deleteat!(copy(x.args), rand(is))...)
end

function swapline(x)
  isexpr(x, :block) || return
  is = findall(x -> x isa Expr, x.args)
  length(is) < 2 && return
  i = rand(is)
  j = rand(setdiff(is, i))
  args = copy(x.args)
  args[i], args[j] = args[j], args[i]
  return Expr(:block, args...)
end

function flipcond(x)
  isexpr(x, :if, :elseif) || return
  Expr(x.head, Expr(:call, :!, x.args[1]), x.args[2:end]...)
end

const defaults =
  Any[stringindex, integer, rmline, swapline, flipcond]
