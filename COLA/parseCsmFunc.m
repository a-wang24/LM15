function [csm] = parseCsmFunc(fileLoc)
% parseCsm takes an input of the file location of the csm file
% and outputs into a structure of three parts
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

%% read file and break up into sections to start to parse
% writes entire conjunction message to a string
str = fileread(fileLoc);
% split the string into segments of the message by '*'
strSeg = strsplit(str, '*');

%% begin to populate the structure details
% start pulling wanted details from strSeg
% break first section into cell array of strings
sec1 = textscan(strSeg{1},'%s');
% create cell array equal length as sec1
% populate same index with 1 that 'TIME:' occupies
timeCellInd = strfind(sec1{1},'TIME:');
% find exact ind of 'TIME:' within cell array
properInd = (find(~cellfun(@isempty,timeCellInd))+1);
endInd = properInd + 4;
i = 1;
% loop through part of sec1 that gives us message creation time
messageTimeArray = cell(1,(endInd-properInd+1));
for m = properInd:endInd
    messageTimeArray{1,i} = sec1{1}{m};
    i = i + 1;
end
% concatenate into string and input into details structure
details.Message_Creation_Time = strjoin(messageTimeArray,' ');

% repeat the process for other five fields of details
sec2 = textscan(strSeg{2},'%s');
closAppCellInd = strfind(sec2{1},'(UTC):');
properInd = (find(~cellfun(@isempty,closAppCellInd))+1);
endInd = properInd + 4;
i = 1;
closAppArray = cell(1,(endInd-properInd+1));
for m = properInd:endInd
    closAppArray{1,i} = sec2{1}{m};
    i = i + 1;
end
details.Time_of_Closest_Approach = strjoin(closAppArray,' ');

missDistCellInd = strfind(sec2{1},'DISTANCE');
properInd = (find(~cellfun(@isempty,missDistCellInd))+2);
details.Miss_Distance = str2double(sec2{1}{properInd});

relSpeedCellInd = strfind(sec2{1},'SPEED');
properInd = (find(~cellfun(@isempty,relSpeedCellInd))+2);
details.Relative_Speed = str2double(sec2{1}{properInd});

relPosCellInd = strfind(sec2{1},'POSITION');
properInd = (find(~cellfun(@isempty,relPosCellInd))+2);
endInd = properInd + 2;
i = 1;
relPos = [ 0 0 0 ];
for m = properInd:endInd
    relPos(i) = str2double(sec2{1}{m});
    i = i + 1;
end
details.Relative_Position = relPos;

relVelCellInd = strfind(sec2{1},'VELOCITY');
properInd = (find(~cellfun(@isempty,relVelCellInd))+2);
endInd = properInd + 2;
i = 1;
relVel = [ 0 0 0 ];
for m = properInd:endInd
    relVel(i) = str2double(sec2{1}{m});
    i = i + 1;
end
details.Relative_Velocity = relVel;

%% Begin to populate asset and conjuncting
% same process as populating details
sec3 = textscan(strSeg{3},'%s');
sec4 = textscan(strSeg{4},'%s');
satSec = {sec3 sec4};

satStruct1 = struct(field1,'',field2,'',field3,0,field4,[0 0 0],field5,0,field6,[0 0 0],field7,zeros(8,8),field8,[0 0 0],field9,[0 0 0]);
satStruct2 = struct(field1,'',field2,'',field3,0,field4,[0 0 0],field5,0,field6,[0 0 0],field7,zeros(8,8),field8,[0 0 0],field9,[0 0 0]);
tempStructArray = {satStruct1 satStruct2};

