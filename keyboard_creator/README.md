# Acheron Project Keyboard Creator

A tool to create a KiCAD keyboard project using the Acheron Libraries.

This keyboard creator tool also encloses the tolerances and rules used for the Acheron Project in the keyboard PCB projects, uniformizing their design.

## Introduction

The Keyboard Creator is a GNU Makefile-based tool to create a KiCAD keyboard project. Its dependencies are git and the ssh to operate remote repositories in a GNU environment. This Makefile has been developed and tested in bash using GNU Makefile; no other platform or terminal was tested.

## Usage

Copy the contents of ```./core-files``` into a folder; open a terminal and change directory into that folder; then run ```make create```.

This will, in this order,

- Initialize the root folder as a git repository and change the current repository name to `main`;
- Create a folder ```kicad_files``` with:
 - A KiCAD project file ```project.kicad_pro```
 - A KiCAD PCB layout file ```project.kicad_pcb```
 - A KiCAD schematic file ```project.kicad_sch```
 - A KiCAD libraries backup file ```project.kicad_prl```
 - A symbol library table ```sym-lib-table```
 - A footprint library table ```fp-lib-table```
- Create a libraries folder ```./kicad_files/libraries``` folder where the following libraries will be added. Each library is automatically added to the respective library tables:
 - acheron_Symbols
 - acheron_Components.pretty
 - acheron_Connectors.pretty
 - acheron_Hardware.pretty
 - acheron_MX.pretty **(*)**
 - acheron_Graphics.pretty
 - acheron_Logos.pretty

In the end the ```./kicad_files``` folder will contain a fully working KiCAD project with ready to use added libraries.

## Options

Additionally, the ```create``` target also admits passing arguments in the commandline.

- ```SWITCHTYPE=<type>``` is used to modify what switch type library you want to add, as long as it is a valid Acheron Library repository. The Makefile command attempts to add the library ```git@github.com:AcheronProject/acheron_<type>.pretty``` . It defaults to ```MX```, that is, the solderable MX-compatible switch library. Example usage: ```make create SWITCHTYPE=MX_SolderMask``` will instead add the library with solderable MX-comptible switches with soldermask covered front pads. As of april 2021 the available libraries are
 - Solderable MX-style switches:
   - ```MX```: your run-of-the-mill MX-style solderable switches;
   - ```MX_SolderMask```: soldermask-covered front pads (considered to be more aesthetic);
 - Hotswap MX-style switches using Kailh's CPG151101S11 socket:
   - ```MXH```: the default manufacturer-recommended footprints;
   - ```MXH_MetalRings```: metallic rings around the contact holes (considered to be more aesthetic);
   - ```MXH_WaffleMount```: containing "waffle" pattern stress-relief vias on the SMD pads to make the sockets more robust and harder to break apart from the PCB;
 - Non-MX-style switches:
   - ```MXA```: solderable MX and Alps-compatible footprints;
   - ```Choc```: solderable Kailh Choc swithces;
   - ```MX_SMK```: solderable MX and SMK-compatible footprints;
   - ```Alps```

- ```NOGRAPHICS=FALSE``` will prompt the script to also add the ```acheron_Graphics.pretty``` library with various graphics. The same for ```NOLOGOS=FALSE```. Both default to true.
- ```PRJNAME=<name>``` is used to make the script name the files with the project name you want
- ```KICADDIR``` and ```LIBDIR```: by default, the makefile will create a ```./kicad_files``` folder with the KiCAD files and library tables; inside this folder, there will be a ```libraries``` folder inside which the libraries will be added as submodules. ```make create KICADDIR=<dir1> LIBDIR=<dir2>``` will override that behavior.
- ```CLEANCREATE=TRUE``` will delete ```Makefile``` and the ```blankproject```, leaving only the created files and the ```.git``` folder. This argument defaults to false, that is, leaving those files intact after the process.
- ```3DLIB=TRUE``` will also download the ```acheron_3D``` library with the 3D step files used in the acheron project.

## Design notes

The PCB files generated contain a myriad of information regarding tolerances, usage and copper pours. These informations are replicated here.

### Usage comments

This PCB file was generated through the Acheron Setup script, an automated tool to generate design-ready KiCAD schematic and PCB files for keyboard projects; it is offered under a no-liability, as-is clause. Please visit http://github.com/AcheronProject/AcheronSetup for more information.

The files generated are compatible with KiCAD developmental ("nightly") versions up to august 16, 2021 version. These files should also be accompanied of a librires folder where the used libraries are added as submodules which last commit should point to the remote's HEAD; please note that the files need such libraries to fully work.

For requests/issues please submit a issue in the github folder. Do not attempt to contact the developers directly. We ask that bugs/problems be reported through the issues page too.

### Notes on tolerances

