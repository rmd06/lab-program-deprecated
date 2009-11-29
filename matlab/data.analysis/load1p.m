function data = load1p(FullFileName)
% load1p: Load one multi-page TIFF image into a matrix.
%         The matrix is (height, width, number of pages).
% Syntax:
%   a = load1p(FullFileName)
%   FullFileName is a string and should be filename with full path, 
%   e.g. 'C:\data\imaging.tif' .

% Written by Li Hao @ Guo Lab, ION, in 2009.
% Modified by Zhou Bangyu @ Guo Lab, ION, Nov. 29, 2009.

if (nargin == 0)
    [FileName, PathName] = uigetfile('*.tif','Select the TIFF file','H:\');
    if isequal(FileName, 0)
        disp('TIFF Loading Canceled');
        return
    end
    FullFileName = strcat(PathName, FileName);
else
    example = imread(FullFileName, 1);
    [y x] = size(example);
%     nPage=fileno;
end

INFO = imfinfo(FullFileName);
% number of pages in the multi-page TIFF
nPage = numel(INFO);
x = INFO(1).Width;
y = INFO(1).Height;

data = zeros(y, x, nPage, 'uint16');

handle = waitbar(0,'Loading image');
for i = 1:nPage
%   Only after R2009a, elsewise use the following line
%     data(:,:,i) = imread(FullFileName,i);
    data(:,:,i) = imread(FullFileName, i, 'Info', INFO);
    waitbar(i/nPage, handle);
end
delete(handle);
disp(FullFileName);

return