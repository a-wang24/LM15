function [cdm] = parseCdmFunc(fileLoc)
%parseCdmFunc takes an input of the file location of an cdm file
% outputs into a structure of three parts
% the three parts are structures themselves consisting of contents on
% the details of the conjuction, the asset, and the conjuncting satellite

%% Initiate the structures that we want to output

% establish field we want for details
detF1 = 'Message_Creation_Time'; %UTC time as string
detF2 = 'Time_of_Closest_Approach'; %UTC time as string
detF3 = 'Miss_Distance'; %scalar double in meters
detF4 = 'Relative_Speed'; %scalar double as m/s
detF5 = 'Relative_Position'; %vector in asset UVW frame
detF6 = 'Relative_Velocity'; %vector in asset UVW frame
% details has 6 fields
% initiating them as 0 or empty to fill later from csm
details = struct(detF1,'',detF2,'',detF3,0,detF4,0,detF5,[0 0 0],detF6,[0 0 0]);

% establish fields we want for asset and conjuncting
% information categories for each will be identical so we can reuse field
% variables
field1 = 'ID_number'; %string of five digits --> could change to scalar if needed
field2 = 'Common_Name'; %string
field3 = 'Time_of_Last_Obs'; %string <24, 24-48, >48 hours since last obs
field4 = 'Orbit_Parameters'; %vector of apogee,perigee,inclination in that order
field5 = 'Size'; %string >1,0.1-1,<0.1 m^s respectively
field6 = 'Parameter_Values'; %vector of ballistic coeff, solar radiation pressure, energy dissipation rate
field7 = 'Covariance'; %8x8 matrix
field8 = 'Position'; %array of position
field9 = 'Velocity'; %velocity in the TDR coord frame
% asset and conjuncting are structures with 8 fields
% initiate them as 0 or empty to fill later from csm
asset = struct(field1,'',field2,'',field3,0,field4,[0 0 0],field5,0,field6,[0 0 0],field7,zeros(8,8),field8,[0 0 0],field9,[0 0 0]);
conjuncting = struct(field1,'',field2,'',field3,0,field4,[0 0 0],field5,0,field6,[0 0 0],field7,zeros(8,8),field8,[0 0 0],field9,[0 0 0]);

% initiate final structure, csm, that we will output
% csm = struct('details',details,'asset',asset,'conjuncting',conjuncting);

%% read file into a string
str = fileread(fileLoc);

%% begin to  populate structure details












end

