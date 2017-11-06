function [atlasesbSp] = generateDilatedMask(VISCERALsetup, radLexID, regType, dilFlag, dilDist, bSpline)
% radLexID = '58' ......
% regType = 'globAff';
% dilFlag = 1
% dilDist = largeROI
% bSpline = no_bSp = 0
% if dilFlag:
% [VISCERALsetup.currentDir radLexID '_maskFused_' regType '.nii']
% else 
% [VISCERALsetup.outDir '/' VISCERALsetup.imgID '_' VISCERALsetup.modality '_' radLexID '.nii']

atlasesbSp = [];

% SE = strel('disk',R,N) creates a disk-shaped structuring element, where R specifies the radius.
% N specifies the number of line structuring elements used to approximate the disk shape. 
% Morphological operations using disk approximations run much faster
% when the structuring element uses approximations.
se = strel('disk', dilDist, 4); % dilation element (dilDist = VISCERALsetup.largeROI = 25; % voxels in kernel for dilating large ROI masks )
maskthr = 0.5; % minimum pixel intensity to be included in the mask

% Find all the existing transformations for the corresponding anatomical structure
allTransforms = dir([VISCERALsetup.currentDir '*' regType  '_result.nii']);

atlasList = [];

if ~isempty(allTransforms)
    
    % Initialize mask
    maskFused = load_untouch_nii([VISCERALsetup.currentDir allTransforms(1).name]);
    maskFused.img = maskFused.img>maskthr;
    
    if bSpline,
        atlasList = {allTransforms(1).name(1:end-4)};
        allMasks = maskFused.img;
    end;
    
    % Add remaining atlas estimations
    for iterAtlas = 2:length(allTransforms),
        label = load_untouch_nii([VISCERALsetup.currentDir allTransforms(iterAtlas).name]);
        maskFused.img = maskFused.img + (label.img>maskthr);
        
        if bSpline,
            atlasList = cat(2, atlasList, {allTransforms(iterAtlas).name(1:end-4)});
            allMasks = cat(4, allMasks, label.img>maskthr);
        end;
    end;
    
    if dilFlag,
        % Dilate final mask
        maskFused.img = imdilate(maskFused.img>maskthr, se);
        % IM2 = IMDILATE(IM,SE) dilates the grayscale, binary, or packed binary
        % image IM, returning the dilated image, IM2.
        targetMask_out = [VISCERALsetup.currentDir radLexID '_maskFused_' regType '.nii'];
    
    else
        
        if bSpline,
            maskThr = maskFused.img > (VISCERALsetup.bSp_thr-0.5);
            
            for a = 1:length(atlasList)
                % nnz : Number of nonzero matrix elements.
                dice(a) = 2*nnz(maskThr&allMasks(:,:,:,a))/(nnz(allMasks(:,:,:,a)) + nnz(maskThr));
            end;
            
            [dice, idx] = sort(dice,'descend');
            atlasesRanked = atlasList(idx);
            
            atlasesbSp = atlasesRanked(1:VISCERALsetup.bSp_atlases);
            return;
        end;
        
        % Threshold result
        % maskFused.img = maskFused.img > thr;
        if VISCERALsetup.final_thr == -1,
            maskFused.img = maskFused.img; % Probability map
        else
            maskFused.img = maskFused.img>VISCERALsetup.final_thr; % Final voting thresholded to VISCERALsetup.final_thr
        end;
        
        %% Rescale output segmentation to original size
        if VISCERALsetup.scaled,
            sampling = VISCERALsetup.scalingFactor;
            
            maskFused_rescaled = maskFused;  % Make a copy of the image
            maskFused_rescaled.img = maskFused_rescaled.img(1:sampling:end,1:sampling:end,1:sampling:end); % Downsample the image in all dimensions
            maskFused_rescaled.hdr.dime.dim= [3 size(maskFused_rescaled.img,1) size(maskFused_rescaled.img,2) size(maskFused_rescaled.img,3) 1 1 1 1];
            maskFused = maskFused_rescaled; clear maskFused_rescaled;
            
            maskFused = correctSize(maskFused,VISCERALsetup);
        end;
        
        targetMask_out = [VISCERALsetup.outDir '/' VISCERALsetup.imgID '_' VISCERALsetup.modality '_' radLexID '.nii'];
        %
    end;
    
    % Save mask of fused estimations
    save_untouch_nii(maskFused, targetMask_out);
end;