% Lunar Mission using Connect/MATLAB
%
% this is similar to the Lunar Mission tutorial but uses a launch segment
% instead of an initial state.
% 
% author: jens ramrath
% date: 2-24-04
% updated: 8-12-05    fixed to work with the new 6.2 maneuver

% ****************
% ***** INIT *****
% ****************
agiinit                 %Sets Paths
try, stkclose(conid)    %Closes custom connection if there is one
end
try, stkclose           %Closes default connection if there is one
end

clear all               %Clears Workspace
close all               %Dismisses all gui windows if any exist


% OPEN CONNECTIONS
try, conid=stkopen; %opens connection
catch
    errordlg('Problem encountered connecting to STK, make sure that STK is running and accepting connections','Load Warning:'); %returns error if connection can't be opened
    return
end

% **************************
% ***** SCENARIO SETUP *****
% **************************
stkexec(conid,'New / Scenario LunarMissionConnect');
stkexec(conid,'SetTimePeriod Scenario/LunarMissionConnect "1 Jan 1993 00:00:00.00" "1 Jan 1994 00:00:00.00"');
stkexec(conid,'SetEpoch Scenario/LunarMissionConnect "1 Jan 1993 00:00:00.00"');
stkexec(conid,'Animate * SetValues "1 Jan 1993 00:00:00.00" 180 0.025');

% 2D window setup
stkexec(conid,'MapProjection Scenario/LunarMissionConnect Orthographic Format BBR 900000000.0 Sun');
stkexec(conid,'MapProjection Scenario/LunarMissionConnect Orthographic Center 90 -89');
stkexec(conid,'MapDetails Scenario/LunarMissionConnect Background Color white');
% TODO: add sun vector
% 3D window setup
stkexec(conid,'VO Scenario/LunarMissionConnect Grids Space ShowECI On VOWindow 1');
stkexec(conid,'Window3D Scenario/LunarMissionConnect Create 2');
stkexec(conid,'VO Scenario/LunarMissionConnect View FromTo FromToRegName "Central Body" FromToName "Moon" SceneID 2');
stkexec(conid,'VO Scenario/LunarMissionConnect Grids Space ShowECI On VOWindow 2');
%stkexec(conid,'SetCentralBody Scenario/LunarMissionConnect Moon');
% add planets
% TODO: turn on show planet orbits
stkexec(conid,'New / Scenario/LunarMissionConnect/Planet Earth');
stkexec(conid,'New / Scenario/LunarMissionConnect/Planet Moon');
stkexec(conid,'New / Scenario/LunarMissionConnect/Planet Sun');
stkexec(conid,'Define */Planet/Earth CentralBody Earth');
stkexec(conid,'Define */Planet/Moon CentralBody Moon');
stkexec(conid,'Define */Planet/Sun CentralBody Sun');

% *******************
% ***** To Moon *****
% *******************
stkexec(conid,'New / Scenario/LunarMissionConnect/Satellite LunarProbe');
% spacecraft properties
stkexec(conid,'VO Scenario/LunarMissionConnect/Satellite/LunarProbe Pass OrbitTrail All');
stkexec(conid,'VO Scenario/LunarMissionConnect/Satellite/LunarProbe Pass OrbitLead All');

% MCS sequence
stkexec(conid,'ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList Target_Sequence Target_Sequence');
stkexec(conid,'ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.SegmentList Launch Propagate Maneuver Propagate Propagate');
stkexec(conid,'ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence1.SegmentList Maneuver Propagate');
stkexec(conid,'ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.Profiles Differential_Corrector Differential_Corrector');

stkexec(conid,'ASTROGATOR */Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.SegmentList.Maneuver.MnvrType Impulsive');
stkexec(conid,'ASTROGATOR */Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence1.SegmentList.Maneuver.MnvrType Impulsive');

% launch
launchcommand = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.SegmentList.Launch.'];
% TODO: change color of mission segments

stkexec(conid,[launchcommand 'InitialState.Orbit_State.TankTemperature 300 k']);
stkexec(conid,[launchcommand 'InitialState.Orbit_State.TankPressure 1000 psi']);
stkexec(conid,[launchcommand 'InitialState.Orbit_State.SRPArea 40 ft^2']);
stkexec(conid,[launchcommand 'InitialState.Orbit_State.FuelMass 500 kg']);
stkexec(conid,[launchcommand 'InitialState.Orbit_State.FuelDensity 300 kg/m^3']);
stkexec(conid,[launchcommand 'InitialState.Orbit_State.DryMass 1000 lb']);
stkexec(conid,[launchcommand 'InitialState.Orbit_State.DragArea 10 ft^2']);
stkexec(conid,[launchcommand 'InitialState.Orbit_State.Cr 1']);
stkexec(conid,[launchcommand 'InitialState.Orbit_State.Cd 1']);

