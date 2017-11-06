function [regsInfo] = setVISCERALregsParams(batchID,VISCERALdir,fov,organs,outDir,nAtlases)

% batchID = 'LiverTest'
%  VISCERALdir = VISCERALdir (Training data)
%  fov = 'tr' (fomat of the volume)
% organs = {'all'}
% outDir = outputDir '/' batchID
% nAtlases = 20

% Set modality
if strcmp(fov,'tr'),
    modality = 'CTce_ThAb';
elseif strcmp(fov,'wb'),
    modality = 'CT_wb';
else
    disp('ERROR: wrong field-of-view (fov) input')
    return;
end;

% Define organs to be segmented
if strcmp(organs{:},'all')
    organs = {'58' '1302' '1326' '237' '29662' ...
        '187' '30324' '170' '40357' '32248' ...
        '1247' '480' '2473' '7578' '29663' ...
        '86' '30325' '40358' '32249' '29193'};       
end;

% Temporary trash folder
tempDir = [outDir '/temp'];
system(['mkdir ' tempDir]); 

% Downsampled volumes = speed up segmentation process
% Volumes are downsampled to speed up segmentation
downsampled = 1;
scalingFactor = 0.5;

if downsampled,
    prefix = 'Imdownsample_CutResult_sizeAdjust_';
else
    prefix = '';
end;

% Data set
trainAtlasDir = [VISCERALdir prefix 'Anat2_' 'Volumes' '/'];
trainSegmentsDir = [VISCERALdir prefix 'Anat2_' 'Segmentations' '/'];

% Store paths and information from the atlases of the VISCERAL Anatomy data set
[numAtlases,atlases,refNii] = getAtlasesSegments(modality,nAtlases,trainAtlasDir,trainSegmentsDir,prefix);
% example ot the Output
% atlases.IDs = {10000110, ....}
% atlases.paths =  {'VISCERALdir/dS_Anat2_Volumes/10000110_1_CTce_ThAb.nii.gz', ......}

% Registration parameter files paths
paramDir = 'regParameters/';
p_globAff = [paramDir 'p_' modality '_globAff.txt']; % Globak affine registration
p_locAff = [paramDir 'p_' modality '_locAff.txt']; % Local affine registration
p_bSp = [paramDir 'p_' modality '_bSp.txt']; % Local b-Spline registration

bSpline = 1; % Use 1 for adding B-spline registrations
bSp_thr = 3; % Minimum number of atlases included in the b-spline mask
bSp_a = 4; % Number of atlases selected for b-spline registration
final_thr = 1;

smallROI = 15; % voxels in kernel for dilating small ROI mask
largeROI = 25; % voxels in kernel for dilating large ROI masks 

%% Build VISCERAL struct
regsInfo.batchID = batchID;
regsInfo.organs = organs;
regsInfo.outDir = outDir;

regsInfo.modality = modality;

regsInfo.tempDir = tempDir; 

regsInfo.scaled = downsampled;
regsInfo.scalingFactor = scalingFactor;

regsInfo.trainAtlasDir = trainAtlasDir;
regsInfo.trainSegmentsDir = trainSegmentsDir;
%trainSegmentsDir = 'VISCERALdir/dS_Anat2_Segmentations/'

regsInfo.noAtlases = numAtlases;
regsInfo.trainAtlases = atlases;
regsInfo.ref_VISCERALnii = refNii;

regsInfo.p_globAff = p_globAff;
regsInfo.p_locAff = p_locAff;
regsInfo.p_bSp = p_bSp;

regsInfo.bSp = bSpline;
regsInfo.bSp_thr = bSp_thr;
regsInfo.bSp_atlases = bSp_a;
regsInfo.final_thr = final_thr;

regsInfo.largeROI = largeROI;
regsInfo.smallROI = smallROI;

