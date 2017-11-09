function local2Local(VISCERALsetup, organID, prevRadLex)

VISCERALsetup.currentDir = [VISCERALsetup.tempDir '/' organID '/'];
if ~exist(VISCERALsetup.currentDir,'file')
    system(['mkdir ' VISCERALsetup.currentDir]);
end
%% Set organ mask to current registration status
% Apply global transform to original organ annotations
prevRegType = 'globAff';
useOriginal=1;
disp(['Applying global transformations to original ' organID ' label masks...']);
transformSegment_global(VISCERALsetup, VISCERALsetup.globalTemp, organID, prevRegType, prevRegType, useOriginal);

% Apply local affine transform to original organ annotations
currentRegType = 'locAff';
for prevRad = 1:length(prevRadLex),
    if prevRad>1,
        prevRegType = 'locAff';
    end;
    prevDir = [VISCERALsetup.tempDir '/' prevRadLex{prevRad} '/'];
    disp(['Generate local mask from ' prevRadLex{prevRad} ' registrations...']);
    transformSegment_fromSegm(VISCERALsetup, prevDir, VISCERALsetup.currentDir, organID, prevRegType, currentRegType);
end;

%% Generate ROI mask
dilFlag = 1;
no_bSp = 0;
disp(['Generate local ' organID ' fused mask from local ' prevRadLex{end} ' registrations...']);
generateDilatedMask(VISCERALsetup, organID, currentRegType, dilFlag, VISCERALsetup.largeROI,no_bSp); 

%% Local registration
disp(['Registering atlases with local ' organID ' fused mask as reference...']);
localRegister(VISCERALsetup,prevRadLex{end},organID,currentRegType,currentRegType);

[outSeg] = outSegNeeded(VISCERALsetup,organID);

if outSeg,
    %% Apply local affine transform to original organ annotations
    prevRegType = 'locAff';
    useOriginal=0;
    disp(['Applying local ' organID ' transformations to locally oriented ' organID ' label masks...']);
    transformSegment_global(VISCERALsetup,VISCERALsetup.currentDir,organID,prevRegType,currentRegType,useOriginal);

    %% Label fusion %%%%%%
    % % ++++++++ Majority voting
    disp(['Label Fusion: Majority voting_' organID '...']);
    dilFlag = 0;
    [a_bSp] = generateDilatedMask(VISCERALsetup,organID,currentRegType,dilFlag,VISCERALsetup.largeROI,VISCERALsetup.bSp);
    
    %% Local non-rigid bSpline %%%%%%
    prevRegType = 'locAff';
    currentRegType = 'bSp';
    localbSpReg(VISCERALsetup, organID, organID, prevRegType, currentRegType, a_bSp);
    
    %% Apply local B-spline transform to original organ annotations
    transformSegment_global(VISCERALsetup, VISCERALsetup.currentDir, organID, prevRegType, currentRegType, useOriginal);
    
    %% Label fusion %%%%%%
    % % ++++++++ Majority voting
    disp(['Label Fusion: Majority voting_' organID '...']);
    dilFlag = 0;
    generateDilatedMask(VISCERALsetup, organID, currentRegType, dilFlag, VISCERALsetup.largeROI, no_bSp);
end;

