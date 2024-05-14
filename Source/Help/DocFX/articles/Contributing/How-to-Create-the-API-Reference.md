# How to create the API reference

## Prerequisites
* [Tools](#tools)
* [Details](#details)

## Tools

* A current copy of [Sandcastle Help File Builder](https://github.com/EWSoftware/SHFB/releases)
* Documentation project files, available from [here](https://github.com/Krypton-Suite/Help-Files)
* Built binaries and documentation files
* Time

## Details

Open up `Full Toolkit Documentation (Markdown) - Empty Project` in Sandcastle Help File Builder, add **both** the compiled binaries and XML files to 'Documentation Sources', then build the project.

Once built, copy the contents from `Help` located in the root directory over to `Documents\API Reference\<Project Name>` then upload.