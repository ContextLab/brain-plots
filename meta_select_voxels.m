function[meta] = meta_select_voxels(full, Vs)
%remove voxels not in Vs

meta = full;
if islogical(Vs)
    meta.nvoxels = sum(Vs);
else
    meta.nvoxels = length(Vs);
end

try %#ok<TRYNC>
    meta = rmfield(meta, 'dimx');
    meta = rmfield(meta, 'dimy');
    meta = rmfield(meta, 'dimz');
end

meta.colToCoord = full.colToCoord(Vs,:);
meta.coordToCol = zeros(size(full.coordToCol));

for i = 1:length(Vs)
    meta.coordToCol(full.coordToCol == Vs(i)) = i;
end
