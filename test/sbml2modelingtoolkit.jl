#=model = libsbml.model
par = ["a", "b"]
model.parameters = par
@test getparameters(model) == par
@test=#

FIXTURES = joinpath(@__DIR__, "fixtures")
SBML_FILE = joinpath(FIXTURES, "_model.xml")

# @test SbmlInterface.getmodel(SBML_FILE) != 1
@test_nowarn SbmlInterface.getmodel(SBML_FILE)

model = SbmlInterface.getmodel(SBML_FILE)
parameters = SbmlInterface.getparameters(model)
trueparameters = Any[a0 => 1.0,
                     b0 => 1.0,
                     k1 => 0.0,
                     k2 => 0.0]
@test repr(parameters) == repr(trueparameters)

initialconditions = SbmlInterface.getinitialconditions(model)
trueinitialconditons = Any[A => 1.0,
                           B => 1.0]
@test repr(initialconditions) == repr(trueinitialconditons)

#=@test begin
    SbmlInterface.createvariables(model)
    isa(A, ModelingToolkit.Num)
end=#

#=@testset "sbml2odesystem.jl" begin
    sys, p, ic = sbml2odesystem(SBML_FILE)
#=    @test sys = b
    @test p = d
    @test ic = e=#
end=#



# @test SbmlInterface.getparameters(model) != 1
 

