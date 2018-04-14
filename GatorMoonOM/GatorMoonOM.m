clc;clear all;
%Create new COM object
uiapp = actxserver('STK9.application');
%Grab running instance of STK
%uiapp = actxGetRunningServer('STK9.application');
root = uiapp.Personality2;
%Create new Scenario
root.NewScenario('LunarMission');

%Grab scenario object
scen = root.CurrentScenario;
%scen.SetTimePeriod('1 Jul 2008 12:00:00.00','2 Jul 2008 12:00:00.00');
%scen.Animation.StartTime = '1 Jul 2008 14:00:00.00';
scen.Animation.AnimStepValue = 60;

%Create/Grab Satellite Object
sat = root.CurrentScenario.children.New('eSatellite','LunarOrbiter');
sat.SetPropagatorType('ePropagatorAstrogator');

%Create/Grab planets and modify graphics
moon = root.CurrentScenario.children.New('ePlanet','Moon');
moon.PositionSourceData.CentralBody = 'Moon';
moon.graphics.Inherit = 0;
moon.graphics.SubPlanetPointVisible = 0;
moon.graphics.SubPlanetLabelVisible = 0;
moon.graphics.OrbitVisible = 1;
moon.graphics.PositionLabelVisible = 0;

%Get the Astrogator Driver
driver = sat.Propagator;
main = driver.MainSequence;
auto = driver.AutoSequence;

% Remove all default sequences from the MCS
driver.MainSequence.RemoveAll

% Ask user to define mission start date:
customOrDefault = input('Enter 1 to Specify Mission Start Date or 2 for Scenario Default: ');
if customOrDefault == 1
    missionStartDate = input('Enter Mission Start Date (UTCG): ');
elseif customOrDefault == 2
    missionStartDate = scen.StartTime;
else
    fprintf('Please Enter a valid selection index\n')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%                                                %%%%%%%%%%%%%
%%%%%%%%%%%%%%    Configure 'Target Moon' target sequence     %%%%%%%%%%%%%
%%%%%%%%%%%%%%                                                %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Add 'Target' segment
TargetMoon = main.Insert('eVASegmentTypeTargetSequence','Target Moon','-');

%Add 'Launch' segment
TargetLaunch = TargetMoon.Segments.Insert('eVASegmentTypeLaunch','Launch','-');
TargetLaunch.Properties.Color = 6;
TargetLaunch.Epoch = missionStartDate;
TargetLaunch.EnableControlParameter('eVAControlLaunchEpoch');

%Add 'Propagate' segment 
TargetCoast = TargetMoon.Segments.Insert('eVASegmentTypePropagate','Coast','-');
TargetCoast.Properties.Color = 10;
stopCon = TargetCoast.StoppingConditions;
duration = stopCon.Item('Duration');
duration.properties.Trip = 3000;
duration.EnableControlParameter('eVAControlStoppingConditionTripValue');

%Add 'Maneuver' segment
TargetManeuver = TargetMoon.Segments.Insert('eVASegmentTypeManeuver','TLI','-');
TargetManeuver.Properties.Color = 21;
TargetManeuver.Maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');
ManeuverAttitudeControl = TargetManeuver.Maneuver.AttitudeControl;
ManeuverAttitudeControl.DeltaVVector.AssignCartesian(3.1415,0,0);
TargetManeuver.EnableControlParameter('eVAControlManeuverImpulsiveCartesianX');

%Add 'Propagate' segment
TargetProp2SOI = TargetMoon.Segments.Insert('eVASegmentTypePropagate','Prop to SOI','-');
TargetProp2SOI.PropagatorName = 'Cislunar';
newStopCon = TargetProp2SOI.StoppingConditions.Add('R Magnitude');
newStopCon.Properties.Trip = 350000;
TargetProp2SOI.StoppingConditions.Remove('Duration');

%Add 'Return' segment
TargetReturn = TargetMoon.Segments.Insert('eVASegmentTypeReturn','Lunar Return','-');

