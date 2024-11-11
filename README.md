Makeinstall for MATLAB®
=======================

![release](https://img.shields.io/github/v/release/pucicu/makeinstall)
[![SWH](https://archive.softwareheritage.org/badge/origin/https://github.com/pucicu/makeinstall/)](https://archive.softwareheritage.org/browse/origin/?origin_url=https://github.com/pucicu/makeinstall)
![license](https://img.shields.io/github/license/pucicu/makeinstall)
![file size](https://img.shields.io/github/repo-size/pucicu/makeinstall)

_the easy way of distributing matlab toolboxes_

Makeinstall needs at least MATLAB 5.3.

> The Makeinstall tool was selected on Oct. 3, 2014, as the _Mathworks File Exchange Pick of the Week_!
>
>» [Pick of the Week](http://blogs.mathworks.com/pick/2014/10/03/make-install/)

Description
-----------

You have a created a toolbox with a lot of MATLAB files and now you need a simple way to distribute this toolbox? With _Makeinstall_ you will be able to automatically create a single `install.m` file, which includes a simple installation routine and all the MATLAB programmes needed for the toolbox. The install script modifies the system in order to use the toolbox instantly. If the `Contents.m` file is missing, it will be automatically created. Furthermore the command `tbclean` will be added to the toolbox folder, which enables to remove the toolbox folder and the entries in `startup.m.`

If the toolbox is Octave compatible, the install file can install the toolbox also within the Octave environment.

This tool uses consequently the MATLAB potential, e.g. the MATLAB standard variables or commands for modifying the MATLAB system (cf. Whitepaper for further details).

_Makeinstall_ is free software; you can redistribute it and/or modify it under the terms of the BSD License.

This programme is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the [BSD License](https://raw.githubusercontent.com/pucicu/makeinstall/master/LICENSE) for more details.

Usage
-----

Call `makeinstall` in the toolbox folder or specify this folder with `makeinstall tb-folder`, for example

```matlab
makeinstall CRPtool
```

In order to initialize some needed variables, call this programme the first time and then modify the entries in the automatically created resource file `makeinstall.rc`. After modifying the resource file, recall `makeinstall` or `makeinstall tb-folder`, respectively.

Please note, that further files will be automatically generated in the toolbox folder if they do not exist yet: `Contents.m`, `info.xml` and `tbclean.m`.

The contents of `Contents.m` will be generated from the help lines in the M-files. If there are no help lines or if this help text is not correctly placed, a warning message will occur. Please ensure that the help text corresponds with the predefined structure of M-files:

```matlab
function p = angle(h)
% ANGLE Polar angle.
%   ANGLE(H) returns the phase angles, in radians, of 
%   a matrix with complex elements. Use ABS for the 
%   magnitudes.
p = atan2(imag(h),real(h));
```

where there is a first help line (H1) below the function line and a following help text. The H1 line is used also by other functions like `lookfor`. If you like to generate `Contents.m` automatically with `makeinstall` although `Contents.m` already exists, you have to remove the old `Contents.m` file. Thus, manual modifications will be kept.

The contents of `info.xml` can be modified with some variables in the resource file `makeinstall.rc`. However, you have to remove the old `info.xml` file, if you like to modify it the next time with `makeinstall`. Thus, manual modifications will be preserved.

The generated file `install.m` will be stored in the folder, from which `makeinstall` was called. It contains the installation script and the MATLAB programmes from the toolbox. This single file can be sent by email or distributed otherwise. Calling `install` from the MATLAB shell extracts the MATLAB programmes into the standard toolbox folder (e.g., `~/matlab/CRPtool` or `C:\Program Files\Matlab\toolbox\crptool`) or a predefined folder (specified during running the Makeinstall script or by calling the install file with a specific folder, e.g., `install /my/folder`) and, optionally, adds the needed toolbox entry permanently in the MATLAB `startup.m` file (at top or end of the startup.m, default is end). The M-files will be automatically precompiled with `pcode`. If the toolbox is already installed, the user will be asked whether the old toolbox should be removed and finally replaced.

For each toolbox folder a separate resource file `makeinstall.rc` can be created. The resource files stores the source and destination directories, the toolbox names and the name of the install file.

To view the text of the BSD License, type `makeinstall bsd`.

License
-------

This software is licensed under the  [BSD License](https://raw.githubusercontent.com/pucicu/makeinstall/master/LICENSE).

Warning
-------

I give no warranty for the tool. Users should make backup files before playing with it.

Screenshot
----------

The screenshot shows the result of calling `install`.

![Screenshot](https://raw.githubusercontent.com/pucicu/makeinstall/master/.src/makeinstall.gif)

Example
-------

An illustration of the install script can be found in the [Cross Recurrence Plot Toolbox](https://tocsy.pik-potsdam.de/CRPtoolbox).

Pre-compiling and Compiling of MEX-Files
----------------------------------------

The install script precompiles the M-files. In principle, it would be also possible to compile potential C or Fortran MEX-files in the same way. However, I have not yet implemented this feature, because I support cross-platform development, and the compiling of MEX-files requires C or Fortran, which is not available on all computers (of course, they could be installed on every platform, but not everyone would like to do this). Moreover, with a consequent vectorized MATLAB development the MEX-file progamming can, sometimes, be obsolete.

Note on including p-files
-------------------------

Per default, p-files (pcoded m-files) are not included in install file, but will be created during the installation process. However, the inclusion of p-files can be forced by setting `include_pfiles=1` in the `makeinstall.rc` file, if there is a need to distribute p-coded scripts and programmes.

How to get/ Installation
------------------------

- [Download](https://raw.githubusercontent.com/pucicu/makeinstall/master/makeinstall.m) the MATLAB script from [Github](https://github.com/pucicu/makeinstall)
- [MATLAB Central](http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=1529&objectType=file)

Put the file `makeinstall.m` into a folder, which can be found by MATLAB (e.g., the `matlabroot` folder).

To Do
-----

- compression (fast compression)

White Paper
-----------

A description about the technology behind the Makeinstall script can be found in a [whitepaper](https://tocsy.pik-potsdam.de/Makeinstall/whitepaper_makeinstall.html).

Bugs/ Problems
--------------

Please send me bug reports or if any problem occured. Don't forget to send me the `makeinstall.rc` and the `install.m` file (if it was created):

marwan@pik-potsdam.de

Thanks
------

I'm grateful for every suggestion and hint which improves this programme. Thanks to Gaetan Koers of Vrije Universiteit Brussel for hints about Windows compatibility and improvement the help-text parser. Thanks also to Volkmar Glauche of University of Hamburg (Universitätsklinikum) and Eduard vander Zwan (Wageningen Universiteit) for useful hints and comments about the root-folder of the toolbox and the `startup.m` entries.

Contact
-------

[Norbert Marwan](https//www.pik-potsdam.de/members/marwan), PIK Potsdam, Germany 
