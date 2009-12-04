% Script for imaging processing

% Load files, images
imageFileName = '';
timingFileName = '';

imageData = load1p(imageFileName);
load timingFileName;  % arrary named data, and protocol, loaded

% get ROIs and compute BOT

