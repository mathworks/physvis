# PHYSVIS Toolbox

## Description
Students use PHYSVIS to gain a deeper understanding of physics as they
iteratively apply the fundamental laws of physics to compute and
visualize a system's evolution. PHYSVIS lets students explore physical
systems visually without having to write explicit graphics statements.
PHYSVIS is built with the matrix-based MATLAB language so students can
express computational mathematics in a natural way, which helps them
translate theoretical models into code.

## Install
To install, run the PHYSVIS.mltbx file in MATLAB.

The following C files have been compiled for MATLAB R2017a on the most 
common platforms:
* /resources/arbitraryRotation.c
* /resources/arbitraryRotation_ThetaAxis.c
* /resources/transformMultiply.c

The common platforms include:
* Windows 7 and 10
* Debian 7.4 and 8.3
* OSX 10.10.5, 10.11.3, and 10.11.6

To install PHYSVIS on older versions of MATLAB on these common platforms, 
see the section titled "Build from Source". That section also explains how
to install PHYSVIS on less common platforms.

## Documentation
To view documentation after installing, search for 'physvis' in the search 
bar at the top right of the MATLAB desktop.

## Contributing
PHYSVIS was designed to make it easy for others to add new classes of 
shapes / geometries. The Box and Sphere classes serve as examples.

A class diagram is included in the /design-documents directory.

Custom error messages can be added to / referenced from the XML file
/resources/messages.xml

## Build from Source
To build PHYSVIS from source and install it,
1. Copy / paste mex files from /resources/<MATLAB_Release> to /resources/
2. Be sure to add the following directories to your path:
    * /+physvis
    * /doc/* (all subdirectories)
    * /resources (no subdirectories)
3. Run the PHYSVIS.prj file in MATLAB and package the toolbox
4. Run PHYSVIS.mltbx

Sometimes specific MATLAB versions and/or specific operating 
systems require that you (re)compile the C files in /resources into mex 
files. The following MATLAB documentation pages describe the compilation 
procedure:
* [Mex documentation](https://www.mathworks.com/help/matlab/ref/mex.html)
* [List of compatible compilers](https://www.mathworks.com/support/compilers.html)
* [How to change the default compiler](https://www.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html)

© Copyright 2017 The MathWorks, Inc.