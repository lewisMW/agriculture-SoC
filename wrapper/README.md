This directory is for the custom design and verification files for an accelerator wrapper.

By using the accelerator_wrapper_tech components, Arm IP and the IP components provided by your own accelerator, it should be possible to construct a wrapped up version of your accelerator which can then be plumbed into the expansion region of the NanoSoC Expansion Region. 

The src directory is where the design files should go. Then within the flist directory at the top-level of this repository, under project, you should list your accelerator components within your accelerator.flist file. 