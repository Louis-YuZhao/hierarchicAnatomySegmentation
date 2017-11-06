function localRegister(VISCERALsetup, prevRadlex, currRadlex, prevRegType, currentRegType)

if VISCERALsetup.scaled,
    fixPath = VISCERALsetup.scaledImg;
    % outDir/temp/dS_10000015_1_CT_wb.nii
else
    fixPath = VISCERALsetup.targetImg;
end;

prevDir = [VISCERALsetup.tempDir prevRadlex '/'];
currentDir = [VISCERALsetup.tempDir currRadlex '/'];
allAtlases = dir([prevDir '*' prevRegType '_result.0.*']);

maskFused = dir([currentDir currRadlex '_maskFused_' prevRegType '*']);
if ~isempty(maskFused)
    fmaskPath = [currentDir maskFused(1).name]; 
end;

out = currentDir;
p = VISCERALsetup.p_locAff;

for iterAtlas = 1:length(allAtlases),
    
    % Set path and load moving image
    movID = allAtlases(iterAtlas).name(1:numel(VISCERALsetup.imgID));
    movPath = [prevDir allAtlases(iterAtlas).name];
    
    %  Call elastix for first affine
    system(['elastix -f ' fixPath ' -m ' movPath ' -fMask ' fmaskPath ' -mMask ' fmaskPath ' -out ' out  ' -p ' p]);
    
    % Identify result files
    system(['mv ' out 'elastix.log ' out movID '_' currRadlex '_' currentRegType '_elastix.log']);
    system(['mv ' out 'IterationInfo.0.R0.txt ' out movID '_' currRadlex '_' currentRegType '_IterationInfo.0.R0.txt']);
    system(['mv ' out 'IterationInfo.0.R1.txt ' out movID '_' currRadlex '_' currentRegType '_IterationInfo.0.R1.txt']);
    system(['mv ' out 'IterationInfo.0.R2.txt ' out movID '_' currRadlex '_' currentRegType '_IterationInfo.0.R2.txt']);
    system(['mv ' out 'result.0.nii ' out movID '_' currRadlex '_' currentRegType '_result.0.nii']);
    system(['mv ' out 'TransformParameters.0.txt ' out movID '_' currRadlex '_' currentRegType '_TransformParameters.0.txt']);
end;