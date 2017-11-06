function local2Local(VISCERALsetup,radLexID,prevRadLex)

VISCERALsetup.currentDir = [VISCERALsetup.tempDir '/' radLexID '/']; system(['mkdir ' VISCERALsetup.currentDir]);

%% Set organ mask to current registration status
% Apply global transform to original organ annotations
prevRegType = 'globAff';
useOriginal=1;
disp(['Applying global transformations to original ' radLexID ' label masks...']);
transformSegment_global(VISCERALsetup,VISCERALsetup.globalTemp,radLexID,prevRegType,prevRegType,useOriginal);

% Apply local affine transform to original organ annotations
currentRegType = 'locAff';
for prevRad = 1:length(prevRadLex),
    if prevRad>1,
        prevRegType = 'locAff';
    end;
    prevDir = [VISCERALsetup.tempDir '/' prevRadLex{prevRad} '/'];
    disp(['Generate local mask from ' prevRadLex{prevRad} ' registrations...']);
    transformSegment_fromSegm(prevDir,VISCERALsetup.currentDir, radLexID, prevRegType, currentRegType);
end;

%% Generate ROI mask
dilFlag = 1;
no_bSp = 0;
disp(['Generate local ' radLexID ' fused mask from local ' prevRadLex{end} ' registrations...']);
generateDilatedMask(VISCERALsetup,radLexID,currentRegType,dilFlag,VISCERALsetup.largeROI,no_bSp); % -------------------

%% Local registration
disp(['Registering atlases with local ' radLexID ' fused mask as reference...']);
localRegister(VISCERALsetup,prevRadLex{end},radLexID,currentRegType,currentRegType);

[outSeg] = outSegNeeded(VISCERALsetup,radLexID);

if outSeg,
    %% Apply local affine transform to original organ annotations
    prevRegType = 'locAff';
    useOriginal=0;
    disp(['Applying local ' radLexID ' transformations to locally oriented ' radLexID ' label masks...']);
    transformSegment_global(VISCERALsetup,VISCERALsetup.currentDir,radLexID,prevRegType,currentRegType,useOriginal);

    %% Label fusion %%%%%%
    % % ++++++++ Majority voting
    disp(['Label Fusion: Majority voting_' radLexID '...']);
    dilFlag = 0;
    [a_bSp] = generateDilatedMask(VISCERALsetup,radLexID,currentRegType,dilFlag,VISCERALsetup.largeROI,VISCERALsetup.bSp);
    
    %% Local non-rigid bSpline %%%%%%
    prevRegType = 'locAff';
    currentRegType = 'bSp';
    localbSpReg(VISCERALsetup,radLexID,radLexID,prevRegType,currentRegType,a_bSp);
    
    %% Apply local B-spline transform to original organ annotations
    transformSegment_global(VISCERALsetup,VISCERALsetup.currentDir,radLexID,prevRegType,currentRegType,useOriginal);
    
    %% Label fusion %%%%%%
    % % ++++++++ Majority voting
    disp(['Label Fusion: Majority voting_' radLexID '...']);
    dilFlag = 0;
    generateDilatedMask(VISCERALsetup,radLexID,currentRegType,dilFlag,VISCERALsetup.largeROI,no_bSp);
end;

