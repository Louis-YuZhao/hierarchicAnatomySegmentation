function [outSeg] = outSegNeeded(VISCERALsetup,radlexID)

outSeg = 0;

for o = 1:length(VISCERALsetup.organs)
    if strcmp(VISCERALsetup.organs{o},radlexID),
        outSeg = 1;
        break;
    end;
end;