module Vimes

using Dates
using MacroTools
using Printf
using SourceWalk
using StatsBase

using SourceWalk.CSTParser
using SourceWalk: sourcemap

include("library.jl")
include("patch.jl")
include("run.jl")

end # module
