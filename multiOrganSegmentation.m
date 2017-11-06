function multiOrganSegmentation(batchID, fileList, VISCERALdir, outputDir,  fov, organs, nAtlases)
%  batchID = 'LiverTest'
%  fileList = ['/Users/medgift/Dropbox/anatomySegmentation/testDICOMs.txt'] (Test data)
%  VISCERALdir = VISCERALdir (Training data)
%  fov = 'tr' (fomat of the volume)
%  organs = {'all'}
%  nAtlases = 20

% returns the path, file name, and file name extension for the specified FILE. 
routeThisFile = fileparts(mfilename('fullpath'));
addpath(genpath(routeThisFile))

% Set empty output folder
outDir = [outputDir '/' batchID];

if exist(outDir, 'dir')
    rmdir(outDir,'s');
end;
mkdir(outDir);

%% Setup paths and registration parameters
[VISCERALsetup] = setVISCERALregsParams(batchID,VISCERALdir, fov, organs, outDir, nAtlases);
% return regsInfo

% Open DICOM folders list
fid = fopen(fileList); % fileList = '/Users/medgift/Dropbox/anatomySegmentation/testDICOMs.txt'
fline = fgetl(fid); % read one line of the file

while fline>0,
    tic
    %% Convert dicom folder to single nifti file
    [fidx] = strfind(fline, '/'); % Find one string within another
    dicomID = fline(fidx(end)+1:end);  % dicomID = "10000015_1_CT_wb.nii.gz" ....
    VISCERALsetup.imgID = dicomID; % Add target image ID  

    if ~exist([outDir '/' dicomID '.nrrd'],'file'),
        disp('Converting DICOM folder to single NIFTI volume...');
        [dcmNii, dcmNii_path] = my_dcm2nii(fline,dicomID,VISCERALsetup.ref_VISCERALnii,outDir);
        clear dcmNii;
        
        %% Downsample original target volume %%%%% 
        disp('Downsample NIFTI volume...');
        [target_dS, target_dS_path,origSize] = myRescale(dcmNii_path,VISCERALsetup.scalingFactor,VISCERALsetup.tempDir);
        VISCERALsetup.scaledImg = target_dS_path;
        VISCERALsetup.origSize = origSize;
        clear target_dS;
  
        %% Global registration of whole body
        disp('Input ready. Starting global alignment...')
        VISCERALsetup.globalTemp = [VISCERALsetup.tempDir '/globalTemp/']; system(['mkdir ' VISCERALsetup.globalTemp]);
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
        system(['rm -r ' outDir '/temp/']);
        
        fline = fgetl(fid);
    else
        fline = fgetl(fid);
    end;
    toc
end;

fclose(fid);
disp('Done!');