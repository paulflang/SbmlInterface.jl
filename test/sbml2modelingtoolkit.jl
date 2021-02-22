FIXTURES = joinpath(@__DIR__, "fixtures")
SBML_FILE = joinpath(FIXTURES, "_model.xml")

# test getmodel
@test_nowarn getmodel(SBML_FILE)
model = getmodel(SBML_FILE)

# test getparameters
parameters = getparameters(model)
trueparameters = Pair{ModelingToolkit.Num,Float64}[a0 => 1.0,
                                                   b0 => 1.0,
                                                   k1 => 0.0,
                                                   k2 => 0.0,
                                                   compartment => 1.0]
@test repr(parameters) == repr(trueparameters)

# test getinitialconditions
initialconditions = getinitialconditions(model)
trueinitialconditons = Pair{ModelingToolkit.Num,Float64}[A => 1.0,
                                                         B => 1.0]
@test repr(initialconditions) == repr(trueinitialconditons)

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
#=@test repr(ModelingToolkit.get_default_p(sys)) == "Dict{Sym{ModelingToolkit.Parameter{Real}},Float64}(b0 => 1.0,a0 => 1.0,k1 => 0.0,k2 => 0.0,compartment => 1.0)"
@test repr(ModelingToolkit.get_default_u0(sys)) == "Dict{Term{Real},Float64}(B(t) => 1.0,A(t) => 1.0)"=#

# test sbml2odeproblem
prob = sbml2odeproblem(SBML_FILE)
println(prob)
@test_nowarn OrdinaryDiffEq.solve(prob,OrdinaryDiffEq.Tsit5())

# test simulatesbml
@test_nowarn simulatesbml(SBML_FILE)



# export variables
# change parameters
# add function output stuff
# add test cases
# check that there are no warnings
# continuous integration
# add t_out
# reserve package name

# test simulatesbml
#=sol = simulatesbml(SBML_FILE,(0.0,1.0))
println(sol)
@test 1==1=#

#=@test begin
    createvariables(model)
    isa(A, ModelingToolkit.Num)
end=#

#=@testset "sbml2odesystem.jl" begin
    sys, p, u0 = sbml2odesystem(SBML_FILE)
#=    @test sys = b
    @test p = d
    @test u0 = e=#
end=#



# @test getparameters(model) != 1
 

