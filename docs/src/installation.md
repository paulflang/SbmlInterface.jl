```@meta
CurrentModule = SbmlInterface
```

# Installation

SbmlInterface.jl is not yet available on the Julia package managing system. To install SbmlInterface please first clone this repository:
  ```
  $ git clone https://github.com/paulflang/SbmlInterface.jl.git
  ```
As SbmlInterface.jl relies on the Python libsbml library, please make sure your version of Julia can communicate with a Python environment were libsbml is installed. Please follow the [PyCall installation instructions](https://github.com/JuliaPy/PyCall.jl) or:
* create a Python virtual environment and activate it:
  ```
  $ python -m venv venv
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
* activate the Julia virtual environment:
  ```julia
  julia> ]
  (v1.5) pkg> activate .
  ```
* install PyCall.jl into the Julia virtual environment:
  ```julia
  (SbmlInterface) pkg> add PyCall
  (SbmlInterface) pkg> build PyCall
  ```
* and add SbmlInterface.jl:
  ```julia
  (SbmlInterface) pkg> dev .
  ```