%Add 'Propagate' segment
TargetProp2Moon =  TargetMoon.Segments.Insert('eVASegmentTypePropagate','Prop to Moon','-');
TargetProp2Moon.Properties.Color = 21;
TargetProp2Moon.PropagatorName = 'Moon HPOP Default v9';
periStop = TargetProp2Moon.StoppingConditions.Add('Periapsis');
periStop.Properties.CentralBodyName = 'Moon';
altStop.Properties.CentralBodyName = 'Moon';
altStop.Properties.Trip = 10;
TargetProp2Moon.StoppingConditions.Remove('Duration');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%       Add Targeter Profiles       %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TargetMoon.Profiles.Remove('Differential Corrector');

retOn = TargetMoon.Profiles.Add('Change Return Segment');
retOn.Name = 'Return On';
retOn.State = 0;

diffCorr = TargetMoon.Profiles.Add('Differential Corrector');
diffCorr.Name = 'RA Dec';

retOff = TargetMoon.Profiles.Add('Change Return Segment');
retOff.Name = 'Return Off';
retOff.State = 1;

Bplane = TargetMoon.Profiles.Add('Differential Corrector');
Bplane.Name = 'Bplane';

AltInc = TargetMoon.Profiles.Add('Differential Corrector');
AltInc.Name = 'Alt Inc';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Add Segment Results       %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TargetProp2SOI.Results.Add('MultiBody/Delta Declination');

TargetProp2SOI.Results.Add('MultiBody/Delta Right Asc');

bdt = TargetProp2Moon.Results.Add('MultiBody/BdotT');
bdt.RefVectorName = 'CentralBody/Moon NorthPole';

bdr = TargetProp2Moon.Results.Add('MultiBody/BdotR');
bdr.RefVectorName = 'CentralBody/Moon NorthPole';

DAS = TargetProp2Moon.results.Add('Segments/Difference Across Segments');
DAS.Name = 'TOF';
DAS.CalcObjectName = 'Epoch';
DAS.OtherSegmentName = 'Target Moon.TLI';

lunarAlt = TargetProp2Moon.Results.Add('Geodetic/Altitude');
lunarAlt.CentralBodyName = 'Moon';

lunarInc = TargetProp2Moon.Results.Add('Keplerian Elems/Inclination');
lunarInc.CoordSystemName = 'CentralBody/Moon TOD';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%                                     %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%  Set up 'RA Dec' targeting profile  %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%                                     %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

epochControl = diffCorr.ControlParameters.Item(0);
epochControl.Enable = 1;
epochControl.Perturbation = 1000;
epochControl.MaxStep = 10000;

tripControl = diffCorr.ControlParameters.Item(1);
tripControl.Enable = 1;
tripControl.Perturbation = 10;
tripControl.MaxStep = 100;

deltaDEC = diffCorr.Results.Item(0);
deltaDEC.Enable = 1;

deltaRA = diffCorr.Results.Item(1);
deltaRA.Enable = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%                                     %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%  Set up 'Bplane' targeting profile  %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%                                     %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%Active the Controls
epochControlBplane = Bplane.ControlParameters.Item(0);
epochControlBplane.Enable = 1;
epochControlBplane.Perturbation = 100;
epochControlBplane.MaxStep = 1000;

tripControlBplane = Bplane.ControlParameters.Item(1);
tripControlBplane.Enable = 1;
tripControlBplane.Perturbation = 1;
tripControlBplane.MaxStep = 100;

cartXControl = Bplane.ControlParameters.Item(2);
cartXControl.Enable = 1;
cartXControl.Perturbation = 0.001;
cartXControl.MaxStep = 0.01;

%%%Active the constraints
constrainBDR = Bplane.Results.Item(3);
constrainBDR.Enable = 1;
constrainBDR.DesiredValue = -8000;
constrainBDR.Tolerance = 10;

constrainBDT = Bplane.Results.Item(4);
constrainBDT.Enable = 1;
constrainBDT.DesiredValue = 0;
constrainBDT.Tolerance = 10;

constrainBDT = Bplane.Results.Item(6);
constrainBDT.Enable = 1;
constrainBDT.DesiredValue = 432000;
constrainBDT.Tolerance = 3600;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%                                      %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%  Set up 'Alt Inc' targeting profile  %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%                                      %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%Active the Controls
epochAltInc = AltInc.ControlParameters.Item(0);
epochAltInc.Enable = 1;
epochAltInc.Perturbation = 10;
epochAltInc.MaxStep = 100;

