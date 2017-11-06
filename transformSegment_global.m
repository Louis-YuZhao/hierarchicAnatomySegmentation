function [] = transformSegment_global(VISCERALsetup,inDir,radlexID,prevRegType,currentRegType,useOriginal)
% inDir = VISCERALsetup.globalTemp = outDir/temp/globalTemp/
% radLexID = '58' ......
% prevRegType = 'globAff'
% currentRegType = 'globAff'
% useOriginal =1 

% useOriginal =1 :
% input = [VISCERALdir/dS_Anat2_Segmentations/* 10000015_1_CT_wb *_'58'_*
% mask(1).name](VISCERALsetup.trainSegmentsDir)
% output = outDir/temp/'58'
% transform parameters = outDir/temp/globalTemp/10000015_1_CT_wb.....

% useOriginal =0 :
% input = [outDir/temp/'58 *  10000015_1_CT_wb *_58_globAff_result.nii''
% mask(1).name](VISCERALsetup.currentDir)
% output = outDir/temp/'58'
% transform parameters = outDir/temp/globalTemp/10000015_1_CT_wb.....

out = VISCERALsetup.currentDir;
% VISCERALsetup.currentDir = outDir/temp/'58'

allTransforms = dir([inDir '*' currentRegType '_TransformParameters.0.txt']);
% {outDir/temp/globalTemp/ * 'globAff' ('locAff')_TransformParameters.0.txt}
% linear transformation

for t = 1:length(allTransforms),    
    % Get information for the corresponding transformation case
    % VISCERALsetup.imgID = "10000015_1_CT_wb.nii.gz"
    % numel : number of the array elements
    transfID = allTransforms(t).name(1:numel(VISCERALsetup.imgID));
    transf_p = [inDir allTransforms(t).name];
    
    % Change transform parameters to obtain a binary mask '(FinalBSplineInterpolationOrder 0)';
    if ~strcmp('bSp',currentRegType),
        fid = fopen(transf_p);
        tempfid = [transf_p '.1'];
        fout = fopen(tempfid,'a'); % 'a' : open or create file for writing; append data to end of file
        
        for l = 1:31,
            line = fgetl(fid);
            if (l==24),
                line(end-1) = '0';
            end;
            fprintf(fout,[line '\n']);
        end;
        
        fclose(fout); fclose(fid);
        system(['mv ' tempfid ' ' transf_p]);
    end;
    
    if useOriginal,
        mask = dir([VISCERALsetup.trainSegmentsDir '*' transfID '*_' radlexID '_*']);
        % mask = dir(['VISCERALdir/dS_Anat2_Segmentations/* transfID *_'58'_* ])
        if ~isempty(mask)
            in = [VISCERALsetup.trainSegmentsDir mask(1).name];
        end;
    else
        mask = dir([VISCERALsetup.currentDir '*' transfID '*_' radlexID '_' prevRegType '_result.nii']);
         % mask = dir([outDir/temp/'58' *  transfID *_58_globAff_result.nii'])
        if ~isempty(mask)
            in = [VISCERALsetup.currentDir mask(1).name];
        end;
    end;
    
    if ~isempty(mask)
    
        % Call Transformix for first affine
        system(['transformix -out ' out ' -tp ' transf_p ' -in ' in]);
        
        % Identify result files
        system(['mv ' out 'transformix.log ' out transfID '_' radlexID '_' currentRegType '_transformix.log']);
        system(['mv ' out 'result.nii ' out transfID '_' radlexID '_' currentRegType '_result.nii']);
    end;
end;