The tolerances used might seem too loose or big, but these are the bare large-scale manufacturable values found through experience using multiple factories. Adjust the values at your own discretion, but be very mindful of these tolerances as they are imperative for the manufacturing process and feasibility of the final PCB.

The values used divide into two groups: the "factory minimum" and the "recommended minimum" ones:

- **"Factory minimums"** are the values minimally feasible needed by factories. Different ones will inevitably have different numbers, but through using multiple a common denominator was found. these values should not be used often, but seldomly at the designer's discretion and in ultimate case. Their use will incurr in higher manufacturing fees, larger lead times, more quality check issues (PCBs failing after large production).

- **"Recommended minimums"** are the smalles tolerances doable with no fabrication or quality control issues. These can be safely used without incurring in higher costs or major large-scale production issues. There is no particular reason for any of these but experience through usage of many factories. This KiCAD file was set to use the recommended values in its Design Rule Checks and routines; these values were used successfully throughout the Acheron Project and are proven to work.

Keep in mind that these are, after all, minimum values. Always try to stray away from them when there is chance, so as to give you and the factory headroom to work with. The actually used values can very well vary according to your specifications and the capabilities of the factory being used.

### Notes on copper pours

Many DIY designers will state that the usage of copper pours is perfeccionism; in some cases, designers will argue that the pours are actually detrimental to the design, while I (gondolindrim) disagree with the former I agree with the latter in some respects. Ground pours are an integral part of digital high-speed signal design; since most (if not all) modern keyboards work under USB communication which uses differential pair topology, a ground copper pour is absolutely needed to ensure proper return currents paths, low ground impedance, EMI resistance, efficiency in ESD protection, protection from overheating, and so on. Particularly in keyboard PCBs, however, the copper pours make the PCBs stiffer, reducing what is known as "flex". The way to countermeasure that is by deploying flex cuts (also known as relief cuts) or leaf-spring mounting points. Use copper pours are your discretion but I (Gondolindrim) recommend always using them. My designs make liberal use of such pours even for other signals.

### Used tolerances

**IMPORTANT!** : The values and observations here listed consider a two-layer, 1 oz/ft² copper weight PCB setting. A change in these parameters (layers and copper weight) will unequivocably change the minimum values. DO NOT use these values in other settings; always coordinate properly with the factory for that. All values are given in milimeters.

- **Factory minimums**
 - **Track width**: 0.15
 - **Copper clearance**: 0.15 (see [1])
 - **VIA hole**: 0.2
 - **VIA annular width**": 0.13
 - **VIA diameter**: 0.4
 - **Copper-to-hole clearance**: 0.3 (see [3])
 - **Copper-to-edge clearance**: 0.2
 - **Minimum through hole drill**: 0.2
 - **Hole-to-hole clearance**: 0.5
 - **Silkscreen character height**: 0.8
 - **Silkscreen trace width**: 0.15
 - **Silkscreen character height-to-trace ratio**: 1:6
 - **Pad-to-silkscreen clearance**: 0.15
 - **Soldermask expansion**: 0.05
 - **Minimum soldermask bridge**: 0.2

- **Recommended minimums**
 - **Track width**: 0.2
 - **Copper clearance**: 0.2 (see [1])
 - **VIA hole**: 0.3
 - **VIA annular width**": 0.15
 - **VIA diameter**: 0.6
 - **Copper-to-hole clearance**: 0.35 (see [3])
 - **Copper-to-edge clearance**: 0.5 (see [4])
 - **Minimum through hole drill**: 0.3
 - **Hole-to-hole clearance**: 0.5
 - **Silkscreen character height**: 1.0
 - **Silkscreen trace width**: 0.2
 - **Silkscreen character height-to-trace ratio**: 1:5
 - **Pad-to-silkscreen clearance**: 0.2
 - **Soldermask expansion**: 0.1
 - **Minimum soldermask bridge**: 0.25

Observations:

- [1] Official copper-copper clearances are 0.2mm but not exactly "all copper". Pad-to-pad minimums are 0.5mm in the case of THT pads and 0.2mm for SMD pads.
- [2] The recommended ratio between silkscreen character height and its trace width so they are clearly legible.
- [3] The hole-to-copper clearance changes on occasion. For instance, via-to-track and NPTH-to-track clearance is 0.25mm but PTH-to-track is 0.3.
- [4] The distance of copper-to-edge is a big problem for fabs in designs where traces need to be close to certain slots or the edges, like keyboard PCBs with flex cuts where the PCB traces need to be routed close to the flex cuts for lack of real-estate. This is why this value is much higer than the fabrication ones.
- [5] The 1:6 ratio for silkscreen is OK for large characters but can become unreadable to the naked eye on a 1mm character. A 1:5 ratio is recommended.
