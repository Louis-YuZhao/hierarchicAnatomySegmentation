%
% Hierarchic atlas-based organ segmentation
%
close all; clear all; clc;

%% Settings
batchID = 'LiverTest';
fileList = ['/media/louis/Volume/ResearchData/oscarVesceralOriginal/ds_Anat_Volumes/FileList.txt']; % Test Data

VISCERALdir = '/media/louis/Volume/ResearchData/oscarVesceralOriginal/'; %Training Data
fov = 'tr'; % 'tr' = trunk, 'wb' = whole-body
nAtlases = 20; %  20 = use ALL VISCERAL Anatomy training atlases available, 
% More atlases = more computation time!

% IDs of the organs that should be segmented
organs = {'58' '187'};
% organs = {'all'};
%organs = {'58' '29662'} % radLex terms = {liver rKidney};

outputDir = '/media/louis/Volume/ProgramWorkResult/oscarVesceralResult';
multiOrganSegmentation(batchID, fileList, VISCERALdir, outputDir, fov, organs, nAtlases);