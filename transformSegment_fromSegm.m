function [] = transformSegment_fromSegm(VISCERALsetup, prevDir, currentDir, currentRadlex, globalReg, localReg)
%
%
%

out = currentDir;
allTransforms = dir([prevDir '*' localReg '_TransformParameters.0.txt']);

for t = 1:length(allTransforms),
    
    % Get information for the corresponding transformation case
    transfID = allTransforms(t).name(1:numel(VISCERALsetup.imgID));
    transf_p = [prevDir allTransforms(t).name];
    
    mask = dir([VISCERALsetup.currentDir transfID '_' currentRadlex '_' globalReg '_result.*']);
    
    if ~isempty(mask)
        in = [currentDir mask(1).name];
        % in = [currentDir transfID '_' currentRadlex '_' globalReg '_result.*']
        
        % Call Transformix for first affine
        system(['/home/louis/Documents/Packages/elastix_v4.8/bin/transformix -out ' out ' -tp ' transf_p ' -in ' in]);
        
        % Identify result files
        system(['mv ' out 'transformix.log ' out transfID '_' currentRadlex '_' localReg '_transformix.log']);
        system(['mv ' out 'result.nii ' out transfID '_' currentRadlex '_' localReg '_result.nii']);
    end;
end;

