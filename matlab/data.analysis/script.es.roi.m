% Script for imaging processing

%%
% Load files, images
imageFileName = '';
timingFileName = '';

imageData = load1p(imageFileName);
load timingFileName;  % arrary named data, and protocol, loaded

%%
% ROIs and compute BOT
handleImage = imagesc(imageData(:, :, 1));

prompt = {'Total ROI Number:'};  % ask for ROI numberdlg_title = 'Inputs for mmROI function';
num_lines = 1;
def = {'1'};
inputs  = str2num(char(inputdlg(prompt, dlg_title, num_lines, def)));
nRoi = inputs(1);  % get ROI number

roiInfo = getroi(nRoi, handleImage);
botData = bot(imageData, roiInfo);
% todo: save the ROI position figure

%%
% Find timing infomation
[tFrameUp tEsUp tFrameOnEsUp tFrameOnEsDown] = timing(data);

botPlotData = (tFrameUp, botData);


