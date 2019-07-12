module Vimes

using MacroTools, StatsBase, Dates, Printf
using MacroTools: sourcemap
using MacroTools.CSTParser

include("library.jl")
include("patch.jl")
include("run.jl")

end # module
