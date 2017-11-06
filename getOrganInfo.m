% Define if organ requires a global or local initialization,
% add organ name to radLex and
% add organs required for initialization (if required)
function [organInfo] = getOrganInfo(radLexID)

switch radLexID
    %% Global initialization
    case '58'
        organInfo.initialization = 'global';
        organInfo.name = 'liver';
    case '1302'
        organInfo.initialization = 'global';
        organInfo.name = 'rLung';
    case '1326'
        organInfo.initialization = 'global';
        organInfo.name = 'lLung';
    case '237'
        organInfo.initialization = 'global';
        organInfo.name = 'uBladder';
        
    %% Local initialization
    % Liver as reference
    case '29662'
        organInfo.initialization = 'local';
        organInfo.name = 'rKidney';
        organInfo.prevRadLex = {'58'};
    case '187'
        organInfo.initialization = 'local';
        organInfo.name = 'gBladder';
        organInfo.prevRadLex = {'58'};
    
    % rKidney as reference
    case '30324'
        organInfo.initialization = 'local';
        organInfo.name = 'rAdGland';
        organInfo.prevRadLex = {'58' '29662'};
    case '170'
        organInfo.initialization = 'local';
        organInfo.name = 'pancreas';
        organInfo.prevRadLex = {'58' '29662'};
    case '40357'
        organInfo.initialization = 'local';
        organInfo.name = 'rRectAb';
        organInfo.prevRadLex = {'58' '29662'};
    case '32248'
        organInfo.initialization = 'local';
        organInfo.name = 'rPsoas';
        organInfo.prevRadLex = {'58' '29662'};
        
     % rLung as reference 
    case '1247'
        organInfo.initialization = 'local';
        organInfo.name = '';
        organInfo.prevRadLex = {'1302'};
    case '480'
        organInfo.initialization = 'local';
        organInfo.name = 'aorta';
        organInfo.prevRadLex = {'1302'};
    case '2473'
        organInfo.initialization = 'local';
        organInfo.name = 'sternum';
        organInfo.prevRadLex = {'1302'};
    case '7578'
        organInfo.initialization = 'local';
        organInfo.name = 'thyroid';
        organInfo.prevRadLex = {'1302'};
        
    % lLung as reference    
    case '29663'
        organInfo.initialization = 'local';
        organInfo.name = 'lKidney';
        organInfo.prevRadLex = {'1326'};
    case '86'
        organInfo.initialization = 'local';
        organInfo.name = 'spleen';
        organInfo.prevRadLex = {'1326'};
        
    % lKidney as reference    
    case '30325'
        organInfo.initialization = 'local';
        organInfo.name = 'lAdGland';
        organInfo.prevRadLex = {'1326' '29663'};
    case '40358'
        organInfo.initialization = 'local';
        organInfo.name = 'lRectAb';
        organInfo.prevRadLex = {'1326' '29663'};
    case '32249'
        organInfo.initialization = 'local';
        organInfo.name = 'lPsoas';
        organInfo.prevRadLex = {'1326' '29663'};
    case '29193'
        organInfo.initialization = 'local';
        organInfo.name = '1LumbVert';
        organInfo.prevRadLex = {'1326' '29663'};
    otherwise
        disp('Wrong organ input')
end;


