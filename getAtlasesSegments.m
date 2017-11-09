function [numAtlases,atlases,refNii] = getAtlasesSegments(modality, numAtlases, trainAtlasDir, trainSegmentsDir, prefix)
% modality = 'CTce_ThAb'
% numAtlases = 20
% trainAtlasDir = [VISCERALdir 'dS_' 'Anat2_' 'Volumes' '/'];
% trainSegmentsDir = [VISCERALdir 'dS_' 'Anat2_' 'Segmentations' '/'];
% prefix = 'dS_'

% Select atlases from the data set for the registrations
allAtlases = dir([trainAtlasDir '*' modality '*']);
% VISCERALdir/dS_Anat2_Volumes/* CTce_ThAb * 

if numAtlases>length(allAtlases),
    disp('-- There are not enough atlases in the VISCERAL data set!!');
    numAtlases = length(allAtlases);
    disp(['-- Using max number of atlases: ' num2str(numAtlases)]);
else
    randAtlasSelection = randperm(length(allAtlases),numAtlases);
end;

atlases.IDs = []; atlases.paths = []; 
for a = 1:numAtlases,
    atlasID = allAtlases(randAtlasSelection(a)).name(1+length(prefix):8+length(prefix));
    % 10000110
    atlasPath = [trainAtlasDir allAtlases(randAtlasSelection(a)).name];
    
    % Get paths for each atlas
    atlases.IDs = cat(2,{atlasID},atlases.IDs);
    atlases.paths = cat(2,{atlasPath},atlases.paths);
    % VISCERALdir/dS_Anat2_Volumes/10000110_1_CTce_ThAb.nii.gz
    % .......
end;

% Reference VISCERAL volume path for conversion DICOM to NIFTI file
refNii = [trainAtlasDir allAtlases(1).name ];