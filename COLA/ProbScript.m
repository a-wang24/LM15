% Alan Wang
% Produces probability statistics on collision using parseCsmFunc

close all;
clear all;

filename = input('Please enter the directory or name of the file to be read: ', 's');

% use parseCsm function to extract data
try
    csm = parseCsmFunc(filename);
catch
    warning('The file could not be opened. Please input a correct directory');
end

%% create handles for position and velocity covariance and populates position and velocity covariance matrices
assetCov = csm.asset.Covariance;
conjCov = csm.conjuncting.Covariance;

assPosCov = zeros(3,3);
assVelCov = zeros(3,3);
conjPosCov = zeros(3,3);
conjVelCov = zeros(3,3);

for i = 1:3
    for j = 1:3
        assPosCov(i,j) = assetCov(i,j);
        conjPosCov(i,j) = conjCov(i,j);
        assVelCov(i,j) = assetCov(i,j+3);
        conjVelCov(i,j) = conjCov(i,j+3);
    end
end

%% Establishes vectors for different coordinate frames as well as angles between them
% Develops transformation matrices necessary to transform covariance
% matrices
vp = csm.asset.Velocity;
vs = csm.conjuncting.Velocity;
posp = csm.asset.Position;
poss = csm.conjuncting.Position;
unitVelp = (vp/norm(vp));
unitVels = (vs/norm(vs));
% x y z define ECER frame
x = [ 1 0 0 ];
y = [ 0 1 0 ];
z = [ 0 0 1 ];

% U V W correspond to radial, in track, cross track respectively
unitUp = posp/norm(posp);
unitUs = poss/norm(poss);
% xypositions denote projection of position vector onto xy plane
xyposp = [posp(1),posp(2),0];
xyposs = [poss(1),poss(2),0];
% cross track direction is crossproduct of radial vector with velocity
% vector
unitWp = cross(unitUp,unitVelp);
unitWs = cross(unitUs,unitVels);
% in track direction defined as cross between cross track and radial
% vectors
unitVp = cross(unitWp,unitUp);
unitVs = cross(unitWs,unitUs);

alphap = acos(dot(unitWp,z));
alphas = acos(dot(unitWs,z));
magxyp = norm(xyposp);
magxys = norm(xyposs);
betap = acos(dot(xyposp,x)/magxyp);
betas = acos(dot(xyposs,x)/magxys);

unitN = cross(vp,vs);

unitXp = cross(unitVelp,unitN);
unitXs = cross(unitVels,unitN);

T1 = [cos(alphas),0,sin(alphas);0,1,0;-sin(alphas),0,cos(alphas)];
T2 = [cos(betas),sin(betas),0;-sin(betas),cos(betas),0;0,0,1];
T3 = [cos(alphap),0,sin(alphap);0,1,0;-sin(alphap),0,cos(alphap)];
T4 = [cos(betap),sin(betap),0;-sin(betap),cos(betap),0;0,0,1];

%% Transforms covariance matrices to same coordinate frame
% develop angles between vectors for cosine matrix
% pull velocity data from csm structure for unit vectors
% denote 'subscript' p as primary object or asset and s as secondary for
% conjuncting object
conjPosCovECR = T2*T1*conjPosCov*T1'*T2';
conjVelCovECR = T2*T1*conjVelCov*T1'*T2';
conjPosCovAss = T4*T3*conjPosCovECR*T3'*T4';
conjVelCovAss = T4*T3*conjVelCovECR*T3'*T4';

comPosCov = assPosCov+conjPosCovAss;
comVelCov = assVelCov+conjVelCovAss;

%% Create geometry for Encounter Plane Region
% Develop transformations and equations necessary to plot projections onto
% the encounter plane (normal to relative velocity vector)
% to Describe new encounter frame we will define XYZ coordinate frame where
% Y is parallel with relative velocity vector and resulting XZ plane is the
% encounter plane
relPosition = csm.details.Relative_Position;
relVelocity = csm.details.Relative_Velocity;
unitRelPos = relPosition/norm(relPosition);
unitRelVelo = relVelocity/norm(relVelocity);

