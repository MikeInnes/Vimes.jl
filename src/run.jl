function _read(cmd)
    out = Pipe()
    if VERSION > v"1.1-"
      procs = Base._spawn(cmd, Any[devnull,out,out])
    else
      procs = Base._spawn(cmd, (devnull,out,out))
    end
    close(out.in)
    return String(read(out)), success(procs)
end

function initialise(dir)
  (isfile(joinpath(dir, "Project.toml")) && isdir(joinpath(dir, "src"))) ||
    error("No Julia project found at $dir")
  tmp = joinpath(tempdir(), "vimes-$(rand(UInt64))")
  mkdir(tmp)
  for path in ["Project.toml", "Manifest.toml", "src", "test", "deps"]
    ispath(joinpath(dir, path)) &&
      cp(joinpath(dir, path), joinpath(tmp, path))
  end
  atexit(() -> rm(tmp, recursive=true))
  return tmp
end

function runtests(dir)
  out, pass = _read(`$(Base.julia_cmd()) --project=$dir -e 'using Pkg; Pkg.test()'`)
end

function mutate(dir, idx)
  pick!(idx)
end

function reset(dir, tmp)
  rm(joinpath(tmp, "src"), recursive=true)
  cp(joinpath(dir, "src"), joinpath(tmp, "src"))
  return
end

diff(dir, tmp) = _read(`git diff $(joinpath(dir, "src")) $(joinpath(tmp, "src"))`)[1]

function logdiff(dir, tmp)
  mkpath(joinpath(dir, ".vimes"))
  write(joinpath(dir, ".vimes", "$(now()).diff"), diff(dir, tmp))
end

function checktests(dir, tmp)
  out, pass = runtests(tmp)
  if !pass
    mkpath(joinpath(dir, ".vimes"))
    write(joinpath(dir, ".vimes", "log.txt"), out)
    error("Tests fail before starting. See `.vimes/log.txt`.")
  end
end

function test(dir, tmp, idx)
  while isempty(diff(dir, tmp))
    mutate(tmp, idx)
  end
  _, pass = runtests(tmp)
  pass && logdiff(dir, tmp)
  reset(dir, tmp)
  return !pass
end

function go(dir, ps = defaults; procs = 1)
  runs, pass = 0, 0
  function run(r)
    runs += 1
    pass += r
    @info("Ran $runs tests, precision $(@sprintf("%.2f", pass/runs*100))%")
  end
  tmp = initialise(dir)
  idx = indices(joinpath(tmp, "src"), ps)
  checktests(dir, tmp)
  rm(tmp, recursive=true)
  @sync for i = 1:procs
    let tmp = initialise(dir), idx = indices(joinpath(tmp, "src"), ps)
      @async while true
        run(test(dir, tmp, idx))
      end
    end
  end
end
