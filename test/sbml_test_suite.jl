using SbmlInterface, ModelingToolkit, OrdinaryDiffEq, SciMLBase, DataFrames

# assumes this is cloned: https://github.com/sbmlteam/sbml-test-suite
path  = joinpath(homedir(), "sbml-test-suite/cases/")
@test isdir(path)

function extract_xmls()
    dirs = filter(isdir, readdir(path; join=true))
    all_dirs = mapreduce(x -> filter(isdir, readdir(x; join=true)), vcat, dirs)
    all_files = vcat(readdir.(all_dirs; join=true)...)
    filter!(x -> occursin(".xml", x), all_files)
end

# theres probably an idiomatic way to do this
function call_save_err(f, x)
    n = length(x)
    arr = Vector(undef, n)
    for i in 1:n
        try 
            arr[i] = f(x[i])
        catch e 
            arr[i] = e
        end
    end
    arr
end

# theres probably an idiomatic way to do this
function filtermap(f, x)
    arr = call_save_err(f, x)
    arr[Not(@. typeof(arr) <: Exception)]
end

all_files = extract_xmls()
@test all_files isa Vector{String}

n = length(all_files)
skipidx = 10
num = 1000
# all_files = all_files[1:n]


@time models = getmodel.(all_files); #   8.972979 seconds (779.59 k allocations: 35.538 MiB, 0.57% gc time, 0.73% compilation time)
@time ps = getparameters.(models); # 15.963854 seconds (6.03 M allocations: 346.563 MiB, 0.86% gc time, 0.02% compilation time)

@time u0s = call_save_err(getinitialconditions, models); #  16.213772 seconds (7.04 M allocations: 408.899 MiB, 0.99% gc time, 0.51% compilation time)
@time eqs = call_save_err(getodes, models); #  52.578963 seconds (24.88 M allocations: 1.315 GiB, 1.52% gc time, 0.87% compilation time)
@time systems = call_save_err(sbml2odesystem, all_files); #  97.208173 seconds (44.64 M allocations: 2.364 GiB, 1.50% gc time, 0.57% compilation time)
# @time probs = call_save_err(x->sbml2odeproblem(x, (0., 1.)), all_files); # longer than im willing to wait
@time probs = call_save_err(x->sbml2odeproblem(x, (0., 1.)), all_files[1:100]); # 18.651824 seconds (37.88 M allocations: 2.416 GiB, 3.23% gc time)
# @time probs = call_save_err(x->ODEProblem(x...), syss[1:100]); # don't do this

df = DataFrame(:id => all_files, :model => models, :p => ps, :u0 => u0s, :eqs => eqs, :sys => systems) # :prob => probs)

N, M = size(df)
cols = DataFrames.names(df) 

errored_mask = @. typeof(df[:, :sys]) <: Exception
errs = df[errored_mask, :]
good = df[Not(errored_mask), :]
syss = good.sys

good_probs = probs[Not(@. typeof(probs) <: Exception)] # eventually benchmark solve on these

# plot(solve(rand(good_probs)))
@time mtks = filtermap(modelingtoolkitize, good_probs); # 
eqs = unique(equations.(mtks))
@test length(eqs) > 0 