% to begin transformations, first rotate about W axis and then U axis to
% align the V axis with Y, resulting UW components of matrix is UW plane
% ellipse
relVeloUV = [relVelocity(1) relVelocity(2) 0];
unitRelVeloUV = relVeloUV/norm(relVeloUV);
phi = acos(dot(unitRelVeloUV,[0 1 0]));
T5 = [cos(phi) sin(phi) 0;-sin(phi) cos(phi) 0;0 0 1];
newV = T5*[0 1 0]';
theta = acos(dot(unitRelVelo,newV));
T6 = [1 0 0;0 cos(theta) sin(theta);0 -sin(theta) cos(theta)];

newU = T6*T5*[1 0 0]';
newW = T6*T5*[0 0 1]';

assPosCovEnPl = T6*T5*assPosCov*T5'*T6';
assPosCovEnPl2D = [assPosCovEnPl(1,1) assPosCovEnPl(1,3);assPosCovEnPl(3,1) assPosCovEnPl(3,3)];
conjPosCovEnPl = T6*T5*conjPosCovAss*T5'*T6';
conjPosCovEnPl2D = [conjPosCovEnPl(1,1) conjPosCovEnPl(1,3);conjPosCovEnPl(3,1) conjPosCovEnPl(3,3)];
relPositionEnPl = T6*T5*relPosition';
comPosCovEnPl = T6*T5*comPosCov*T5'*T6';
comPosCovEnPl2D = [comPosCovEnPl(1,1) comPosCovEnPl(1,3);comPosCovEnPl(3,1) comPosCovEnPl(3,3)];

% Now match the X axis with the longest axis of uncertainty for the asset
% in the encounter plane
% We will compute the eigenvectors and eigenvalues of the ellipse in the
% encounter plane to do this and then perform coordinate transform to align
% the axes and plot
[v,d] = eig(assPosCovEnPl2D);
[m,i] = max(d(:));
[r,c] = ind2sub(size(d),i);
omega1 = acos(dot(v(:,c),[1 0]));
omega2 = acos(dot(v(:,c)*-1,[1 0]));
omega = min(omega1,omega2);
T7 = [cos(omega) sin(omega);-sin(omega) cos(omega)];
T8 = [cosd(90) sind(90);-sind(90) cosd(90)];
relPositionEnPl2D = [relPositionEnPl(1) relPositionEnPl(3)];
relPositionEnPl2DRot = T8*T7*relPositionEnPl2D';
conjPosCovEnPl2DRot = T8*T7*conjPosCovEnPl2D*T7'*T8';
d1 = T8*d*T8';
newU2D = [newU(1) newU(3)];
newW2D = [newW(1) newW(3)];
newV2D = [newV(1) newV(3)];
newU1 = T8*T7*newU2D';
newW1 = T8*T7*newW2D';
newV1 = T8*T7*newV2D';

%% begin probability calcs

% pull from csm the size of objects, gives a range
% [large, medium small] --> [>1m^2, .1-1m^2,<.1m^2]
% this corresponds to radiuses [>.564m, .178-.564, <.178]
% for the sake of the exercise, assume radiuses on large side of bounds
assSize = csm.asset.Size;
conjSize = csm.conjuncting.Size;
if strcmp(assSize, 'LARGE')
    assRadius = 5;
elseif strcmp(assSize, 'MEDIUM')
    assRadius = .564;
elseif strcmp(assSize, 'SMALL')
    assRadius = .178;
end
if strcmp(conjSize, 'LARGE')
    conjRadius = 5;
elseif strcmp(conjSize, 'MEDIUM')
    conjRadius = .564;
elseif strcmp(conjSize, 'SMALL')
    conjRadius = .178;
end

% sets up limits and area of integration for function integral2
% computes probability using assets covariance
areaRadius = assRadius + conjRadius;
zmax = @(x) sqrt(areaRadius^2 - x.^2);
zmin = @(x) -sqrt(areaRadius^2 - x.^2);
xmax = areaRadius;
xmin = -areaRadius;
fun = @(x,z) exp(-.5.*((x./d(1)).^2 + (z./d(4)).^2));
P = integral2(fun,xmin,xmax,zmin,zmax);
PfinalAss = P * (1/(2*d(1)*d(4)));

% computes probability using combined covariance
% all limits are the same just variances are different
[ve,d2] = eig(comPosCovEnPl2D);
fun1 = @(x,z) exp(-.5.*((x./d2(1)).^2 + (z./d2(4)).^2));
P = integral2(fun1,xmin,xmax,zmin,zmax);
PfinalCom = P * (1/(2*d2(1)*d2(4)));









