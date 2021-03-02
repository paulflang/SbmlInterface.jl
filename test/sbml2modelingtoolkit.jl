FIXTURES = joinpath(@__DIR__, "fixtures")
SBML_FILE = joinpath(FIXTURES, "_model_v1.xml")

# test getmodel
@test_nowarn getmodel(SBML_FILE)
model = getmodel(SBML_FILE)

# test getparameters
parameters = getparameters(model)
trueparameters = Pair{ModelingToolkit.Num,Float64}[a0 => 1.0,
                                                   b0 => 0.0,
                                                   k1 => 0.8,
                                                   k2 => 0.6,
                                                   compartment => 1.0]
@test repr(parameters) == repr(trueparameters)

# test getinitialconditions
@parameters t
u0 = getinitialconditions(model)
true_u0 = Pair{ModelingToolkit.Num,Float64}[A => 1.0,
                                            B => 0.0]
@test repr(u0) == repr(true_u0)

# test getodes
rxs = getreactions(model)
# truerxs = "Reaction[Reaction{Any,Float64}(compartment*k1*A(t), Term{Real}[A(t)], Term{Real}[B(t)], [1.0], [1.0], Pair{Any,Float64}[B(t) => 1.0, A(t) => -1.0], true), Reaction{Any,Float64}(compartment*k2*B(t), Term{Real}[B(t)], Term{Real}[A(t)], [1.0], [1.0], Pair{Any,Float64}[B(t) => -1.0, A(t) => 1.0], true)]"
# truerxs = Reaction{Any,Float64}(compartment*k1*A(t), Term{Real}[A(t)], Term{Real}[B(t)], [1.0], [1.0], Pair{Any,Float64}[B(t) => 1.0, A(t) => -1.0], true)
truerxs = Reaction[Reaction(compartment*k1*A, [A], [B], [1.0], [1.0], only_use_rate=true), Reaction(compartment*k2*B, [B], [A], [1.0], [1.0], only_use_rate=true)]
@test repr(rxs) == repr(truerxs)
rs  = ModelingToolkit.ReactionSystem(rxs, t, [item.first for item in true_u0], [item.first for item in trueparameters])
odesys = convert(ModelingToolkit.ODESystem, rs)
@test repr(ModelingToolkit.get_iv(odesys)) == "t"
@test repr(ModelingToolkit.get_states(odesys)) == "Term{Real}[A(t), B(t)]"
    
# test sbml2odesystem
sys,u0,p = sbml2odesystem(SBML_FILE)
@test repr(ModelingToolkit.get_iv(sys)) == "t"
@test repr(ModelingToolkit.get_states(sys)) == "Term{Real}[A(t), B(t)]"

# test sbml2odeproblem
prob = sbml2odeproblem(SBML_FILE,(0.0,10.0))
@test prob.u0 == [1.0, 0.0]  # "Pair{ModelingToolkit.Num,Float64}[A => 1.0,B => 0.0]"
@test prob.tspan == (0.0, 10.0)
@test prob.p == [1.0, 0.0, 0.8, 0.6, 1.0]  # Todo: try removing the Set() when new ODEproblem version is released.
@test_nowarn OrdinaryDiffEq.solve(prob,OrdinaryDiffEq.Tsit5())
@test_nowarn sbml2odeproblem(SBML_FILE,(0.0,1.0),jac=false)

# test simulatesbml
sol1 = simulatesbml(SBML_FILE,(0.0,10.0))
@test sol1[end] ≈ [0.42857284277223784, 0.5714271572277619]
@test_nowarn simulatesbml(SBML_FILE,(0.0,1.0),saveat=0.5,jac=false,solver=OrdinaryDiffEq.Vern9())
@test_nowarn simulatesbml(joinpath(FIXTURES, "model_Vinod_FEBS2015.xml"),(0.0,1.0))
