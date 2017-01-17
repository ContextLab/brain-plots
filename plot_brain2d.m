function[hs] = plot_brain2d(img, nrow, ncol, dim, c, hs)
%PLOT_BRAIN2D  Plot slices of a brain image (3d matrix)
%
% Usage: plot_brain2d_alt(x,[nrow],[ncol],[dim],[clim],[hs])
%
% INPUTS:
%      x: a 3d matrix (tensor) of voxel activations
%
%   nrow: an optional argument specifying the number of rows of brain
%         images (default: 4)
% 
%   ncol: an optional argument specifying the number of columns of brain
%         images (default: 4)
%
%    dim: optional argument specifying the plane along which the 3d brain
%         image will be sliced. default: 2 (coronal slices).  options: 1
%         (sagittal), 2 (coronal), 3 (horizontal).
%
%   clim: optional argument specifying upper and lower bounds of the color
%         axis.  minimum value is mapped to blue; upper is mapped to red.
%         user can also input a matrix or brain image here (e.g. to use as
%         a reference for the to-be-plotted image.)  if so, the lower 10%
%         and upper 90% activation values of the given image are used as
%         the color axis bounds.
%
%     hs: optional argument containing a vector of handles to the subplots.
%         this is useful for saving time when plot_brain2d is called
%         repeatedly with the same subplot requirements.
%
% OUTPUTS:
%     hs: a vector of handles to the subplots
%
% SEE ALSO: PLOT_BRAIN2D, PLOT_BRAIN3D, SANEPCOLOR, SLICES,
%           GETTIGHTSUBPLOTHANDLES, IMCONTOUR, SUBPLOT, PCOLOR,
%           IMAGESC, LINSPECER
%
%  AUTHOR: Jeremy R. Manning
% CONTACT: manning3@princeton.edu

% CHANGELOG:
% 2-22-13  jrm  wrote it.
% 11-2-13  jrm  rename to plot_brain2d
% 12-12-13 jrm  removed in_roi option.
% 4-14-14  jrm  allow user to pass in vector of subplot handles
% 7-21-14  jrm  always convert image to a double prior to plotting
% 8-6-14   jrm  changed default to coronal slices, changed how planes are
%               referenced to match nifti defaults
% 5-1-15   jrm  minor cleanup

warning('off', 'MATLAB:contour:ConstantData');
warning('off', 'MATLAB:hg:patch:PatchFaceVertexCDataLengthMustEqualVerticesLength');

if ~exist('nrow','var') || isempty(nrow)
    nrow = 4;
end
if ~exist('ncol','var') || isempty(ncol)
    ncol = 4;
end
if ~exist('dim','var') || isempty(dim)
    dim = 2;
end

img = double(img);
select_img = img;
nslices = min(nrow*ncol,size(img,dim));
brain_slices = slices(img,dim);
select_slices = slices(select_img,dim);

slice_edges = linspace(1,size(img,dim),nslices+1);
which_slices = mean([slice_edges(1:end-1) ; slice_edges(2:end)],1);
which_slices = unique(round(which_slices));

if ~exist('hs', 'var') || length(hs) ~= nrow*ncol
    clf;
    hs = getTightSubplotHandles(0.01,0.01,0.01,nrow,ncol);
end

if ~exist('c','var') || isempty(c)
    c = [prctile(img(:),10) prctile(img(:),90)];
elseif ~((min(size(c)) == 1) && (max(size(c)) == 2)) %c is a set of images...
    c = prctile(flatten(c), [10 90]);
end
for i = 1:length(hs)
    axes(hs(i)); %#ok<LAXES>
    if i <= length(which_slices)
        ind = length(which_slices) - i + 1;
        plot_helper(flipud(squeeze(brain_slices{which_slices(ind)})'),flipud(squeeze(select_slices{which_slices(ind)})'),c);        
    else        
        axis off;
    end
end

function[] = plot_helper(img,select_img,c)
hold on;
sanePColor(img(end:-1:1, :)); 

try %#ok<TRYNC>
    caxis(c); 
end
colormap linspecer;
se = strel('arbitrary',ones([1 1]));
[~,h] = imcontour(imdilate(~isnan(select_img(end:-1:1, :)),se),1);
set(h,'LineColor','k','LineWidth',2);
hold off;
axis tight;
axis square;
axis off;

function[f] = flatten(x)
if iscell(x)
    f = zeros(1, sum(cellfun(@numel, x)));
    start = 1;
    for i = 1:length(x)
        f(start:(start + numel(x{i})-1)) = x{i}(:)';
        start = start + numel(x{i});
    end
else
    f = x(:)';
end
