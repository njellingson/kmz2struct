# About
This function converts KML and KMZ files into a MATLAB structure. If converting a KMZ file, this function extracts the KMZ to a directory called '.kml2struct' in the home directory. This directory is deleted when the function exits.

The output of this function is similar to the MATLAB `shaperead`. It also adds fields for:
- ***Folder*** - The KML folder where the shape exists.
- ***Color*** - The color of the shape as a three element row vector in RGB format.

This function only handles KML/KMZ files with `Point`, `LineString`, and `Polygon` geometries. If this function is used to read a KML/KMZ with other elements, they are omitted from the result.

# Installation
The easiest way to install this function is to download it from the link below then add the kmz2struct.m file to your matlab path.

[![View kmz2struct on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/70450-kmz2struct)

# Usage
To load a KML/KMZ file with this function, use the function like this:
```
S = kmz2struct(filename)
```
- ***filename*** - The full or relative path to KML/KMZ file you wish to load.
- ***S*** - The data loaded from the KML/KMZ file in MATLAB structure format.

If a MATLAB table is preferred, use the MATLAB `struct2table` function:
```
S = kmz2struct(filename)
T = struct2table(S)
```
- ***T*** - The data loaded from the KML/KMZ file as MATLAB table object.

# Development Strategy
The `kmz2struct` function performs the following steps:
- ***Unzip KMZ Files*** - If `filename` is a KMZ file, the kmz2struct function unzips it to the `.kmz2struct` folder in the user's home directory.
- ***Loop Through KML Files Within The Unzipped folder*** - Loop through the unzipped folder and find the KML files. If a KML file is provided no looping is required.
- ***Load Each KML File As A DOM*** - Use the MATLAB `xmlread` function to load the KML file as a Document Object Model (DOM). This method is slightly slower than attempting to load the file with a regular expression, but this method makes it easier to track the folder for each geometry.
- ***Load All the Styles From The KML*** - Load all the styles from the KML. KML styles contain the colors that need to be linked to geometries later.
- ***Recursively Search The KML Folders For Geometries*** - Search the KML file for geometries recursively. Track the folder in which each geometry is found. 
- ***Load Each Geometry*** - Load each geometry found from the DOM into a structure. Link the geometry to a style to find the color.
- ***Use A Regular Expression To Read In Coordinates*** - Use a regular expression to read in coordinates. This is a much faster way load to coordinates in. Add coordinates to the structure.
- ***Combine The Structure From Each Geometry*** - Combine all the structures to output a structure array.

# Future Improvements
- Load more types of KML/KMZ data.
- Use regular expressions to improve the performance of part or all of the `kmz2struct` function.
- Matpak integration?

Feel free to open a pull request!