stkexec(conid,[launchcommand 'CentralBody Earth']);
stkexec(conid,[launchcommand 'Launch.Epoch 0 EpSec']);
stkexec(conid,[launchcommand 'Launch.Geodetic.Latitude 28.6 deg']);
stkexec(conid,[launchcommand 'Launch.Geodetic.Longitude -80.6 deg']);
stkexec(conid,[launchcommand 'Launch.Geodetic.Altitude 0 km']);

stkexec(conid,[launchcommand 'TimeOfFlight 600 sec']);
stkexec(conid,[launchcommand 'Burnout.Geodetic.Latitude 25.1 deg']);
stkexec(conid,[launchcommand 'Burnout.Geodetic.Longitude -51.3 deg']);
stkexec(conid,[launchcommand 'Burnout.Geodetic.Altitude 300 km']);

% propagate
propagatecommand = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.SegmentList.Propagate.'];
stkexec(conid,[propagatecommand 'Propagator Earth_Full_RKF']);
stkexec(conid,[propagatecommand 'StoppingConditions.Duration.TripValue 4 hr']);

% impulsive maneuver
maneuvercommand = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.SegmentList.Maneuver.'];
stkexec(conid,[maneuvercommand 'AttitudeControl Thrust Vector']);
stkexec(conid,[maneuvercommand 'CoordType Cartesian']);
stkexec(conid,[maneuvercommand 'Cartesian.X 3.15 km/sec']);
stkexec(conid,[maneuvercommand 'Cartesian.Y 0.00 km/sec']);
stkexec(conid,[maneuvercommand 'Cartesian.Z 0.00 km/sec']);

% propagate1 to r = 300000 km
propagate1command = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.SegmentList.Propagate1.'];
stkexec(conid,[propagate1command 'Propagator Earth_Full_RKF']);
stkexec(conid,[propagate1command 'StoppingConditions R_Magnitude']);
stkexec(conid,[propagate1command 'StoppingConditions.R_Magnitude.TripValue 300000 km']);

% propagate2
propagate2command = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.SegmentList.Propagate2.'];
stkexec(conid,[propagate2command 'Propagator CisLunar']);
stkexec(conid,[propagate2command 'StoppingConditions Duration Periapsis Altitude']);
stkexec(conid,[propagate2command 'StoppingConditions.Duration.TripValue 10 days']);
stkexec(conid,[propagate2command 'StoppingConditions.Periapsis.RepeatCount 1']);
stkexec(conid,[propagate2command 'StoppingConditions.Periapsis.CalcObjectAttributes.CentralBody Moon']);
stkexec(conid,[propagate2command 'StoppingConditions.Altitude.TripValue 150 km']);
stkexec(conid,[propagate2command 'StoppingConditions.Altitude.CalcObjectAttributes.CentralBody Moon']);

% *************************
% ***** target deltas *****
% *************************
% set up control parameters
targetcommand = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe AddMCSSegmentControl MainSEQUENCE.SegmentList.Target_Sequence.SegmentList.'];
stkexec(conid,[targetcommand 'Launch Launch.Epoch']);
stkexec(conid,[targetcommand 'Propagate StoppingConditions.Duration.TripValue']);
stkexec(conid,[targetcommand 'Maneuver ImpulsiveMnvr.Cartesian.X']);

targetcommand4 = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SetMCSControlValues MainSEQUENCE.SegmentList.Target_Sequence.Profiles.Differential_Corrector '];
stkexec(conid,[targetcommand4 'Launch Launch.Epoch Active true']);
stkexec(conid,[targetcommand4 'Propagate StoppingConditions.Duration.TripValue Active true']);
stkexec(conid,[targetcommand4 'Maneuver ImpulsiveMnvr.Cartesian.X Active true']);

% set up equality constraints
targetcommand2 = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.SegmentList.'];
stkexec(conid,[targetcommand2 'Propagate2.Results Delta_Declination Delta_Right_Asc Epoch BDotR BDotT']);

targetcommand3 = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.Profiles.Differential_Corrector.Results.'];
stkexec(conid,[targetcommand3 'Delta_Declination.Desired 0.0 deg']);
stkexec(conid,[targetcommand3 'Delta_Right_Asc.Desired 0.0 deg']);

targetcommand5 = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SetMCSConstraintValue MainSEQUENCE.SegmentList.Target_Sequence.Profiles.Differential_Corrector '];
stkexec(conid,[targetcommand5 'Propagate2 Delta_Declination Active true']);
stkexec(conid,[targetcommand5 'Propagate2 Delta_Right_Asc Active true']);

% run targeter
stkexec(conid,'ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.Action Run active profiles');
stkexec(conid,'ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.Profiles.Differential_Corrector.Mode Iterate');
%stkexec(conid,'Propagate Scenario/LunarMissionConnect/Satellite/LunarProbe "1 Jan 1993 00:00:00.00" "1 Jan 1994 00:00:00.00"');


