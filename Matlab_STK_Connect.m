% Alan Wang Jun 29 2015
% Astrogator-STK to Matlab Interface
% This script models a basic Hohmann transfer using the interface between
% Matlab and STK, specifically the Astrogator propagator

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
        % input correct directory below as string
        root.LoadScenario('C:\Users\e303162\Documents\STK 10\DIY_MATLAB\Matlab_Astrogator_DIY.sc');
    catch
        root.NewScenario('Matlab_Astrogator_DIY')
    end
else
    root.CloseScenario();
    try
        % input correct directory below as string
        root.LoadScenario('C:\Users\e303162\Documents\STK 10\DIY_MATLAB\Matlab_Astrogator_DIY.sc');
    catch
        root.NewScenario('Matlab_Astrogator_DIY')
    end
end

%% Create a new satellite
satellite = root.CurrentScenario.Children.New('eSatellite','Sat1');
% Set astrogator as propagator
satellite.SetPropagatorType('ePropagatorAstrogator');
% Create handle to Astrogator portion of satellites object model; not
% Necessary but for convenience sake
ASTG = satellite.Propagator;

% Create handle for main sequence and clear it
MCS = ASTG.MainSequence;
MCS.RemoveAll;

% Define initial state
initState = MCS.Insert('eVASegmentTypeInitialState','LEO','-');

% Configure properties of initial state
initState.SetElementType('eVAElementTypeModKeplerian');
initState.Element.PeriapsisAltitude = 200;
initState.Element.Eccentricity = 0.015;
initState.Element.Inclination = 28.5;
initState.Element.RAAN = 0;
initState.Element.ArgOfPeriapsis = 0;
initState.Element.TrueAnomaly = 0;

%% Propagate the LEO to periapsis
% Change the segment color, stopping condition, etc
propToPeri = MCS.Insert('eVASegmentTypePropagate','Prop to Peri','-');
% Object Model colors must be set with decimal values, but can be easily
% converted from hex values. table with some examples from STK help guide
% Name     RGB            BGR            Hex      Decimal
% Red     255, 0, 0      0, 0, 255      0000ff    255
% Green   0, 255, 0      0, 255, 0      00ff00    65280
% Blue    0, 0, 255      255, 0, 0      ff0000    16711680
% Cyan    0, 255, 255    255, 255, 0    ffff00    16776960
% Yellow  255, 255, 0    0, 255, 255    00ffff    65535
% Magenta 255, 0, 255    255, 0, 255    ff00ff    16711935
% Black   0, 0, 0        0, 0, 0        000000    0
% White   255, 255, 255  255, 255, 255  ffffff    16777215
Red = '0000ff';
Green = '00ff00';
Blue = 'ff0000';
Cyan = 'ffff00';
Yellow = '00ffff';
Magenta = 'ff00ff';
Black = '000000';
White = 'ffffff';

propToPeri.Properties.Color = uint32(hex2dec(Cyan));

% Configure stopping conditions
propToPeri.StoppingConditions.Add('Periapsis');
propToPeri.StoppingConditions.Remove('Duration');

%% Insert Target Sequence
% add target sequence to main sequence
firstBurn = MCS.Insert('eVASegmentTypeTargetSequence','1st Burn','-');
% set characteristics of Target Sequence to run active profiles; '1' is
% active profiles and '0' is nominal sequence
firstBurn.Action = 1;
% configure target sequence 'when profiles finish', default is 'Run to RETURN and continue'? 
%firstBurn.WhenProfilesFinish

% nest a maneuver to initiate hohmann transfer, set color to red
raiseAPO = firstBurn.Segments.Insert('eVASegmentTypeManeuver','Raise APO','-');
raiseAPO.Properties.Color = uint32(hex2dec(Red));
%Select characteristics of maneuver
raiseAPO.SetManeuverType('eVAManeuverTypeImpulsive');
% Create handle for impulsive properties of maneuver
impulsive = raiseAPO.Maneuver;
impulsive.SetAttitudeControlType('eVAAttitudeControlVelocityVector');
% Create handle to Attitude Control and set DV
veloVector = impulsive.AttitudeControl;
veloVector.DeltaVMagnitude = 1000;
% enable DV as control parameter to allow targeter to vary property
raiseAPO.EnableControlParameter('eVAControlManeuverImpulsiveDeltaVMagnitude');

% nest a propagate segment
propToAPO = firstBurn.Segments.Insert('eVASegmentTypePropagate','Prop to APO','-');
propToAPO.Properties.Color = uint32(hex2dec(Red));
propToAPO.StoppingConditions.Add('Apoapsis');
propToAPO.StoppingConditions.Remove('Duration');

% finish configuring targeter
% create a handle for targeter control and set properties
dc = firstBurn.Profiles.Item('Differential Corrector');
dVControlParam = dc.Controlparameters.GetControlByPaths('Raise Apo','ImpulsiveMnvr.DeltaVMagnitude');




































