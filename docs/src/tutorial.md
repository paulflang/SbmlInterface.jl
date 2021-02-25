```@meta
CurrentModule = SbmlInterface
```

# Tutorial

SBML models can be simulated with the following 6 steps:
```julia
using SbmlInterface

model = getmodel('mymodel.sbml')
p = getparameters(model)
u0 = getinitialconditions(model)
eqs = getodes(model)
sys = ODESystem(eqs)
prob = ODEProblem(sys,u0,(0.0,10.0),p)
sol = solve(prob,Tsit5())
```
If you want to create an `ODESystem`, `ODEProblem` or solution `Array` directly from an SBML file use `sbml2odesystem('mymodel.sbml')`, `sbml2odeproblem('mymodel.sbml',(tstart,tend))` and `simulatesbml('mymodel.sbml',(tstart,tend))`, respectively.
