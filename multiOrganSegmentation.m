function multiOrganSegmentation(batchID, testList, trainingDir, outputDir,  volumeFormat, organs, nAtlases)
%  batchID = 'LiverTest'
%  testList = ['/Users/medgift/Dropbox/anatomySegmentation/testDICOMs.txt'] (Test data)
%  trainingDir = trainingDir (Training data)
%  volumeFormat = 'tr' (format of the volume)
%  organs = {'all'}
%  nAtlases = 20

% returns the path, file name, and file name extension for the specified FILE. 
routeThisFile = fileparts(mfilename('fullpath'));
addpath(genpath(routeThisFile))

% Set empty output folder
outDir = [outputDir '/' batchID];

% if exist(outDir, 'dir')
%     rmdir(outDir,'s');
% end;

if ~exist(outDir, 'dir')
    mkdir(outDir);
end
%% Setup paths and registration parameters
[VISCERALsetup] = setVISCERALregsParams(batchID, trainingDir, volumeFormat, organs, outDir, nAtlases);
% return regsInfo

% Open DICOM folders list
fid = fopen(testList); % testList = '/Users/medgift/Dropbox/anatomySegmentation/testDICOMs.txt'
currentTestLine = fgetl(fid); % read one line of the file

while currentTestLine>0,
    tic
    %% Convert dicom folder to single nifti file
    [fidx] = strfind(currentTestLine, '/'); % Find one string within another
    dicomID = currentTestLine(fidx(end)+1:end);  % dicomID = "Imdownsample_CutResult_sizeAdjust_10000005_1_CT_wb.nrrd" ....
    prefix = 'Imdownsample_CutResult_sizeAdjust_';
    VISCERALsetup.imgID = dicomID(1+length(prefix):8+length(prefix)); % Add target image ID  

    if ~exist([outDir '/' dicomID '.nrrd'],'file'),
%         dcmNii_path =  [outDir '/' dicomID '.nii'];
%         disp('Converting DICOM folder to single NIFTI volume...');
%         [dcmNii, dcmNii_path] = my_dcm2nii(currentTestLine,dicomID,VISCERALsetup.ref_VISCERALnii,outDir);
%         clear dcmNii;
        
        %% Downsample original target volume %%
%         disp('Downsample NIFTI volume...');
%         [target_dS, target_dS_path, origSize] = myRescale(dcmNii_path, VISCERALsetup.scalingFactor, VISCERALsetup.tempDir);
%         VISCERALsetup.scaledImg = target_dS_path;
%         VISCERALsetup.origSize = origSize;
%         clear target_dS;  
%         VISCERALsetup.scaledImg = currentTestLine;   
        VISCERALsetup.targetImg = currentTestLine;  
        
        %% Global registration of whole body
        disp('Input ready. Starting global alignment...')
        VISCERALsetup.globalTemp = [VISCERALsetup.tempDir '/globalTemp/']; 
        if ~exist(VISCERALsetup.globalTemp,'file')
            system(['mkdir ' VISCERALsetup.globalTemp]);
        end
        
        globalRegister(VISCERALsetup);
        
        %% Organs segmentation
        disp('Starting organ segmentation...')
        
        % Segment all organs in list
        for o = 1:numel(VISCERALsetup.organs),
            organID = VISCERALsetup.organs{o};
            organInfo = getOrganInfo(organID);   
            
            disp(['Segmenting ' organInfo.name '...'])
            if strcmp(organInfo.initialization,'global')
                global2Local(VISCERALsetup, organID);
            else
                local2Local(VISCERALsetup, organID, organInfo.prevRadLex);
            end;
        end;
        
        %% Clean up temporary files
        % system(['rm -r ' outDir '/temp/']);
        
        currentTestLine = fgetl(fid);
    else
        currentTestLine = fgetl(fid);
    end;
    toc
end;

fclose(fid);
disp('Done!');