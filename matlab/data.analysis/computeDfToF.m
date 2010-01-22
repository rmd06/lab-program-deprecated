function dfToFTimeData = computeDfToF(botTimeData, tEvent, ...
    timeLengthBefore, timeLengthAfter)
% dfToFTimeData = computeDfToF(botTimeData, tEvent, timeLengthBefore, timeLengthAfter)
%            computes dF/F traces of all the sessions in one BOT trace.
%
% *botTimeData* should be in an n-by-nBOT [time bot] format, *bot* being 
% the time series BOT data of a total number of nBOT and *time* the 
% corresponding time. *Note* the time in it should be in raw form, 
% i.e. the unit is 1/10000 second.
% *tEvent* should be the *time point of the event start* (like ES, drug
% application, etc.).
% *timeLengthBefore* is the length of time before time point tEvent, in
% seconds. It is also the time period for caculating baseline brightness.
% *timeLengthAfter* is the length of time after tEvent, in seconds.
% *timeLengthBefore* plus *timeLengthAfter* is the total time in dF/F data.
% Output *dfToFTimeData* is an 1-by-n struct, the i-th in it represents the
% i-th session in one trial (one BOT trace in the input BOT data)

nSession = numel(tEvent); % One event means one session.
rawTimeLengthBefore = timeLengthBefore * 10000;
rawTimeLengthAfter = timeLengthAfter * 10000;

tSessionBegin = round(tEvent - rawTimeLengthBefore) ;
tSessionEnd = round(tEvent + rawTimeLengthAfter) ;

% A struct is used to store data in different sessions.
for i = 1:nSession
	data(i).rawData = botTimeData((botTimeData(:,1) > tSessionBegin(i) & ...
        botTimeData(:,1) < tSessionEnd(i)), :);
    timeData = data(i).rawData(:, 1); % First column is time. Strip it off.
    relativeTimeData = timeData - tEvent(i); 
    rawData = data(i).rawData(:, 2:end); % Raw data without time.
    baselineRawData = botTimeData((botTimeData(:,1) > tSessionBegin(i) & ...
        botTimeData(:,1) < tEvent(i)), 2:end); 
        % Select baseline brightness data. Stripped time column off.
    meanBaselineF = ones(size(rawData,1), 1) * mean(baselineRawData);  
                 % Mean F of baseline. Ready the size for './' .
    fToF = rawData ./ meanBaselineF; 
    dfToF = fToF - 1;
    data(i).dfToF = [timeData dfToF]; % Merge the time back.
    data(i).dfToFRelativeInSeconds = [relativeTimeData/10000 dfToF];
end
dfToFTimeData = data;

return