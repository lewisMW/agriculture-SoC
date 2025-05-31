# SoCSim

SoCSim is a very basic simulation framework which allows for easy running of simulation scripts.
Scripts can be located in the simulate/socsim directory of any repository or subrepository of a project.

By using the 
```
$ socsim $simulation_script
```
command, you can easily run your simulation scripts. This is done by socsim looking over a searchpath of socsim directories in your design project.

These scripts can call any simulator or external simulation flow and should make simulation management easier.
