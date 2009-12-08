% Script for imaging processing

%%
% Load files, images
expDateShort = '091103';
expDateLong = strcat('20', expDateShort);
expName = 'a05-01-lobe-med-01-lr-001';

imageFileName = strcat('e:\data\zby\registered\', expDateLong, ...
    '\registered-', expName, '.tif');

timingFileName = strcat('e:\data\zby\time\', expDateShort, '\', expName, '.mat');

imageData = load1p(imageFileName);
load(timingFileName, 'data');  
timingData = data;
clear data

%%
% ROIs and compute BOT
handleFig = figure();
imagesc(imageData(:, :, 1));  % Figure handle to remember, not image handle

prompt = {'Total ROI Number:'};  % ask for ROI number
dlg_title = 'Inputs for mmROI function';
num_lines = 1;
def = {'1'};
inputs  = str2num(char(inputdlg(prompt, dlg_title, num_lines, def)));
nRoi = inputs(1);  % get ROI number

roiInfo = getroi(nRoi, handleFig);
botData = bot(imageData, roiInfo);
% todo: save the ROI position figure

%%
% Find timing infomation
[tFrameUp tEsUp tFrameOnEsUp tFrameOnEsDown] = timing(timingData);
tEvent = tEsUp([1 5 9 13]);

% Timing and frame match together
% In cases of mismatch ...
% [nFrameRecorded n] = size(botData);
% clear n
% nFrameDetected = numel(tFrameUp);
% if (nFrameDetected < nFrameRecorded)
%     botData = botData(1:nFrameDetected, :); 
% end  % ... throw away some tail frames.
botTimeData = [tFrameUp, botData];
botPlotData = [tFrameUp/10000, botData];  % scale the time, now in seconds

%%
% Plot
dfToFTimeData = computeDfToF(botTimeData, tEvent, 5, 15);

