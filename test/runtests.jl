using SbmlInterface
using ModelingToolkit
using OrdinaryDiffEq
using Test

@testset "SbmlInterface.jl" begin
    @testset "sbml2modelingtoolkit.jl" begin include("sbml2modelingtoolkit.jl") end
end
