function varargout = roigui(varargin)
% ROIGUI M-file for roigui.fig
%      ROIGUI, by itself, creates a new ROIGUI or raises the existing
%      singleton*.
%
%      H = ROIGUI returns the handle to a new ROIGUI or the handle to
%      the existing singleton*.
%
%      ROIGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROIGUI.M with the given input arguments.
%
%      ROIGUI('Property','Value',...) creates a new ROIGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before roigui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to roigui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roigui

% Last Modified by GUIDE v2.5 10-Sep-2010 12:03:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roigui_OpeningFcn, ...
                   'gui_OutputFcn',  @roigui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before roigui is made visible.
function roigui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roigui (see VARARGIN)

% Choose default command line output for roigui
handles.output = hObject;

% UIWAIT makes roigui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Managing inputs: There can be no inputs, or 1 string to indicate image
% filename, or 1 3-dimensional array that is image data.

handles.imageData = [];
handles.fullFilename = [];
handles.roi = [];  
handles.nRoi = 1;
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = roigui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in startendtoggle.
function startendtoggle_Callback(hObject, eventdata, handles)
% hObject    handle to startendtoggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of startendtoggle
state = get(hObject,'Value');
if state == get(hObject,'Max')  % drawing is started
  set(hObject,'String', 'End'); % change toggle button text to "End"
  isStarted = true;             % set a flag to indicate state
  set(handles.tipsbox, 'String', ...
      'Press End to draw another ROI and stop'); % show tips to end drawing
end
if state == get(hObject,'Min')  % drawing will end
  set(hObject,'String', 'Start'); % change button text to "Start"
  isStarted = false;
  set(handles.tipsbox, 'String', ...
      'Press Start to resume drawing ROIs');
end

if isStarted
  % The real work will be done here, as the "Start" button is pressed

  i = handles.nRoi;  % get from "cached" parameters
  roi = handles.roi;
  while ishandle(handles.axes1)
  % A loop of drawing polygonal ROIs, end until "End" is pressed
    if strcmp(get(hObject,'String'), 'Start')
      break
    end

    % The magic is really all in this following line
    [roi(i).x, roi(i).y, roi(i).BW, roi(i).xi, roi(i).yi] = roipoly;
    
    % Determing and illustrate ROI contours and numbered tags
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
    
    hold on;  % will now draw contour and number tag
    plot(roi(i).xi,roi(i).yi,'Color','w','LineWidth',1);
    text(roi(i).center(1), roi(i).center(2), num2str(i),...
         'Color', 'w', 'FontWeight','Bold');

    % Prepare for next ROI
    i = i + 1;
    handles.roi = roi; % better to "cache" the ROIs after each is done
    handles.nRoi = i;
    guidata(hObject, handles); % update the "cache"
  end
end

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
isLoaded = false;  % add a flag for loading image, initially not loaded
handles.isLoaded = isLoaded;
guidata(hObject, handles); 


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Initialize the pictures by pressing


% --- Executes during object creation, after setting all properties.
function startendtoggle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startendtoggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'Enable', 'off'); % initially not available to user

handles.Strings = {'Start';'End'};
guidata(hObject, handles); 


% --- Executes on button press in exportbutton.
function exportbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exportbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi = handles.roi;
imageData = handles.imageData;
fullFilename = handles.fullFilename;
assignin('base', 'roi', roi); % output to workspace!
assignin('base', 'imageData', imageData);
assignin('base', 'fullname', fullFilename);

% --- Executes during object creation, after setting all properties.
function tipsbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tipsbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', 'Press Load Image to load a stacked tiff image');


% --- Executes on button press in loadbutton.
function loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
isLoaded = handles.isLoaded;  % get flag
imageData = handles.imageData;
fullFilename = handles.fullFilename;

if isLoaded % do not load twice
  set(handles.tipsbox, 'String', 'Image already loaded');
else  %  if not loaded, load image and enable buttons
  [imageData fullFilename] = load1p();
  if isempty(imageData)  % deals with user cancelling file selection
    
  else
    imagesc(mean(imageData, 3));  % show image stack, averaged
    axis off;
    isLoaded = true;  % set flag to 'loaded'
    set(handles.startendtoggle, 'Enable', 'on');
    set(handles.exportbutton, 'Enable', 'on');
    set(handles.tipsbox, 'String', 'Press Start to draw ROIs');
   end
end

handles.isLoaded = isLoaded;  % "cache" and initialize some general var
handles.imageData = imageData;
handles.fullFilename = fullFilename;
guidata(hObject, handles);   % update the "cache"


% --- Executes during object creation, after setting all properties.
function exportbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exportbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'Enable', 'off');  %  
