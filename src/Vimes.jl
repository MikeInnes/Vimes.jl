module Vimes

using CSTParser

isdefined(CSTParser, :LocExpr) ||
  error("""
  Vimes depends on a fork of CSTParser:
  ] add https://github.com/MikeInnes/CSTParser.jl#location
  """)

using MacroTools, CSTParser, StatsBase, Dates, Printf
using MacroTools: sourcemap

include("library.jl")
include("patch.jl")
include("run.jl")

end # module
