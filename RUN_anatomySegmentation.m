%
% Hierarchic atlas-based organ segmentation
%
close all; clear all; clc;

%% Settings
batchID = 'LiverTest';
testList = ['/media/louis/Volume/ResearchData/oscarVesceralOriginal/ds_Anat_Volumes/FileList.txt']; % Test Data

trainingDir = '/media/louis/Volume/ResearchData/oscarVesceralOriginal/'; %Training Data
volumeFormat = 'tr'; % 'tr' = trunk, 'wb' = whole-body
nAtlases = 19; %  20 = use ALL VISCERAL Anatomy training atlases available, 
% More atlases = more computation time!

% IDs of the organs that should be segmented
organs = {'58' '187'};
% organs = {'all'};
% organs = {'58' '29662'} % radLex terms = {liver rKidney};

outputDir = '/media/louis/Volume/ProgramWorkResult/oscarVesceralResult';
multiOrganSegmentation(batchID, testList, trainingDir, outputDir, volumeFormat, organs, nAtlases);