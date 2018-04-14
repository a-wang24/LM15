% This script walks through the basic functions of the STK Astrogator Object
% Model by building the Hohmann Transfer Using a Targeter tutorial
% exercise, found in the STK Help. A version of this code using C# can be
% found in <STK Install>\CodeSamples\CustomApplications\CSharp\HohmannTransferUsingTargeter

%%%
% Basic introduction to using the STK Object Model with MATLAB
% More thorough examples can be found at the AGI Developer Network
% http://adn.agi.com
%%%

% Launch a new instance of STK
uiapp = actxserver('STK9.Application');
% or to grab an already open instance of STK
%uiapp = actxGetRunningServer('STK9.Application');

% Attach to the STK Object Model
root = uiapp.Personality2;


% Create a new scenario
root.NewScenario('ASTG_OM_Test')
% if one already exists, you can access it as in the examples below

% Create a new satellite. See STK Programming Interface Help to see that
% the enumeration for a Satellite object is 'eSatellite' with a value of 18
sat = root.CurrentScenario.Children.New(18, 'ASTG_Sat');
% or connect to an already existing satellite
%sat = root.CurrentScenario.Children.Item('Satellite1');

% Set the new Satellite to use Astrogator as the propagator
sat.SetPropagatorType('ePropagatorAstrogator')
% Note that Astrogator satellites by default start with one Initial State
% and one Propagate segment

% Create a handle to the Astrogator portion of the satellites object model
% for convenience
ASTG = sat.Propagator;

% In MATLAB, you can use the .get command to return a list of all
% "attributes" or properties of a given object class. Examine the
% Astrogator Object Model Diagram to see a depiction of these.
ASTG.get
%    MainSequence: [1x1 Interface.AGI_STK_Astrogator_9.IAgVAMCSSegmentCollection]
%         Options: [1x1 Interface.AGI_STK_Astrogator_9._IAgVAMCSOptions]
%    AutoSequence: [1x1 Interface.AGI_STK_Astrogator_9.IAgVAAutomaticSequenceCollection]

% In MATLAB, you can use the .invoke command to return a list of all
% "methods" or functions of a given object class. Examine the Astrogator
% Object Model Diagram to see a depiction of these.
ASTG.invoke
% 	RunMCS = void RunMCS(handle)
% 	BeginRun = void BeginRun(handle)
% 	EndRun = void EndRun(handle)
% 	ClearDWCGraphics = void ClearDWCGraphics(handle)
% 	ResetAllProfiles = void ResetAllProfiles(handle)
% 	ApplyAllProfileChanges = void ApplyAllProfileChanges(handle)
% 	AppendRun = void AppendRun(handle)
% 	AppendRunFromTime = void AppendRunFromTime(handle, Variant, AgEVAClearEphemerisDirection)
% 	AppendRunFromState = void AppendRunFromState(handle, handle, AgEVAClearEphemerisDirection)
% 	RunMCS2 = AgEVARunCode RunMCS2(handle)

% At any place in the STK or Astrogator OM, use the .get or .invoke
% commands to inspect the structure of the object model and help find the
% desired properties or methods

%%%
% Adding and Removing segments
%%%

% Collections
% In the OM, groupings of the same kind of object are referred to as
% Collections. Examples include Sequences (including the MainSequence and
% Target Sequences) which hold groups of segments, Segments which may hold
% groups of Results, and Propagate Segments which may hold groups of
% Stopping Conditions.
% In general, all Collections have some similar properties and methods and
% will be interacted with the same way. The most common elements of a
% Collection interface are
%   Item(argument) - returns a handle to a particular element of
%   the collection
%   Count - the number of elements in this collection
%   Add(argument) or Insert(argument) - adds new elements to the collection
%   Remove, RemoveAll - removes elements from the collection
% Other methods like Cut, Copy, and Paste may be available depending on the
% kind of collection

% Create a handle to the MCS and remove all existing segments
MCS = ASTG.MainSequence;
MCS.RemoveAll;

% Functions can also be called directly without needing to create a
% separate handle. This will also work:
% ASTG.MainSequence.RemoveAll;

%%% Define the Initial State %%%

% Use the Insert method to add a new Initial State to the MCS. The Insert
% method requires an enumeration as one of its arguments. Enumerations are
% a set of pre-defined options for certain methods and can be found in the
% Help for that given method.
MCS.Insert('eVASegmentTypeInitialState','Inner Orbit','-');

% The Insert command will also return a handle to the segment it creates
propagate = MCS.Insert('eVASegmentTypePropagate','Propagate','-');

%%%
% Configuring Segment properties
%%%

