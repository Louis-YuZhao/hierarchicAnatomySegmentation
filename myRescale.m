% Rescales(downsample, upsample) a nifti volume without interpolation
function [downSamp_Img,newFilename,origSize] = myRescale(filename, scalingFactor, outDir)
% filename 
% scalingFactor = VISCERALsetup.scalingFactor
% outDir = VISCERALsetup.tempDir

if strcmp(filename(end-2:end),'.gz')
    filename = filename(1:end-3);
    if ~exist(filename,'file')
        gunzip ([filename '.gz']);
    end;
end;

[idx] = strfind(filename,'/');
newFilename = [outDir '/dS_' filename(idx(end)+1:end)];

if ~exist(newFilename,'file')
    
    sampling = 1/scalingFactor;
    
    original_Img = load_untouch_nii(filename); % Load current image
    origSize = original_Img.hdr.dime.dim(2:4);
    downSamp_Img = original_Img; % Make a copy of the image
    downSamp_Img.img = downSamp_Img.img(1:sampling:end,1:sampling:end,1:sampling:end); % Downsample the image in all dimensions
    downSamp_Img.hdr.dime.dim= [3 size(downSamp_Img.img,1) size(downSamp_Img.img,2) size(downSamp_Img.img,3) 1 1 1 1];
    
    save_untouch_nii(downSamp_Img, newFilename);   % Save new image
end;