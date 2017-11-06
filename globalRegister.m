
function globalRegister(VISCERALsetup)

for a=1:length(VISCERALsetup.trainAtlases.paths)
    
    if VISCERALsetup.scaled,
        fixPath = VISCERALsetup.scaledImg;
    else
        fixPath = VISCERALsetup.targetImg;
    end;
    
    regType = 'globAff';
    
    % Set path and load moving image
    movPath = VISCERALsetup.trainAtlases.paths{a};
    out = VISCERALsetup.globalTemp;
    p = VISCERALsetup.p_globAff;
    
    %  Call elastix for first affine
    system(['elastix -f ' fixPath ' -m ' movPath ' -out ' out  ' -p ' p]);
    
    % Identify result files
    system(['mv ' out 'elastix.log ' out VISCERALsetup.trainAtlases.IDs{a} '_' regType '_elastix.log']);
    system(['mv ' out 'IterationInfo.0.R0.txt ' out VISCERALsetup.trainAtlases.IDs{a} '_' regType '_IterationInfo.0.R0.txt']);
    system(['mv ' out 'IterationInfo.0.R1.txt ' out VISCERALsetup.trainAtlases.IDs{a} '_' regType '_IterationInfo.0.R1.txt']);
    system(['mv ' out 'IterationInfo.0.R2.txt ' out VISCERALsetup.trainAtlases.IDs{a} '_' regType '_IterationInfo.0.R2.txt']);
    system(['mv ' out 'result.0.nii ' out VISCERALsetup.trainAtlases.IDs{a} '_' regType '_result.0.nii']);
    system(['mv ' out 'TransformParameters.0.txt ' out VISCERALsetup.trainAtlases.IDs{a} '_' regType '_TransformParameters.0.txt']);
end;