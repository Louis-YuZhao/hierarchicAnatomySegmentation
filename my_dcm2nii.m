function [dcmNii,dcmNii_path] = my_dcm2nii(dicomFolder,dicomID,ref_VISCERALnii,out)

% Get dicom ID
outNii = [out '/' dicomID];

% Use VISCERAL data set reference nifti file for conversion
refNii = load_untouch_nii(ref_VISCERALnii);

% Find all dicom slices
files = dir(dicomFolder);
dicomFileNames=[];
for j=1:size(files,1),  
    if ~files(j).isdir, % Skip dirs
    %if regexpi(files(j).name, '.dcm'), % If files have .dcm in the name
        dicomFileNames=[dicomFileNames; {files(j).name}]; 
    end;
end;
% perform checks
if size(dicomFileNames,1)==0,
    disp('no file found');
    return;
end;

% sort the slices
sortedDicomFileNames=[];
count=1;
image_nb=size(dicomFileNames,1);
while count<=image_nb,
    for k=1:image_nb,
        dcmInfo=dicominfo([dicomFolder '/' dicomFileNames{k,:}]);
        
        if dcmInfo.InstanceNumber==count,
            sortedDicomFileNames=[sortedDicomFileNames; {dicomFileNames(k,:)}];
            count=count+1;
            k=dcmInfo.InstanceNumber;
        end;
    end;
end;
if size(sortedDicomFileNames,1)~=image_nb,
    disp('Not all images were sorted');
    return;
end;
dicomFileNames=sortedDicomFileNames;

imageTemp=dicomread([dicomFolder '/' dicomFileNames{1}{:}]);
imageStack=zeros(size(imageTemp,1),size(imageTemp,2),image_nb);
imageStack(:,:,1)=(dicomread(fullfile(dicomFolder,dicomFileNames{1}{:})));
dicomDim = [size(imageStack,1) size(imageStack,2)];
for i=1:image_nb,
    dicomSlice = (dicomread(fullfile(dicomFolder,dicomFileNames{i}{:})));
    % Just add slices from a volume with the same dimensions
    if dicomDim == [size(dicomSlice,1) size(dicomSlice,2)],
        imageStack(:,:,i)=dicomSlice;
    else
        disp('---WARNING: Folder contains DICOM files from different dimensions!')
    end;
end;

% Adapt reference .nii header
dcmNii = refNii;

% convert to Hounsfield units
dcmNii.img = double((imageStack.*dcmInfo.RescaleSlope)+dcmInfo.RescaleIntercept);

dcmNii.fileprefix = outNii;
dcmNii.hdr.dime.dim= [3 size(dcmNii.img,1) size(dcmNii.img,2) size(dcmNii.img,3) 1 1 1 1];
dcmNii.hdr.dime.datatype = dcmInfo.BitsAllocated;
dcmNii.hdr.dime.pixdim = [-1 dcmInfo.PixelSpacing(1) dcmInfo.PixelSpacing(2) dcmInfo.SliceThickness 0 0 0 0];
dcmNii.hdr.dime.glmax = max(dcmNii.img(:))+(min(dcmNii.img(:))*-1);
dcmNii.hdr.dime.glmin = min(dcmNii.img(:));

% Convert volume to VISCERAL data set orientation
dimZ = size(dcmNii.img,3);
dcmNii.img = rot90(dcmNii.img,1); 
invImg = dcmNii.img;
for z = 1:dimZ,
    dcmNii.img(:,:,z) = invImg(:,:,(dimZ+1)-z);
end;

dcmNii_path = [outNii '.nii'];
save_untouch_nii(dcmNii,dcmNii_path);

% Clear temporary files and variables
clear dcmInfo; clear invImg; clear refNii; clear imageTemp; clear imageStack; clear dcm_HU;
clear count; clear files; clear outNii; clear ref_VISCERALnii;
clear dicomFileNames; clear dimZ; clear i; clear idx; clear image_nb; clear j; clear k; clear z; clear sortedDicomFileNames;