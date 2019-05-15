module Vimes

using MacroTools, CSTParser, StatsBase
using MacroTools: sourcemap

isdefined(CSTParser, :LocExpr) ||
  error("] add https://github.com/MikeInnes/CSTParser.jl#location")

include("library.jl")
include("patch.jl")
include("run.jl")

end # module
