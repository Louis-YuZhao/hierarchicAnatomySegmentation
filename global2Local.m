function global2Local(VISCERALsetup, organID)
% organID = '58'......

prevRegType = 'globAff';
VISCERALsetup.currentDir = [VISCERALsetup.tempDir '/' organID '/']; 
if ~exist(VISCERALsetup.currentDir,'file')
    system(['mkdir ' VISCERALsetup.currentDir]);
end
% VISCERALsetup.currentDir = VISCERALsetup.tempDir/'58'

%% Apply global transform to original organ annotations 
useOriginal=1;
disp(['Applying global transformations to original ' organID ' label masks...']);
transformSegment_global(VISCERALsetup, VISCERALsetup.globalTemp, organID, prevRegType, prevRegType, useOriginal);
% VISCERALsetup.globalTemp = VISCERALsetup.tempDir /globalTemp/
% organID = '58' ......
% prevRegType = 'globAff'
% useOriginal =1 

%% Generate ROI mask
dilFlag = 1;
no_bSp = 0;
disp(['Generate local ' organID ' fused mask from global registrations...']);
generateDilatedMask(VISCERALsetup, organID, prevRegType, dilFlag, VISCERALsetup.largeROI, no_bSp); 
% if dilFlag:
% [VISCERALsetup.currentDir organID '_maskFused_' regType '.nii']
% else 
% [VISCERALsetup.outDir '/' VISCERALsetup.imgID '_' VISCERALsetup.modality '_' organID '.nii']

%% Local registration 
currentRegType = 'locAff';
disp(['Registering atlases with local ' organID ' fused mask as reference...']);
localRegister(VISCERALsetup, 'globalTemp', organID, prevRegType, currentRegType);
%

[outSeg] = outSegNeeded(VISCERALsetup, organID);

if outSeg,
    %% Apply local affine transform to original organ annotations
    useOriginal=0;
    disp(['Applying local affine ' organID ' transformations to locally oriented ' organID ' label masks...']);
    transformSegment_global(VISCERALsetup,VISCERALsetup.currentDir,organID,prevRegType,currentRegType,useOriginal);

    %% Label fusion %%%%%%
    % % ++++++++ Majority voting
    disp(['Label Fusion (affine): Majority voting_' organID '...']);
    dilFlag = 0;
    [a_bSp] = generateDilatedMask(VISCERALsetup,organID,currentRegType,dilFlag,VISCERALsetup.largeROI,VISCERALsetup.bSp);
    
    %% Local non-rigid bSpline %%%%%%
    prevRegType = 'locAff';
    currentRegType = 'bSp';
    localbSpReg(VISCERALsetup,organID,organID,prevRegType,currentRegType,a_bSp);
    
    %% Apply local bSpline transform to original organ annotations
    disp(['Applying local bSpline transformations to original ' organID ' label masks...']);
    transformSegment_global(VISCERALsetup,VISCERALsetup.currentDir,organID,prevRegType,currentRegType,useOriginal);
    
    %% Label fusion %%%%%%
    % % ++++++++ Majority voting
    disp(['Label Fusion (bSpline): Majority voting_' organID '...']);
    dilFlag = 0;
    generateDilatedMask(VISCERALsetup,organID,currentRegType,dilFlag,VISCERALsetup.largeROI,no_bSp);       
end;
