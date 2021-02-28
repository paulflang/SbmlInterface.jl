using SbmlInterface
using ModelingToolkit
using OrdinaryDiffEq
using Test

@testset "SbmlInterface.jl" begin
    @show readdir()
    @show readdir(homedir())
    @show pwd()
    @test true
    # @testset "sbml2modelingtoolkit.jl" begin include("sbml2modelingtoolkit.jl") end
    @testset "sbml_test_suite.jl" begin include("sbml_test_suite.jl") end
end
