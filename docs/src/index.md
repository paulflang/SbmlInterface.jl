```@meta
CurrentModule = SbmlInterface
```

# SbmlInterface.jl

> :warning: **SbmlInterface will soon be deprecated**. For more information, please refer to [issue #31 on SBML.jl](https://github.com/LCSB-BioCore/SBML.jl/issues/31).

SbmlInterface.jl is a lightweight tool to import models specified in the Systems Biology Markup Language (SBML) into Julia. More specifically, SbmlInterface.jl uses the Python libsbml library to extract ordinary differential equations, initial conditions and parameter values from SBML files. Events and constraints and several other SBML components are not yet supported. There are several ways to specify the same model in SBML. Please help us improving SbmlInterface.jl by creating a GitHub issue if you find your way of specifying an SBML model is not supported by SbmlInterface.


## Contents
```@contents
Pages = ["installation.md", "tutorial.md", "examples.md", "api_reference.md", "contributing.md", "about.md"]
```
