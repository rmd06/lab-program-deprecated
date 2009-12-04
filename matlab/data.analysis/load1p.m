function data = load1p(fullFileName)
% load1p: Load one multi-page TIFF image into an array.
%    data = load1p(fullFileName) loads the file fullFileName into a three
%    dimensional array data (height, width, number of pages).
% 
%    The multi-page TIFF file should be grayscale and same size across all
%    pages. It's meant to be the data from a imaging experiment.
% 
%    fullFileName is a string and should be filename with full path, 
%    e.g. 'C:\data\imaging.tif' .

% Written by Li Hao @ Guo Lab, ION, 2009.
% Modified by Zhou Bangyu @ Guo Lab, ION, Nov. 29, 2009.

if (nargin == 0)
    [FileName, PathName] = uigetfile('*.tif','Select the TIFF file','e:\data\');
    if isequal(FileName, 0)
        disp('TIFF Loading Canceled');
        return
    end    % Deals with user canceling loading.
    fullFileName = strcat(PathName, FileName);
else
    example = imread(fullFileName, 1);
    [y x] = size(example);
%     nPage=fileno;
end

INFO = imfinfo(fullFileName);
nPage = numel(INFO);    % number of pages (frames) in the multi-page TIFF
x = INFO(1).Width;
y = INFO(1).Height;

data = zeros(y, x, nPage, 'uint16');

texFullFileName = strrep(fullFileName,'\','\\'); % Make filename TeX.
handle = waitbar(0,sprintf('Loading image\n%s', texFullFileName));
for i = 1:nPage
%   Only after R2009a, elsewise use the following line
%     data(:,:,i) = imread(fullFileName,i);
    data(:, :, i) = imread(fullFileName, i, 'Info', INFO);
    waitbar(i/nPage, handle);
end
delete(handle);
disp(fullFileName);

return