function [outSeg] = outSegNeeded(VISCERALsetup, organID)

outSeg = 0;

for o = 1:length(VISCERALsetup.organs)
    if strcmp(VISCERALsetup.organs{o}, organID),
        outSeg = 1;
        break;
    end;
end;