coastAltInc = AltInc.ControlParameters.Item(1);
coastAltInc.Enable = 1;
coastAltInc.Perturbation = 1;
coastAltInc.MaxStep = 10;

cartXAltInc = AltInc.ControlParameters.Item(2);
cartXAltInc.Enable = 1;
cartXAltInc.Perturbation = 0.0001;
cartXAltInc.MaxStep = 0.01;

%%%Active the Constraints
constrainLunarInc = AltInc.Results.Item(5);
constrainLunarInc.DesiredValue = 90;
constrainLunarInc.Enable = 1;

constrainLunarAlt = AltInc.Results.Item(2);
constrainLunarAlt.DesiredValue = 250.0;
constrainLunarAlt.Enable = 1;

constrainTOFaltInc = AltInc.Results.Item(6);
constrainTOFaltInc.DesiredValue = 5*24*3600;
constrainTOFaltInc.Tolerance = 3600;
constrainTOFaltInc.Enable = 1;

AltInc.MaxIterations = 50;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%                                        %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%          Configure B-Plane             %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%                                        %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Create BPlane Template:
sat.VO.BPlanes.Templates.Add.Name = 'Lunar_BPlane';
bplaneVO = sat.VO.BPlanes.Templates.Item(0);
bplaneVO.CentralBody = 'Moon';
bplaneVO.GridSpacing = 1000;
bplaneVO.ReferenceVector = 'CentralBody/Moon NorthPole Vector';


%Display BPlane in 3D window:
bplaneVOdisp = sat.VO.BPlanes.Instances.Add('Lunar_BPlane');
bplaneVOdisp.IsVisible = 1;

TargetProp2Moon.Properties.UpdateAnimationTimeAfterRun = 1;
TargetProp2Moon.Properties.BPlanes.Add('LunarOrbiter_1');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%                                                  %%%%%%%%%%%%
%%%%%%%%%%%%%    Configure 'Get into Orbit' target sequence    %%%%%%%%%%%%
%%%%%%%%%%%%%                                                  %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Add 'Target' sequence
TargetFinal = main.Insert('eVASegmentTypeTargetSequence','Get into Orbit','-');

%Add 'Maneuver' segment
LOI = TargetFinal.Segments.Insert('eVASegmentTypeManeuver','LOI','-');
LOI.Maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');
LOI.Maneuver.AttitudeControl.ThrustAxesName = 'Satellite/LunarOrbiter VNC(Moon)';
LOI.EnableControlParameter('eVAControlManeuverImpulsiveCartesianX');

%Add Segment Results
constraintEcc = LOI.Results.Add('Keplerian Elems/Eccentricity');
constraintEcc.CentralBodyName = 'Moon';

%Add Target Profile
targetEcc = TargetFinal.Profiles.Item('Differential Corrector');
targetEcc.Name = 'Target Ecc';

%Add Control Parameters
controlLOIx = targetEcc.ControlParameters.Item(0);
controlLOIx.Enable = 1;

constraintLOIecc = targetEcc.Results.Item(0);
constraintLOIecc.DesiredValue = 0.0;
constraintLOIecc.Tolerance = 0.01;
constraintLOIecc.Enable = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Insert new 'Propagate' segment in Main Sequence
PropTwice = main.Insert('eVASegmentTypePropagate','Prop Final Orbit','-');
PropTwice.Properties.Color = 2;
PropTwice.PropagatorName = 'Moon HPOP Default v9';

%Set to 'Run active profiles'
TargetMoon.Action = 1;
TargetFinal.Action = 1;

driver.RunMCS;

%Set to 'Run Nominal Sequence'
% TargetMoon.ApplyProfiles
% TargetFinal.ApplyProfiles
% TargetMoon.Action = 0;
% TargetFinal.Action = 0;

driver.RunMCS;

% Set the scenario time period to line up with the satellite's available
% times:
availableTimesDP = sat.DataProviders.Item('Available Times').Exec(scen.StartTime, scen.StartTime);
satStartTimeUTCG = cell2mat(availableTimesDP.DataSets.GetDataSetByName('Start Time').GetValues);
satStopTimeUTCG = cell2mat(availableTimesDP.DataSets.GetDataSetByName('Stop Time').GetValues);

scen.SetTimePeriod(satStartTimeUTCG,satStopTimeUTCG);
root.ExecuteCommand('Animate * Reset');