% Create a handle to the Initial State Segment, set it to use Modified
% Keplerian elements and assign new initial values
initstate = MCS.Item('Inner Orbit');
initstate.SetElementType('eVAElementTypeModKeplerian');
initstate.Element.RadiusOfPeriapsis = 6700;
initstate.Element.Eccentricity = 0;
initstate.Element.Inclination = 0;
initstate.Element.RAAN = 0;
initstate.Element.ArgOfPeriapsis = 0;
initstate.Element.TrueAnomaly = 0;

%%% Propagate the Parking Orbit %%%

% Change Propagate segment color, propagator, and stopping condition trip
% value

% Object Model colors must be set with decimal values, but can be easily
% converted from hex values. Here is a table with some example values for use within this script.
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

propagate.Properties.Color = uint32(hex2dec(Cyan));

% Change the propagator
propagate.PropagatorName = 'Earth Point Mass';

%%%
% Configure Stopping Conditions
%%%

% Recall Stopping Conditions are also stored as a collection of items
propagate.StoppingConditions.Item('Duration').Properties.Trip = 7200;

%%% Maneuver into the Transfer Ellipse
%%% Define a Target Sequence

% Insert a Target Sequence with a nested Maneuver segment
ts = MCS.Insert('eVASegmentTypeTargetSequence','Start Transfer','-');
% Sequences (including Target and Backward) have their own collection of
% segments
dv1 = ts.Segments.Insert('eVASegmentTypeManeuver','DV1','-');
dv1.Properties.Color = uint32(hex2dec(Red));

%%% Select Variables

dv1.SetManeuverType('eVAManeuverTypeImpulsive');
% Create a handle to the impulsive properties of the maneuver
impulsive = dv1.Maneuver;
impulsive.SetAttitudeControlType('eVAAttitudeControlThrustVector');
% Create a handle to the Attitude Control - Thrust Vector properties of the
% maneuver and set the appropriate axes
thrustVector = impulsive.AttitudeControl;
thrustVector.ThrustAxesName = 'Satellite VNC(Earth)';


%%%
% Turn on Controls for Search Profiles
%%%

% For the targeter to vary a given segment property, it must be
% enabled as a control parameter. This is done by the
% EnableControlParameter method which is available on each segment inside a
% target sequence. 
dv1.EnableControlParameter('eVAControlManeuverImpulsiveCartesianX');


%%%
% Configure Results
%%%

% Segment Results, which can be used as targeter goals, are also stored in a collection
dv1.Results.Add('Keplerian Elems/Radius of Apoapsis');


%%% Set up the Targeter
%%%
% Configure Targeting
%%%

% Targter Profiles are also stored as a collection
dc = ts.Profiles.Item('Differential Corrector');

% Create a handle to the targeter control and set its properties
xControlParam = dc.ControlParameters.GetControlByPaths('DV1', 'ImpulsiveMnvr.Cartesian.X');
xControlParam.Enable = true;
xControlParam.MaxStep = 0.3;

% Create a handle to the targeter results and set its properties
roaResult = dc.Results.GetResultByPaths('DV1', 'Radius Of Apoapsis');
roaResult.Enable = true;
roaResult.DesiredValue = 42238;
roaResult.Tolerance = 0.1;

% Set final DC and targeter properties and run modes
dc.MaxIterations = 50;
dc.EnableDisplayStatus = true;
dc.Mode = 'eVAProfileModeIterate';
ts.Action = 'eVATargetSeqActionRunActiveProfiles';

%%% Propagate the Transfer Orbit to Apogee
transferEllipse = MCS.Insert('eVASegmentTypePropagate','Transfer Ellipse','-');
transferEllipse.PropagatorName = 'Earth Point Mass';
%Add an Apoapsis Stopping Condition and remove the Duration Stopping
%Condition
transferEllipse.StoppingConditions.Add('Apoapsis');
transferEllipse.StoppingConditions.Remove('Duration');

%%% Maneuver into the Outer Orbit

%%% Define another Target Sequence

% Starting here, we will overwrite some existing variables (ts, dc, etc...)
% with a handle to elements in the new target sequence
ts = MCS.Insert('eVASegmentTypeTargetSequence','Finish Transfer','-');
dv2 = ts.Segments.Insert('eVASegmentTypeManeuver','DV2','-');
dv2.Properties.Color = uint32(hex2dec(Red));

%%% Select Variables
dv2.SetManeuverType('eVAManeuverTypeImpulsive');
impulsive = dv1.Maneuver;
impulsive.SetAttitudeControlType('eVAAttitudeControlThrustVector');
thrustVector = impulsive.AttitudeControl;
thrustVector.ThrustAxesName = 'Satellite VNC(Earth)';
dv2.EnableControlParameter('eVAControlManeuverImpulsiveCartesianX');
dv2.Results.Add('Keplerian Elems/Eccentricity');

