test_suite_clone_path = joinpath(homedir(), "sbml-test-suite")
if !isdir(test_suite_clone_path)
    run(`git clone https://github.com/sbmlteam/sbml-test-suite $(test_suite_clone_path)`)
end
path = joinpath(test_suite_clone_path, "cases")
@test isdir(path)

function extract_xmls(path)
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
    arr[.!(@. typeof(arr) <: Exception)]
end

all_files = extract_xmls(path)
@test all_files isa Vector{String}

n = length(all_files)
@test n > 0

# speed up CI
TEST_ON = 50
all_files = all_files[1:TEST_ON]

models = getmodel.(all_files); 
ps = getparameters.(models); 
u0s = call_save_err(getinitialconditions, models); 
rxs = call_save_err(getreactions, models); 
systems = call_save_err(sbml2odesystem, all_files); 
probs = call_save_err(x->sbml2odeproblem(x, (0., 1.)), all_files); 

errored_mask = @. typeof(systems) <: Exception
errs = systems[errored_mask, :]
good = systems[.!(errored_mask), :]

good_probs = probs[.!(@. typeof(probs) <: Exception)] # eventually benchmark solve on these

@time mtks = filtermap(modelingtoolkitize, good_probs);
eqs = unique(equations.(mtks))
@test length(eqs) > 0 

@show eqs 
