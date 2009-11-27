function data=load1p(fileno)

[FileName,PathName] = uigetfile('*.tif','Select the TIF file','H:\');
path=strcat(PathName,FileName);

if (nargin == 0)
    INFO=imfinfo(path);
    j=numel(INFO);
    x=INFO(1).Width;
    y=INFO(1).Height;
else
    example=imread(path,1);
    [y x]=size(example);
    j=fileno;
end
data=zeros(y,x,j,'uint16');

handle=waitbar(0,'Loading image');
for i=1:j
%   Only after R2009a, elsewise use the following line
%     data(:,:,i)=imread(path,i);
    data(:,:,i)=imread(path,i,'Info',INFO);
    waitbar(i/j,handle);
end
close(handle);
disp(path);

return