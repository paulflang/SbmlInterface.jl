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
u0 = getinitialconditions(model)
true_u0 = Pair{ModelingToolkit.Num,Float64}[A => 1.0,
                                            B => 0.0]
@test repr(u0) == repr(true_u0)

# test getodes
eqs = getodes(model)
trueeqs = ModelingToolkit.Equation[
            D(B) ~ 1.0 * (compartment * k1 * A) - 1.0 * (compartment * k2 * B),
            D(A) ~ -1.0 * (compartment * k1 * A) + 1.0 * (compartment * k2 * B)
          ]
@test repr(eqs) == repr(trueeqs)
sys = ModelingToolkit.ODESystem(eqs)
@test repr(ModelingToolkit.get_iv(sys)) == "t"
@test repr(ModelingToolkit.get_states(sys)) == "Term{Real}[B(t), A(t)]"
    
# test sbml2odesystem
sys,u0,p = sbml2odesystem(SBML_FILE)
@test repr(ModelingToolkit.get_iv(sys)) == "t"
@test repr(ModelingToolkit.get_states(sys)) == "Term{Real}[B(t), A(t)]"

# test sbml2odeproblem
prob = sbml2odeproblem(SBML_FILE,(0.0,10.0))
@test prob.u0 == [0.0, 1.0]  # "Pair{ModelingToolkit.Num,Float64}[A => 1.0,B => 0.0]"
@test prob.tspan == (0.0, 10.0)
@test Set(prob.p) == Set([0.8, 0.6, 1.0])  # Todo: try removing the Set() when new ODEproblem version is released.
@test_nowarn OrdinaryDiffEq.solve(prob,OrdinaryDiffEq.Tsit5())
@test_nowarn sbml2odeproblem(SBML_FILE,(0.0,1.0),jac=false)

# test simulatesbml
sol1 = simulatesbml(SBML_FILE,(0.0,10.0))
@test sol1[end] ≈ [0.5714271572277619, 0.42857284277223784]
@test_nowarn simulatesbml(SBML_FILE,(0.0,1.0),saveat=0.5,jac=false,solver=OrdinaryDiffEq.Vern9())
sol2 = simulatesbml(joinpath(FIXTURES, "_model_v2.xml"),(0.0,10.0))
@test sol2[end] ≈ [0.5714271572277619, 0.42857284277223784]


# update readme
# write docs
# reserve package name