% since asset and conjuncting are so similar loop through twice for each
% searching different sections each time for respective information
for k = 1:2
    section = satSec{k};
    
    if k == 1
        idCellInd = strfind(section{1},'ASSET:');
        properInd = (find(~cellfun(@isempty,idCellInd))+1);
        tempStructArray{k}.ID_number = section{1}{properInd};
    end
    if k == 2
        idCellInd = strfind(section{1},'CONJUNCTING');
        properInd = (find(~cellfun(@isempty,idCellInd))+2);
        tempStructArray{k}.ID_number = section{1}{properInd};
    end
    
    comNameCellInd = strfind(section{1},'NAME:');
    properInd = (find(~cellfun(@isempty,comNameCellInd))+1);
    % gets a little different here; have to correct for variable length
    % names
    endInd = properInd + 6; %assume no name will be longer than 7 words
    i = 1;
    comNameArray = cell(1,(endInd-properInd+1));
    for m = properInd:endInd
        comNameArray{1,i} = section{1}{m};
        i = i + 1;
    end
    comNameStr = strjoin(comNameArray,' ');
    stopIndex = (regexp(comNameStr,'<>') - 2);
    comName = comNameStr(1:stopIndex);
    tempStructArray{k}.Common_Name = comName;
    
    tlobsCellInd = strfind(section{1},'OB:');
    properInd = (find(~cellfun(@isempty,tlobsCellInd))+1);
    if isempty(properInd)
        tlobsCellInd = strfind(section{1},'(UTC):');
        properInd = (find(~cellfun(@isempty,tlobsCellInd))+1);
        endInd = properInd + 4;
        i = 1;
        tlobsArray = cell(1,(endInd-properInd+1));
        for m = properInd:endInd
            tlobsArray{1,i} = sec2{1}{m};
            i = i + 1;
        end
        tlObs = strjoin(tlobsArray,' ');
    else
        tlObs = section{1}{properInd};
    end
    tempStructArray{k}.Time_of_Last_Obs = tlObs;
    
    orbParCellInd = strfind(section{1},'APOGEE');
    properInd = (find(~cellfun(@isempty,orbParCellInd))+2);
    endInd = properInd +6;
    orbPar = [ 0 0 0 ];
    i = 1;
    for m = properInd:3:endInd
        orbPar(i) = str2double(section{1}{m});
        i = i + 1;
    end
    tempStructArray{k}.Orbit_Parameters = orbPar;
    
    sizeCellInd = strfind(section{1},'(SCALED):');
    properInd = (find(~cellfun(@isempty,sizeCellInd))+1);
    if isempty(properInd)
        sizeCellInd = strfind(section{1},'(M2):');
        properInd = (find(~cellfun(@isempty,sizeCellInd))+1);
    end
    size = section{1}{properInd};
    tempStructArray{k}.Size = size;
    
    coeff = [ 0 0 0 ];
    ballCellInd = strfind(section{1},'BALLISTIC');
    properInd = (find(~cellfun(@isempty,ballCellInd))+3);
    coeff(1) = str2double(section{1}{properInd});
    pressCellInd = strfind(section{1},'PRESSURE');
    properInd = (find(~cellfun(@isempty,pressCellInd))+3);
    coeff(2) = str2double(section{1}{properInd});
    dissCellInd = strfind(section{1},'DISSIPATION');
    properInd = (find(~cellfun(@isempty,dissCellInd))+3);
    coeff(3) = str2double(section{1}{properInd});
    tempStructArray{k}.Parameter_Values = coeff;
    
    posCellInd = strfind(section{1},'POSITION');
    properInd = (find(~cellfun(@isempty,posCellInd))+2);
    endInd = properInd +2;
    position = [0 0 0];
    i = 1;
    for m = properInd:endInd
        position(i) = str2double(section{1}{m});
        i = i + 1;
    end
    tempStructArray{k}.Position = position;
    
    veloCellInd = strfind(section{1},'VELOCITY');
    properInd = (find(~cellfun(@isempty,veloCellInd))+2);
    endInd = properInd +2;
    velocity = [0 0 0];
    i = 1;
    for m = properInd:endInd
        velocity(i) = str2double(section{1}{m});
        i = i + 1;
    end
    tempStructArray{k}.Velocity = velocity;
end

%set asset and conjuncting
asset = tempStructArray{1};
conjuncting = tempStructArray{2};
% now input the covariance matrices into asset and conjuncting
sec5Str = strSeg{5};
sec6Str = strSeg{6};
assetCov = zeros(8,8);
conjCov = zeros(8,8);
% pull the covariance data from sec 5 and sec 6; only pull doubles in
% scientific notation format
sec5Data = regexp(sec5Str,'\d*[.]\d*E[+]\d*','match');
sec6Data = regexp(sec6Str,'\d*[.]\d*E[+]\d*','match');
% first 36 entries of sec5data are for asset, last 36 are for conjuncting
m = 1;
if m < 37
    for i = 1:6
        for j = 1:6
            assetCov(i,j) = str2double(sec5Data(m));
            m = m + 1;
        end
    end
end
if m > 36
    for i = 1:6
        for j = 1:6
            conjCov(i,j) = str2double(sec5Data(m));
            m = m + 1;
        end
    end
end
% last two rows are drag effects and solar radiation pressure effects
% first 16 entries are for asset, last 36 for conjuncting
m = 1;
if m < 17
    for i = 7:8
        for j = 1:8
            assetCov(i,j) = str2double(sec6Data(m));
            m = m + 1;
        end
    end
end
if m > 16
    for i = 7:8
        for j = 1:8
            conjCov(i,j) = str2double(sec6Data(m));
            m = m + 1;
        end
    end
end
covSum = sum(assetCov(:));
while covSum == 0
    MatrixCovGUI;
    gui = findobj('Tag','covDataGUI');
    uiwait(gui);
    posCov = getappdata(f,'covPosMatrix');
    velCov = getappdata(f,'covVelMatrix');
    assetCov(1:3,1:3) = posCov;
    assetCov(1:3,4:6) = velCov;
    covSum = sum(assetCov(:));
end
asset.Covariance = assetCov;
conjuncting.Covariance = conjCov;

%% return final structure
csm = struct('details',details,'asset',asset,'conjuncting',conjuncting);

end