% **************************
% ***** target B-plane *****
% **************************
% set up profile
command = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SetMCSControlValues MainSEQUENCE.SegmentList.Target_Sequence.Profiles.Differential_Corrector1 '];
stkexec(conid,[command 'Launch Launch.Epoch Active true']);
stkexec(conid,[command 'Propagate StoppingConditions.Duration.TripValue Active true']);
stkexec(conid,[command 'Maneuver ImpulsiveMnvr.Cartesian.X Active true']);

command = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.Profiles.Differential_Corrector1.Results.'];
stkexec(conid,[command 'BDotR.Desired 8000.0 km']);
stkexec(conid,[command 'BDotT.Desired 0.0 km']);
stkexec(conid,[command 'Epoch.Desired 259200 EpSec']);

command = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SetMCSConstraintValue MainSEQUENCE.SegmentList.Target_Sequence.Profiles.Differential_Corrector1 '];
stkexec(conid,[command 'Propagate2 BDotR Active true']);
stkexec(conid,[command 'Propagate2 BDotT Active true']);
%stkexec(conid,[command 'Propagate2 Epoch Active true']);

% run targeter
stkexec(conid,'ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.Action Run active profiles');
stkexec(conid,'ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence.Profiles.Differential_Corrector1.Mode Iterate');
%stkexec(conid,'Propagate Scenario/LunarMissionConnect/Satellite/LunarProbe "1 Jan 1993 00:00:00.00" "1 Jan 1994 00:00:00.00"');

% ***********************
% ***** circularize *****
% ***********************
% impulsive maneuver
maneuvercommand = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence1.SegmentList.Maneuver.'];
stkexec(conid,[maneuvercommand 'AttitudeControl Thrust Vector']);
stkexec(conid,[maneuvercommand 'CoordType Cartesian']);
stkexec(conid,[maneuvercommand 'Cartesian.X 0.00 km/sec']);
stkexec(conid,[maneuvercommand 'Cartesian.Y 0.00 km/sec']);
stkexec(conid,[maneuvercommand 'Cartesian.Z 0.00 km/sec']);
% set up control parameters
command = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe AddMCSSegmentControl MainSEQUENCE.SegmentList.Target_Sequence1.SegmentList.'];
stkexec(conid,[command 'Maneuver ImpulsiveMnvr.Cartesian.X']);
stkexec(conid,[command 'Maneuver ImpulsiveMnvr.Cartesian.Y']);
% set active
command = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SetMCSControlValues MainSEQUENCE.SegmentList.Target_Sequence1.Profiles.Differential_Corrector '];
stkexec(conid,[command 'Maneuver ImpulsiveMnvr.Cartesian.X Active true']);
stkexec(conid,[command 'Maneuver ImpulsiveMnvr.Cartesian.Y Active true']);

% propagate
command = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence1.SegmentList.Propagate.'];
stkexec(conid,[command 'Propagator Lunar']);
stkexec(conid,[command 'StoppingConditions.Duration.TripValue 3 days']);

% desired
command = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence1.SegmentList.'];
stkexec(conid,[command 'Propagate.Results Eccentricity']);
stkexec(conid,'ASTROGATOR */Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence1.SegmentList.Propagate.Results.Eccentricity.CentralBody Moon');

command = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence1.Profiles.Differential_Corrector.Results.'];
stkexec(conid,[command 'Eccentricity.Desired 0.0']);

command = ['ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SetMCSConstraintValue MainSEQUENCE.SegmentList.Target_Sequence1.Profiles.Differential_Corrector '];
stkexec(conid,[command 'Propagate Eccentricity Active true']);

% set up targeter
stkexec(conid,'ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence1.Action Run active profiles');
stkexec(conid,'ASTROGATOR Scenario/LunarMissionConnect/Satellite/LunarProbe SETVALUE MainSEQUENCE.SegmentList.Target_Sequence1.Profiles.Differential_Corrector.Mode Iterate');

% ***************
% ***** run *****
% ***************
stkexec(conid,'Propagate Scenario/LunarMissionConnect/Satellite/LunarProbe "1 Jan 1993 00:00:00.00" "1 Jan 1994 00:00:00.00"');




%a = stkexec(conid,'ASTROGATOR_RM Scenario/LunarMissionConnect/Satellite/LunarProbe GetMCSControlValue MainSEQUENCE.SegmentList.Target_Sequence.Profiles.Differential_Corrector Impulsive_Maneuver Cartesian.X LastUpdate')
%a = stkexec(conid,'ASTROGATOR_RM Scenario/LunarMissionConnect/Satellite/LunarProbe GetValue MainSEQUENCE.SegmentList.Target_Sequence')
%a = stkexec(conid,'ASTROGATOR_RM Scenario/LunarMissionConnect/Satellite/LunarProbe GetValue MainSEQUENCE.SegmentList.Target_Sequence.Profiles.Differential_Corrector.Status')