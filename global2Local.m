function global2Local(VISCERALsetup,radLexID)
% radLexID = '58'......

prevRegType = 'globAff';
VISCERALsetup.currentDir = [VISCERALsetup.tempDir '/' radLexID '/']; system(['mkdir ' VISCERALsetup.currentDir]);
% VISCERALsetup.currentDir = VISCERALsetup.tempDIr/'58'

%% Apply global transform to original organ annotations 
useOriginal=1;
disp(['Applying global transformations to original ' radLexID ' label masks...']);
transformSegment_global(VISCERALsetup,VISCERALsetup.globalTemp,radLexID,prevRegType,prevRegType,useOriginal);
% VISCERALsetup.globalTemp = VISCERALsetup.tempDir /globalTemp/
% radLexID = '58' ......
% prevRegType = 'globAff'
% useOriginal =1 

%% Generate ROI mask
dilFlag = 1;
no_bSp = 0;
disp(['Generate local ' radLexID ' fused mask from global registrations...']);
generateDilatedMask(VISCERALsetup,radLexID,prevRegType,dilFlag,VISCERALsetup.largeROI,no_bSp); 
% if dilFlag:
% [VISCERALsetup.currentDir radLexID '_maskFused_' regType '.nii']
% else 
% [VISCERALsetup.outDir '/' VISCERALsetup.imgID '_' VISCERALsetup.modality '_' radLexID '.nii']

%% Local registration 
currentRegType = 'locAff';
disp(['Registering atlases with local ' radLexID ' fused mask as reference...']);
localRegister(VISCERALsetup,'globalTemp',radLexID,prevRegType,currentRegType);
%

[outSeg] = outSegNeeded(VISCERALsetup,radLexID);

if outSeg,
    %% Apply local affine transform to original organ annotations
    useOriginal=0;
    disp(['Applying local affine ' radLexID ' transformations to locally oriented ' radLexID ' label masks...']);
    transformSegment_global(VISCERALsetup,VISCERALsetup.currentDir,radLexID,prevRegType,currentRegType,useOriginal);

    %% Label fusion %%%%%%
    % % ++++++++ Majority voting
    disp(['Label Fusion (affine): Majority voting_' radLexID '...']);
    dilFlag = 0;
    [a_bSp] = generateDilatedMask(VISCERALsetup,radLexID,currentRegType,dilFlag,VISCERALsetup.largeROI,VISCERALsetup.bSp);
    
    %% Local non-rigid bSpline %%%%%%
    prevRegType = 'locAff';
    currentRegType = 'bSp';
    localbSpReg(VISCERALsetup,radLexID,radLexID,prevRegType,currentRegType,a_bSp);
    
    %% Apply local bSpline transform to original organ annotations
    disp(['Applying local bSpline transformations to original ' radLexID ' label masks...']);
    transformSegment_global(VISCERALsetup,VISCERALsetup.currentDir,radLexID,prevRegType,currentRegType,useOriginal);
    
    %% Label fusion %%%%%%
    % % ++++++++ Majority voting
    disp(['Label Fusion (bSpline): Majority voting_' radLexID '...']);
    dilFlag = 0;
    generateDilatedMask(VISCERALsetup,radLexID,currentRegType,dilFlag,VISCERALsetup.largeROI,no_bSp);       
end;
