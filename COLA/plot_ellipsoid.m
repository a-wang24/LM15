function gh = plot_ellipsoid(mean, C, sdWidth, resolution, axh )
%% plot_ellipsoid plots 2-d ellipses and 3-d ellipsoids
%
%   gh = plot_ellipsoid(mean,C) plots distribution of mean and covariance
%   C. Plotted as ellipse or ellipsoid depending on dimensions of mean and
%   C. gh is graphics handle to plotted surface.
%   
%   plot_ellipsoid(mean,C,sdWidth) uses sdWidth as standard deviation along
%   axes. default is sdWidth = 1
%
%   plot_ellipsoid(mean,C,sdWidth,resolution) allows you to set desired
%   resolution. default is resolution = 50 for ellipses and 20 for
%   ellipsoids. Surfaces are generated on a (resolution x resolution) mesh
%   using sphere function.
%
%   plot_ellipsoid(mean,C,sdWidth,resolution,axh) adds plot to the axes
%   specified by axes handle axh.

%% checks for specific cases and inputs and uses later functions to produce plots

if ~exist('sdWidth', 'var')
    sdWidth = 1;
end

if ~exist('resolution', 'var')
    resolution = [];
end

if ~exist('axh', 'var')
    axh = gca;
end

if numel(mean) ~= length(mean), 
    error('mean must be a vector'); 
end

if ~( all(numel(mean) == size(C)) )
    error('Dimensionality of mean and C must match');
end

if ~(isscalar(axh) && ishandle(axh) && strcmp(get(axh,'type'), 'axes'))
    error('Invalid axes handle');
end

set(axh, 'nextplot', 'add');

switch numel(mean)
   case 2, gh=surf2d(mean(:),C,sdWidth,resolution,axh);
   case 3, gh=surf3d(mean(:),C,sdWidth,resolution,axh);
   otherwise
      error('Unsupported dimensionality');
end

if nargout==0,
    clear gh;
end

%% plotting ellipse 2D function
function gh = surf2d(means, C, SD, npts, axh)
if isempty(npts)
    npts = 50;
end
tt = linspace(0,2*pi,npts)';
x = cos(tt);
y = sin(tt);
circle = [x(:) y(:)]';
[v,d] = eig(C);
d = SD * sqrt(d);
ellipse = (v*d*circle) + repmat(means,1,size(circle,2));
gh = plot(ellipse(1,:),ellipse(2,:),'-','parent',axh);

%% plotting ellipsoid 3D function
function gh = surf3d(means, C, SD, npts, axh)
if isempty(npts)
    npts = 20;
end
[x,y,z] = sphere(npts);
sphereP = [x(:) y(:) z(:)]';
[v,d] = eig(C);
if any(d(:) < 0)
    fprintf('warning: negative eigenvalues\n');
    d = max(d,0);
end
d = SD * sqrt(d);
ellipsoid = (v*d*sphereP) + repmat(means,1,size(sphereP,2));
xP = reshape(ellipsoid(1,:), size(x));
yP = reshape(ellipsoid(2,:), size(y));
zP = reshape(ellipsoid(3,:), size(z));
gh = surf(axh,xP,yP,zP);
%% acknowledgement to Gautam Vallabha of mathworks

