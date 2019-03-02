function kmlStruct = kmz2struct(filename)
    [~,~,ext] = fileparts(filename);
    
    if strcmpi(ext,'.kmz')
        userDir = [char(java.lang.System.getProperty('user.home')) '\.kml2struct\'];
        if ~exist(userDir,'dir')
            mkdir(userDir);
        end
        unzip(filename, userDir);
        
        files = dir([userDir '**\*.kml']);
        N = length(files);
        kmlStructs = cell([1 N]);
        for i = 1:length(files)
            xDoc = xmlread(fullfile(files(i).folder,files(i).name));
            start =  xDoc.item(0).item(1);
            kmlStructs{i} = recursive_kml2struct(start,'');
        end
        kmlStruct = horzcat(kmlStructs{:});
        
        rmdir(userDir,'s');
    else
        xDoc = xmlread(filename);
        start =  xDoc.item(0).item(1);
        kmlStruct = recursive_kml2struct(start,'');
    end
end
function kmlStruct = recursive_kml2struct(folder_element,folder)

    % Find number of placemarks and name of folder
    name = 'none';
    number_placemarks = 0;
    for i = 0:folder_element.getLength()-1
        if strcmp(folder_element.item(i).getNodeName,'Placemark')
            number_placemarks = number_placemarks + 1;
        elseif strcmp(folder_element.item(i).getNodeName,'name')
            name = char(folder_element.item(i).getTextContent);
        end
    end
    if strcmpi(folder_element.getNodeName,'Folder')
        folder = [folder '/' name];
    end

    % Find Placemark Data
    count = 1;
    kmlStructs = cell([1 number_placemarks]);
    for i = 0:folder_element.getLength()-1
        current = folder_element.item(i);
        NodeName = current.getNodeName;
        if strcmpi(NodeName,'Folder')
            kmlStructs{count} = recursive_kml2struct(current,folder);
            count = count + 1;
        elseif strcmpi(NodeName,'Placemark')
            kmlStructs{count} = parsePlacemark(current,folder);
            count = count + 1;
        end
    end
    kmlStruct = horzcat(kmlStructs{:});
end
function kmlStruct = parsePlacemark(element,folder)
    name = char(element.getElementsByTagName('name').item(0).getTextContent);
    description = char(element.getElementsByTagName('description').item(0).getTextContent);
    
    number_features = element.getElementsByTagName('coordinates').getLength();
    kmlStructs = cell([1 number_features]);
    count = 1;
    
    % Handle Points
    points = element.getElementsByTagName('Point');
    for i = 0:points.getLength()-1
        coords = char(points.item(i).getElementsByTagName('coordinates').item(0).getTextContent);
        [Lat,Lon] = parseCoordinates(coords);
        
        kmlStructs{count}.Geometry = 'Point';
        kmlStructs{count}.Name = name;
        kmlStructs{count}.Description = description;
        kmlStructs{count}.Lon = Lon;
        kmlStructs{count}.Lat = Lat;
        kmlStructs{count}.BoundingBox = [min(Lon) min(Lat);max(Lon) max(Lat)];
        kmlStructs{count}.Folder = folder;
        count = count + 1;
    end
    
    % Handle Polygons
    polygons = element.getElementsByTagName('Polygon');
    for i = 0:polygons.getLength()-1
        coords = char(polygons.item(i).getElementsByTagName('coordinates').item(0).getTextContent);
        [Lat,Lon] = parseCoordinates(coords);
        
        kmlStructs{count}.Geometry = 'Polygon';
        kmlStructs{count}.Name = name;
        kmlStructs{count}.Description = description;
        kmlStructs{count}.Lon = [Lon;NaN]';
        kmlStructs{count}.Lat = [Lat;NaN]';
        kmlStructs{count}.BoundingBox = [min(Lon) min(Lat);max(Lon) max(Lat)];
        kmlStructs{count}.Folder = folder;
        count = count + 1;
    end
    
    % Handle Lines
    lines = element.getElementsByTagName('LineString');
    for i = 0:lines.getLength()-1
        coords = char(lines.item(i).getElementsByTagName('coordinates').item(0).getTextContent);
        [Lat,Lon] = parseCoordinates(coords);
        
        kmlStructs{count}.Geometry = 'Line';
        kmlStructs{count}.Name = name;
        kmlStructs{count}.Description = description;
        kmlStructs{count}.Lon = Lon';
        kmlStructs{count}.Lat = Lat';
        kmlStructs{count}.BoundingBox = [min(Lon) min(Lat);max(Lon) max(Lat)];
        kmlStructs{count}.Folder = folder;
        count = count + 1;
    end
     
    % Compile answers
    kmlStruct = horzcat(kmlStructs{:});
end

function [Lat,Lon] = parseCoordinates(string)
    coords = str2double(regexp(string,'[,\s]+','split'));
    coords(isnan(coords)) = [];
    [m,n] = size(coords);
    if length(coords) == sum(string==',') * 2
        coords = reshape(coords,2,m*n/2)';
    else
        coords = reshape(coords,3,m*n/3)';
    end
    [Lat, Lon] = poly2ccw(coords(:,2),coords(:,1));
end