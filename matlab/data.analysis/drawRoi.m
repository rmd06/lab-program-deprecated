function [ ] = drawRoi( roiData, handleFig )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

roi = roiData;
nRoi = size(roi, 2);

hold on;

for i=1:nRoi
%     figure(handleFig);
    [roi(i).x, roi(i).y, roi(i).BW, roi(i).xi, roi(i).yi] = roipoly;
    xmingrid = max(roi(i).x(1), floor(min(roi(i).xi)));
    xmaxgrid = min(roi(i).x(2), ceil(max(roi(i).xi)));
    ymingrid = max(roi(i).y(1), floor(min(roi(i).yi)));
    ymaxgrid = min(roi(i).y(2), ceil(max(roi(i).yi)));
    roi(i).xgrid = xmingrid : xmaxgrid;
    roi(i).ygrid = ymingrid : ymaxgrid;
    [X, Y] = meshgrid(roi(i).xgrid, roi(i).ygrid);
    inPolygon = inpolygon(X, Y, roi(i).xi, roi(i).yi);
    Xin = X(inPolygon);
    Yin = Y(inPolygon);
        
    roi(i).area = polyarea(roi(i).xi,roi(i).yi);
    roi(i).center = [mean(Xin(:)), mean(Yin(:))];
    
%     figure(handleFig);
    hold on; 
%     plot(roi(i).xi,roi(i).yi,'Color',clrMap(rndprm(i), :),'LineWidth',1);
%     text(roi(i).center(1), roi(i).center(2), num2str(i),...
%          'Color', clrMap(rndprm(i), :), 'FontWeight','Bold');
    plot(roi(i).xi,roi(i).yi,'Color','w','LineWidth',1);
    text(roi(i).center(1), roi(i).center(2), num2str(i),...
         'Color', 'w', 'FontWeight','Bold');
end

end

