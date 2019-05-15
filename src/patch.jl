pathwalk(f, ex, path = []) = f(path, ex)

pathwalk(f, ex::AbstractVector, path = []) =
  map((i, x) -> pathwalk(f, x, [path..., i]), 1:length(ex), ex)

pathwalk(f, ex::Expr, path = []) =
  f(path, Expr(ex.head, pathwalk(f, ex.args, path)...))

function apply!(f, path, patch)
  sourcemap(f) do ex
    pathwalk(ex) do p, x
      p == path ? patch(x) : x
    end
  end
end

function index(ex, fs)
  idx = Dict()
  pathwalk(ex) do p, x
    for f in fs
      if matches(f, x)
        push!(get!(idx, p, []), f)
      end
    end
    return x
  end
  return idx
end

parsefile(f) = Expr(CSTParser.parse(String(read(f)), true))

function indices(dir, fs)
  idx = []
  for (root, dirs, files) in walkdir(dir), f in files
    endswith(f, ".jl") || continue
    p = joinpath(root, f)
    fidx = index(parsefile(p), fs)
    isempty(fidx) || push!(idx, [p, filesize(p), fidx])
  end
  return idx
end

function pick(idx)
  file = wsample([size for (_, size, _) in idx])
  (file, _, idx) = idx[file]
  (path, patches) = rand(collect(idx))
  patch = rand(patches)
  return file, path, patch
end

pick!(idx) = apply!(pick(idx)...)
