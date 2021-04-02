var documenterSearchIndex = {"docs":
[{"location":"api_reference/#API-reference","page":"API reference","title":"API reference","text":"","category":"section"},{"location":"api_reference/","page":"API reference","title":"API reference","text":"Modules = [SbmlInterface]","category":"page"},{"location":"api_reference/#SbmlInterface.getinitialconditions-Tuple{Any}","page":"API reference","title":"SbmlInterface.getinitialconditions","text":"getinitialconditions(model)\n\nCreate array of initial conditions from a libsbml Model.\n\nExample\n\njulia> u0 = getinitialconditions(model)\n2-element Array{Pair{Num,Float64},1}:\n A(t) => 1.0\n B(t) => 0.0\n\n\n\n\n\n","category":"method"},{"location":"api_reference/#SbmlInterface.getmodel-Tuple{String}","page":"API reference","title":"SbmlInterface.getmodel","text":"getmodel(sbmlfile::String)\n\nGiven an sbmlfile return a PyObject (libsbml.Model).\n\nExample\n\njulia> model = getmodel(SBML_FILE)\nPyObject <Model conversion_reaction_0 \"Conversion Reaction 0\">\n\n\n\n\n\n","category":"method"},{"location":"api_reference/#SbmlInterface.getparameters-Tuple{Any}","page":"API reference","title":"SbmlInterface.getparameters","text":"getparameters(model)\n\nCreate array of parameters from a libsbml Model.\n\nExample\n\njulia> pars = getparameters(model)\n3-element Array{Pair{Num,Float64},1}:\n          k1 => 0.8\n          k2 => 0.6\n compartment => 1.0\n\n\n\n\n\n","category":"method"},{"location":"api_reference/#SbmlInterface.getreactions-Tuple{Any}","page":"API reference","title":"SbmlInterface.getreactions","text":"getreactions(model)::Array\n\nCreate array of Reactions from a libsbml model.\n\nExample\n\njulia> rxs = getreactions(model)\n2-element Array{ModelingToolkit.Reaction,1}:\n ModelingToolkit.Reaction{Any,Float64}(compartment*k1*A(t), SymbolicUtils.Term{Real}[A(t)],\n                                       SymbolicUtils.Term{Real}[B(t)], [1.0], [1.0],\n                                       Pair{Any,Float64}[B(t) => 1.0, A(t) => -1.0], true)\n ModelingToolkit.Reaction{Any,Float64}(compartment*k2*B(t), SymbolicUtils.Term{Real}[B(t)],\n                                       SymbolicUtils.Term{Real}[A(t)], [1.0], [1.0],\n                                       Pair{Any,Float64}[B(t) => -1.0, A(t) => 1.0], true)\n\n\n\n\n\n","category":"method"},{"location":"api_reference/#SbmlInterface.sbml2odeproblem-Tuple{String, Any}","page":"API reference","title":"SbmlInterface.sbml2odeproblem","text":"sbml2odeproblem(sbmlfile::String,tspan;jac::Bool=true)\n\nConvert model from SBML file to an ODEProblem and return it.\n\nArguments\n\nsbmlfile::String: path to SBML file.\ntspan: The solution u(t) will be computed for tspan[1] ≤ t ≤ tspan[2].\njac::Bool=true: Jacobian matrix.\n\nExample\n\njulia> prob = sbml2odeproblem(SBML_FILE,(0.0,10.0))\nODEProblem with uType Array{Float64,1} and tType Float64. In-place: true\ntimespan: (0.0, 10.0)\nu0: [0.0, 1.0]\n\n\n\n\n\n","category":"method"},{"location":"api_reference/#SbmlInterface.sbml2odesystem-Tuple{String}","page":"API reference","title":"SbmlInterface.sbml2odesystem","text":"sbml2odesystem(sbmlfile::String)\n\nGiven an sbmlfile return an ODESystem with default_u0 and default_p set.\n\nExample\n\njulia> sys = sbml2odesystem(SBML_FILE)\nModel ##ODESystem#270 with 2 equations\nStates (2):\n  B(t) [defaults to 0.0]\n  A(t) [defaults to 1.0]\nParameters (3):\n  k2 [defaults to 0.6]\n  compartment [defaults to 1.0]\n  k1 [defaults to 0.8]\n\n\n\n\n\n","category":"method"},{"location":"api_reference/#SbmlInterface.simulatesbml-Tuple{String, Any}","page":"API reference","title":"SbmlInterface.simulatesbml","text":"simulatesbml(sbmlfile::String,tspan;saveat::Real=1.,jac::Bool=true,\n             solver=OrdinaryDiffEq.Tsit5())\n\nSimulate model from SBML file and return an ODESolution.\n\nArguments\n\nsbmlfile::String: path to SBML file.\ntspan: The solution u(t) will be computed for tspan[1] ≤ t ≤ tspan[2].\nsaveat::Real=1.: time intervals of u(t) output.\njac::Bool=true: Jacobian matrix.\nsolver=OrdinaryDiffEq.Tsit5(): Integration algorithm.\n\nExample\n\njulia> sol = simulatesbml(\"mymodel.sbml\",(0.0,1.0))\nretcode: Success\nInterpolation: 1st order linear\nt: 2-element Array{Float64,1}:\n 0.0\n 1.0\nu: 2-element Array{Array{Float64,1},1}:\n [0.0, 1.0]\n [0.4, 0.6]\n\n\n\n\n\n","category":"method"},{"location":"about/","page":"About","title":"About","text":"CurrentModule = SbmlInterface","category":"page"},{"location":"about/#About","page":"About","title":"About","text":"","category":"section"},{"location":"about/#License","page":"About","title":"License","text":"","category":"section"},{"location":"about/","page":"About","title":"About","text":"The software is released under the MIT license.","category":"page"},{"location":"about/#Development-team","page":"About","title":"Development team","text":"","category":"section"},{"location":"about/","page":"About","title":"About","text":"This package was developed by the Paul F. Lang at the University of Oxford, UK and Anand Jain at the University of Chicago, USA.","category":"page"},{"location":"about/#Acknowledgements","page":"About","title":"Acknowledgements","text":"","category":"section"},{"location":"about/","page":"About","title":"About","text":"We would like to thank Frank T. Bergmann for sharing his code to parse SBML files. This work was supported by a the Engineering and Physical Sciences Research Council [grant number 2105279].","category":"page"},{"location":"about/#Questions-and-comments","page":"About","title":"Questions and comments","text":"","category":"section"},{"location":"about/","page":"About","title":"About","text":"Please contact Paul F. Lang or Anand Jain with any questions or comments.","category":"page"},{"location":"contributing/","page":"Contributing","title":"Contributing","text":"CurrentModule = SbmlInterface","category":"page"},{"location":"contributing/#Contributing-to-SbmlInterface","page":"Contributing","title":"Contributing to SbmlInterface","text":"","category":"section"},{"location":"contributing/","page":"Contributing","title":"Contributing","text":"We welcome contributions to SbmlInterface, including to the software, tests and documentation. Please use GitHub pull requests to contribute to SBML2Julia or contact us by email.","category":"page"},{"location":"contributing/","page":"Contributing","title":"Contributing","text":"Create a fork of the SbmlInterface GitHub repository. Please see the GitHub documentation for more information.\nEdit the code, unit tests or documentation.\nCommit your changes to your fork of the SbmlInterface repository.\nPush your changes to GitHub.\nUse the GitHub website to create a pull request for your changes. Please see the GitHub documentation for more information.","category":"page"},{"location":"examples/","page":"Example","title":"Example","text":"CurrentModule = SbmlInterface","category":"page"},{"location":"examples/#Example","page":"Example","title":"Example","text":"","category":"section"},{"location":"examples/#G2/M-cell-cycle-transition","page":"Example","title":"G2/M cell cycle transition","text":"","category":"section"},{"location":"examples/","page":"Example","title":"Example","text":"The SbmlInterface GitHub repository contains a version of the Vinod et Novak model of the G2/M cell cycle transition. The model contains 13 species and 24 parameters.","category":"page"},{"location":"examples/","page":"Example","title":"Example","text":"As mentioned in the section Tutorial, you can simulate the SBML model with the simulatesbml function:","category":"page"},{"location":"examples/","page":"Example","title":"Example","text":"using SbmlInterface\n\nsol = simulatesbml(\"examples/Vinod_FEBS2015/model_Vinod_FEBS2015.xml\",(0.0,300.0))\n\nusing Plots\nplot(sol,vars=[Cb,pCb,B55],lw=3,\",size=(600,400),legend=:right)","category":"page"},{"location":"examples/","page":"Example","title":"Example","text":"(Image: Vinod_FEBS2015)","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"CurrentModule = SbmlInterface","category":"page"},{"location":"installation/#Installation","page":"Installation","title":"Installation","text":"","category":"section"},{"location":"installation/","page":"Installation","title":"Installation","text":"SbmlInterface.jl is not yet available on the Julia package managing system. To install SbmlInterface please first clone this repository:   $ git clone https://github.com/paulflang/SbmlInterface.jl.git As SbmlInterface.jl relies on the Python libsbml library, please make sure your version of Julia can communicate with a Python environment were libsbml is installed. Please follow the PyCall installation instructions or:","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"create a Python virtual environment in the SbmlInterface.jl directory and activate it:\n$ cd SbmlInterface.jl/\n$ python3 -m venv venv\n$ source venv/bin/activate\ninstall python-libsbml to the python environment:\n$ pip install python-libsbml\nstart the Julia REPL:\n$ julia\nand activate the Julia virtual environment:\njulia> ]\n(v1.5) pkg> activate .\n(SbmlInterface) pkg>","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"When using SbmlInterface Julia will be able to communicate with the python virtual environment where you have installed libsbml.","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = SbmlInterface","category":"page"},{"location":"#SbmlInterface.jl","page":"Home","title":"SbmlInterface.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"SbmlInterface.jl is a lightweight tool to import models specified in the Systems Biology Markup Language (SBML) into Julia. More specifically, SbmlInterface.jl uses the Python libsbml library to extract ordinary differential equations, initial conditions and parameter values from SBML files. Events and constraints and several other SBML components are not yet supported. There are several ways to specify the same model in SBML. Please help us improving SbmlInterface.jl by creating a GitHub issue if you find your way of specifying an SBML model is not supported by SbmlInterface.","category":"page"},{"location":"#Contents","page":"Home","title":"Contents","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Pages = [\"installation.md\", \"tutorial.md\", \"examples.md\", \"api_reference.md\", \"contributing.md\", \"about.md\"]","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"CurrentModule = SbmlInterface","category":"page"},{"location":"tutorial/#Tutorial","page":"Tutorial","title":"Tutorial","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"SBML models can be simulated with the following 6 steps:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"using SbmlInterface\n\nmodel = getmodel(\"mymodel.sbml\")\np = getparameters(model)\nu0 = getinitialconditions(model)\nrxs = getreactions(model)\nrs  = ReactionSystem(rxs, t, [item.first for item in u0], [item.first for item in p])\nodesys = convert(ODESystem, rs)\nprob = ODEProblem(odesys,u0,(0.0,10.0),p)\nsol = solve(prob,Tsit5())","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"If you want to create an ODESystem, ODEProblem or solution Array directly from an SBML file use sbml2odesystem('mymodel.sbml'), sbml2odeproblem('mymodel.sbml',(tstart,tend)) and simulatesbml('mymodel.sbml',(tstart,tend)), respectively.","category":"page"}]
}
