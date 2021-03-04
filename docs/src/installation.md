```@meta
CurrentModule = SbmlInterface
```

# Installation

SbmlInterface.jl is not yet available on the Julia package managing system. To install SbmlInterface please first clone this repository:
  ```
  $ git clone https://github.com/paulflang/SbmlInterface.jl.git
  ```
As SbmlInterface.jl relies on the Python libsbml library, please make sure your version of Julia can communicate with a Python environment were libsbml is installed. Please follow the [PyCall installation instructions](https://github.com/JuliaPy/PyCall.jl) or:
* create a Python virtual environment in the SbmlInterface.jl directory and activate it:
  ```
  $ cd SbmlInterface.jl/
  $ python3 -m venv venv
  $ source venv/bin/activate
  ```
* install python-libsbml to the python environment:
  ```
  $ pip install python-libsbml
  ```
* start the Julia REPL:
  ```
  $ julia
  ```
* and activate the Julia virtual environment:
  ```julia
  julia> ]
  (v1.5) pkg> activate .
  (SbmlInterface) pkg>
  ```
When `using SbmlInterface` Julia will be able to communicate with the python virtual environment where you have installed libsbml.
