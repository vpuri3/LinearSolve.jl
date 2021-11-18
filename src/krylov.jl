## Krylov.jl

# place Krylov.CGsolver in LinearCache.cacheval, and resule

struct KrylovJL{F,A,K} <: SciMLLinearSolveAlgorithm
    solver::F
    args::A
    kwargs::K
end

function KrylovJL(args...; solver = Krylov.gmres, kwargs...)
    return KrylovJL(solver, args, kwargs)
end

function SciMLBase.solve(cache::LinearCache, alg::KrylovJL,args...;kwargs...)
    @unpack A, b, u, Pr, Pl = cache
    u, stats = alg.solver(A, b, args...; M=Pl, N=Pr, kwargs...)
    resid = A * u - b
    retcode = stats.solved ? :Success : :Failure
    return u
end

## IterativeSolvers.jl

struct IterativeSolversJL{F,A,K} <: SciMLLinearSolveAlgorithm
    solver::F
    args::A
    kwargs::K
end

## KrylovKit.jl

struct KrylovKitJL{F,A,K} <: SciMLLinearSolveAlgorithm
    solver::F
    args::A
    kwargs::K
end

function KrylovKitJL(args...; solver = KrylovKit.CG(), kwargs...)
    return KrylovKitJL(solver, args, kwargs)
end

function SciMLBase.solve(cache::LinearCache, alg::KrylovKitJL,args...;kwargs...)
    @unpack A, b, u = cache
    @unpack solver = alg
    u = KrylovKit.linsolve(A, b, u, solver, args...; kwargs...)[1] #no precond?!
    return u
end