%%% Set up the Targeter
dc = ts.Profiles.Item('Differential Corrector');
xControlParam = dc.ControlParameters.GetControlByPaths('DV2', 'ImpulsiveMnvr.Cartesian.X');
xControlParam.Enable = true;
xControlParam.MaxStep = 0.3;
eccResult = dc.Results.GetResultByPaths('DV2', 'Eccentricity');
eccResult.Enable = true;
eccResult.DesiredValue = 0;
eccResult.Tolerance = 0.01;

% Set final DC and targeter properties and run modes
dc.EnableDisplayStatus = true;
dc.Mode = 'eVAProfileModeIterate';
ts.Action = 'eVATargetSeqActionRunActiveProfiles';

%%% Propagate the Outer Orbit
outerOrbit = MCS.Insert('eVASegmentTypePropagate','Outer Orbit','-');
outerOrbit.PropagatorName = 'Earth Point Mass';
outerOrbit.Properties.Color = uint32(hex2dec(Yellow));
outerOrbit.StoppingConditions.Item('Duration').Properties.Trip = 86400;

%%% Running and Analyzing the MCS

% Execute the MCS. This is the equivalent of clicking the "Run" arrow
% button on the MCS toolbar.
ASTG.RunMCS;

% Single Segment Mode. There are times when, due to complex mission
% requirements or even the designers preference, the Astrogator MCS
% graphical interface may not be the most efficient solution. For these
% times, Astrogator also supports executing segments and sequences individually, in any
% order specified by your code. Between running segments you can evaluate
% results and change segment properties. This allows the mission designer
% to model trajectories or algorithms which would be impractical in the
% GUI. Note that if executing a sequence or target sequences, the entire
% sequence will run to completion. Implementing custom targeting algorithms
% is usually best done with a Search Plugin.

% Initialize the MCS for Single Segment Mode
ASTG.BeginRun;

% Execute a single segment. Note that some kind of initial state segment
% (Initial State, Launch, or Follow) should be run first.
initstate.Run;
propagate.Run;
ts1 = MCS.Item('Start Transfer');
ts1.Run;
transferEllipse.Run;
ts.Run;
outerOrbit.Run;

% Ends the MCS rus
ASTG.EndRun;



% Segments have three structures which are useful for examining your
% satellite and orbit parameters:
%   Initial State -  The orbit and spacecraft state at the beginning epoch
%   of the segment
%   Final State   -  The orbit and spacecraft state ate the ending epoch of
%   the segment
%   Results       -  The value of any Calc Object selected by the user,
%   evaluated at the ending epoch of the segment

% Report the TA at the beginning of the Transfer Ellipse segment
transferEllipse.InitialState.SetElementType('eVAElementTypeModKeplerian');
transferEllipse.InitialState.Element.TrueAnomaly
transferEllipse.FinalState.SetElementType('eVAElementTypeModKeplerian');
disp(['Transfer Ellipse True Anomaly: ' num2str(transferEllipse.FinalState.Element.TrueAnomaly) ' deg'] );

% Report the TA at the beginning of the Transfer Ellipse segment, in the
% Sun Inertial frame
transferEllipse_IS_Sun_Inertial = transferEllipse.InitialState.GetInFrameName('CentralBody/Sun Inertial');
transferEllipse_IS_Sun_Inertial.SetElementType('eVAElementTypeModKeplerian');
disp(['Transfer Ellipse True Anomaly (Sun Inertial): ' num2str(transferEllipse_IS_Sun_Inertial.Element.TrueAnomaly) ' deg'] );

% Add and report a Duration Result on the Transfer Ellipse segment
transferEllipse.Results.Add('Time/Duration');
ASTG.RunMCS;
disp(['Transfer Ellipse Duration: ' num2str(transferEllipse.GetResultValue('Duration')) ' sec'] );


%%% Accessing the Component Browser
compCollection = root.CurrentScenario.ComponentDirectory.GetComponents('eComponentAstrogator');
Set CalcObjs = compCollection.GetFolder('Calculation Objects');

% Create a copy of the Cartesian Element X that is with respect to Mars
CartElems = CalcObjs.GetFolder('Cartesian Elems');
x = CartElems.Item('X');
x.CloneObject;
CartElems.Item('X').CloneObject;
% When using the CloneObject method, the new name will simply be the old name with
% a '1' added to the end
Xmars = CartElems.Item('X1');
Xmars.Name = 'X Mars';
Xmars.CoordSystemName = 'CentralBody/Mars Inertial';


