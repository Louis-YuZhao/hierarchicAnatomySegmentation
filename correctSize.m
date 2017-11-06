function [newImg] = correctSize(newImg,VISCERALsetup)

diffSize = VISCERALsetup.origSize-newImg.hdr.dime.dim(2:4);

% x dim
if diffSize(1)~=0,
    if diffSize(1)==1,
        newImg.img = cat(1,newImg.img,newImg.img(end,:,:)); % Add a slice in x-dim
    elseif diffSize(1)==-1,
        newImg.img = newImg.img(1:end-1,:,:); % Remove a slice in x-dim
    end;
end;
% y dim
if diffSize(2)~=0,
    if diffSize(2)==1,
        newImg.img = cat(2,newImg.img,newImg.img(:,end,:)); % Add a slice in y-dim
    elseif diffSize(2)==-1,
        newImg.img = newImg.img(:,1:end-1,:); % Remove a slice in y-dim
    end;
end;
% z dim
if diffSize(3)~=0,
    if diffSize(3)==1,
        newImg.img = cat(3,newImg.img,newImg.img(:,:,end)); % Add a slice in z-dim
    elseif diffSize(3)==-1,
        newImg.img = newImg.img(:,:,1:end-1); % Remove a slice in z-dim
    end;
end;

newImg.hdr.dime.dim= [3 size(newImg.img,1) size(newImg.img,2) size(newImg.img,3) 1 1 1 1];
