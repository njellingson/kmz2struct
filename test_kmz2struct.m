% Get directory of test file
[current_directory,~,~] = fileparts(mfilename('fullpath'));

% Create equality for floading point numbers
about_equal = @(x,y) all(abs(x-y) < 0.0001);

%% Test 1: Load Plate Boundries from a USGS Provied KMZ File
S = kmz2struct(fullfile(current_directory,'example-kmz','plate-boundaries.kmz'));
T = struct2table(S);

% Check geometry
geometries = unique(T.Geometry,'sorted');
assert(isequal(geometries,{'Line';'Point'}),'Plate boundry KMZ should only have two geometry types: Line and Point')

% Check if Tamayo Fracture Zone (a line) is loaded correctly
tamayo_fracture_zone_index = find(strcmp(T.Name,'Tamayo Fracture Zone'));
assert(length(tamayo_fracture_zone_index) == 1,'Tamayo Fracture Zone not found or found more than once.')
tamayo_fracture_zone = T(tamayo_fracture_zone_index,:);
assert(strcmp(tamayo_fracture_zone.Geometry,'Line'),'Tamayo Fracture Zone is a line.')
assert(isequal(tamayo_fracture_zone.Color,[1 0 0]),'Tamayo Fracture Zone must be red.')
assert(strcmp(tamayo_fracture_zone.Folder,'/Micro Plates and Major Fault Zones'),'Wrong folder for Tamayo Fracture Zone')
assert(about_equal(tamayo_fracture_zone.Lat{1}(1),21.7990),'Starting latitude of Tamayo Fault Zone is wrong.')
assert(about_equal(tamayo_fracture_zone.Lon{1}(1), -106.8900),'Starting longitude of Tamayo Fault Zone is wrong.')

%% Test 2: Load Data About Prospect- and mine-related features in DC on USGS topographic maps
S = kmz2struct(fullfile(current_directory,'example-kmz','usmin-DC.kmz'));
T = struct2table(S);

% Check geometry
geometries = unique(T.Geometry,'sorted');
assert(isequal(geometries,{'Point';'Polygon'}),'Mine data KMZ should only have two geometry types: Point and Polygon')
assert(isequal(T.Name,{'(Open Pit Mine or Quarry)';'(Disturbed Surface)'}),'Placemark names were not read correctly from DC mine kmz file.')

% Check data about point (index 1)
assert(about_equal(T.Lat{1}(1),38.8584),'Latitude of point is wrong.')
assert(about_equal(T.Lon{1}(1),-76.9838),'Longitude of point is wrong.')

% Check data about polygon (index 2)
assert(about_equal(T.Color(2,:),[1.0000    1.0000    0.5373]),'Polygon color should be light yellow')
assert(about_equal(T.Lat{2}(1),38.8096),'Latitude of first point in Polygon is wrong.')
assert(about_equal(T.Lon{2}(1),-77.0190),'Longitude of first point in Polygon is wrong.')

%% Load Google KML Sample Data to Validate That Plain KML's Also Load
S = kmz2struct(fullfile(current_directory,'example-kmz','KML_Samples.kml'));
T = struct2table(S);
assert(height(T)==18,'Loaded wrong number of geometries.')
