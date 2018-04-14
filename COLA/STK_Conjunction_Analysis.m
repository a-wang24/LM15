% Alan Wang August 5, 2015
% Matlab to STK - Conjunction Analysis
% This script will populate an STK scenario with satellites from OCM

%% connect to running instance of STK, if none open a new instance
try
    app = actxGetRunningServer('STK10.application');
catch
    app = actxserver('STK10.applicaton');
end

% attach to STK object model and set visible to true
root = app.Personality2;
app.visible = 1;

% if no open scenario, check to see if scenario already exists; if it does
% exist load it, if not then start a new one
% if there is an open scenario, close it and same process as above
if isnan(root.CurrentScenario())
    try
        filename = input('Please enter the directory of the STK scenario to be modified: ', 's');
        root.LoadScenario(filename);
    catch
        filename = input('The file could not be opened. Please enter the name of the STK scenario to be created: ','s');
        root.NewScenario(filename)
    end
else
    root.CloseScenario();
    try
        filename = input('Please enter the directory of the STK scenario to be modified: ', 's');
        root.LoadScenario(filename);
    catch
        filename = input('The file could not be opened. Please enter the name of the STK scenario to be created: ','s');
        root.NewScenario(filename)
    end
end

%% extract data from OCM using parseCsm function
ocm = input('Please enter the directory of the OCM file to be read: ','s');

try
    csm = parseCsmFunc(ocm);
catch
    warning('The file could not be opened. Please input a correct directory');
end

%% Create asset and conjuncting satellite in STK from OCM data
assetSat = root.CurrentScenario.Children.New('eSatellite','asset');
conjSat = root.CurrentScenario.Children.New('eSatellite','conjuncting');

% propagator to HPOP
assetSat.SetPropagatorType('ePropagatorHPOP');
conjSat.SetPropagatorType('ePropagatorHPOP');
assHpop = assetSat.Propagator;
conjHpop = conjSat.Propagator;



