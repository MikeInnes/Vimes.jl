using Vimes, Pkg, Test

@testset "Vimes.jl" begin
    @testset "Run Vimes on JSON" begin
        tmp_depot = mktempdir()
        tmp_env = mktempdir()
        atexit((tmp_depot) -> rm(tmp_depot; force = true, recursive = true))
        atexit((tmp_env) -> rm(tmp_env; force = true, recursive = true))
        original_depot_path = deepcopy(Base.DEPOT_PATH)
        empty!(Base.DEPOT_PATH)
        pushfirst!(Base.DEPOT_PATH, tmp_depot)
        Pkg.activate(tmp_env; shared = false)
        Pkg.develop("JSON")
        json_directory = joinpath(tmp_depot, "dev", "JSON")
        @test Vimes.go(json_directory; tests = 1) isa Integer
        @test Vimes.go(json_directory; tests = 1, dead = true) isa Integer
        @test Vimes.go(json_directory; tests = 2, procs = 2) isa Integer
        empty!(Base.DEPOT_PATH)
        append!(Base.DEPOT_PATH, original_depot_path)
        rm(tmp_depot; force = true, recursive = true)
        rm(tmp_env; force = true, recursive = true)
    end
end
