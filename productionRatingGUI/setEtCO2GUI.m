function varargout = setEtCO2GUI(varargin)
% SETRRGUI M-file for setEtCO2GUI.fig
%      SETEtCO2GUI, by itself, creates a new SETEtCO2GUI or raises the existing
%      singleton*.
%
%      H = SETEtCO2GUI returns the handle to a new SETEtCO2GUI or the handle to
%      the existing singleton*.
%
%      SETEtCO2GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETEtCO2GUI.M with the given input arguments.
%
%      SETEtCO2GUI('Property','Value',...) creates a new SETEtCO2GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setEtCO2GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setEtCO2GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setEtCO2GUI

% Last Modified by GUIDE v2.5 19-Feb-2010 15:21:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @setEtCO2GUI_OpeningFcn, ...
    'gui_OutputFcn',  @setEtCO2GUI_OutputFcn, ...
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

% --- Executes just before setEtCO2GUI is made visible.
function setEtCO2GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setEtCO2GUI (see VARARGIN)

% Choose default command line output for setRRGUI
%handles.output = hObject;
assignin('base', 'EtCO2GUI', hObject);
checkAxes(hObject,1);
handles.thisGUI=hObject;

current=1;
switch length(varargin)
    case 1
        raterID=cell2mat(varargin{1});
        handles.parameters.dataset='default';
    case 2
        raterID=cell2mat(varargin{1});
        handles.menuFigure=varargin{2};
        handles.parameters.dataset='default';
    case 3
        raterID=cell2mat(varargin{1});
        handles.menuFigure=varargin{2};
        current=varargin{3};
        handles.parameters.dataset='default';
    case 4
        raterID=cell2mat(varargin{1});
        handles.menuFigure=varargin{2};
        current=varargin{3};
        handles.parameters.dataset=varargin{4};
    otherwise
        % for development %TODO remove
        raterID='r1000';
        handles.menuFigure=[];
        handles.parameters.dataset='default';
end
%if (varargin{1} == '')
if (strcmp(raterID,''))
    % no rater ID was set
else
    handles.parameters.raterID=raterID; %varargin{1};
    
    set(handles.editID,'String',raterID);
     set(handles.editDataset,'String',handles.parameters.dataset);
    % handles.parameters.ratingFolder=['output'];
    handles.parameters.ratingFolder=['data/' handles.parameters.dataset '/'];
    if (~isdir(handles.parameters.ratingFolder))
        mkdir(handles.parameters.ratingFolder);
    end
    
    % read the data directory
    [handles, counter]=readDataDir(hObject,eventdata,handles);
end



%init current
handles.current.output=[];

if(counter>1)
    handles.parameters.settingFile=['settings/setEtCO2' num2str(raterID) '.mat'];
    handles.data.current=current; % set pointer to first
    
    if current==1 %check for setting file
        if exist(handles.parameters.settingFile,'file')
            
            load (handles.parameters.settingFile)
            if (current<=counter)
                handles.data.current=current;
            end
            
        end
    end
    %set(handles.pushbuttonPrevious,'Enable','off');
    setVisibility(hObject, eventdata, handles)
    
    % Update handles structure
    guidata(hObject, handles);
    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using setEtCO2GUI.
    % if strcmp(get(hObject,'Visible'),'off')
    % initialize current handle structure by loading first data file
    [handles]=LoadandDisplay(hObject, eventdata, handles);
    
    [handles]=initZoomSlider(handles);
    %end
else
    set(handles.pushbuttonPrevious,'Enable','off');
    set(handles.pushbuttonNext,'Enable','off');
end

set(handles.uipanelMarkers,'Visible','off');
set(handles.pushbuttonSuggestion,'Enable','off');
set(handles.pushbuttonClearAllMarkers,'Enable','off');
set(handles.pushbuttonSave,'Enable','off');

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = setEtCO2GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = 'EtCO2GUI';





% --- Executes on button press in pushbuttonPrevious.
function pushbuttonPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%save current ratings
saveMarkerLabel(hObject, eventdata, handles);

%update current data pointer
handles.data.current=handles.data.current-1;


setVisibility(hObject, eventdata, handles);

%load previous data and ratings
%plot data and ratings
[handles]=LoadandDisplay(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%save current ratings
saveMarkerLabel(hObject, eventdata, handles);
%update current data pointer
handles.data.current=handles.data.current+1;



setVisibility(hObject, eventdata, handles);

%load next data and ratings
%plot data and ratings
[handles]=LoadandDisplay(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in pushbuttonCInsp.
function pushbuttonCInsp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCInsp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n1=CreateMarkerType(handles.setEtCO2GUI,'InspCO2');


% --- Executes on button press in pushbuttonCExp.
function pushbuttonCExp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%h=axes(handles.axesFlow);

n1=CreateMarkerType(handles.setEtCO2GUI,'EtCO2');
%SetCursorLocation(n1, 2.5);




% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveMarkerLabel(hObject, eventdata, handles);




function setVisibility(hObject, eventdata, handles)


set(handles.pushbuttonNext,'Enable','on');
set(handles.pushbuttonPrevious,'Enable','on');

if (handles.data.current >= length(handles.data.name))
    set(handles.pushbuttonNext,'Enable','off');
end
if (handles.data.current == 1)
    set(handles.pushbuttonPrevious,'Enable','off');
end



function clearAllMarkers(hObject, eventdata, handles)
Markers=getappdata(handles.setEtCO2GUI, 'VerticalMarkers');
for i=1:length(Markers)
    DeleteMarker(handles.setEtCO2GUI,i)
end
clear Markers;


function plotMarkers(hObject, eventdata, handles)
if get(handles.checkboxMarkers,'Value') %Markers enabled
    set(handles.uipanelNavigation,'Visible','off');
    if(isfield(handles.current,'output'))
        if(isfield(handles.current.output,'etco2'))
            for (i=1:length(handles.current.output.etco2.x))
                try            n=CreateMarkerType(handles.setEtCO2GUI,'EtCO2',handles.current.output.etco2.x(i)./handles.current.param.samplingrate.co2);
                catch end         % SetMarkerLocation(handles.setEtCO2GUI,n,handles.current.output.etco2.x(i)./handles.current.param.samplingrate,handles.current.data.co2.y(handles.current.output.etco2.x(i)));
            end
        end
        if(isfield(handles.current.output,'inspco2'))
            for (i=1:length(handles.current.output.inspco2.x))
                try     n=CreateMarkerType(handles.setEtCO2GUI,'InspCO2',handles.current.output.inspco2.x(i)./handles.current.param.samplingrate.co2);
                    % SetMarkerLocation(handles.setEtCO2GUI,n,handles.current.output.inspco2.x(i)./handles.current.param.samplingrate,handles.current.data.co2.y(handles.current.output.inspco2.x(i)))
                catch end
            end
        end
    end
    set(handles.uipanelNavigation,'Visible','on');
    
end

% --- Executes on button press in pushbuttonClearAllMarkers.
function pushbuttonClearAllMarkers_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearAllMarkers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg(['Are you sure you want to clear all markers?'],...
    ['Clear All Markers ...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end
clearAllMarkers(hObject, eventdata, handles);



% --- Executes on button press in pushbuttonSuggestion.
function pushbuttonSuggestion_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSuggestion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% TODO buffer for suggestion preview
% clear previous markers
clearAllMarkers(hObject, eventdata, handles);
%try
if isfield(handles.current,'output')
    range=handles.current.param.samplingrate.co2*0.8;%.0001; %0.5;half second window
    if isfield(handles.current.output,'startinsp')
        if isempty(handles.current.output.startinsp.x)
            handles.current.output.etco2.x=negZeroCrossing(handles.current.data.flow.y);
        else
            for i=1:length(handles.current.output.startinsp.x)
                [val idx]=max(handles.current.data.co2.y(round(max(handles.current.output.startinsp.x(i)-range,1)):round(min(handles.current.output.startinsp.x(i)+range,length(handles.current.data.co2.y)))));
                idx=idx+max(round(handles.current.output.startinsp.x(i)-range),1);
                handles.current.output.etco2.x(i)=idx;
            end
        end
    else
        handles.current.output.etco2.x=negZeroCrossing(handles.current.data.flow.y);
    end
    
    if isfield(handles.current.output,'startexp')
        if isempty(handles.current.output.startexp.x)
            handles.current.output.inspco2.x=posZeroCrossing(handles.current.data.flow.y);
        else
            for i=1:length(handles.current.output.startexp.x)
                [val idx]=min(handles.current.data.co2.y(round(max(1,handles.current.output.startexp.x(i)-range)):round(min(handles.current.output.startexp.x(i)+range,length(handles.current.data.co2.y)))));
                idx=idx+max(handles.current.output.startexp.x(i)-range,1);
                handles.current.output.inspco2.x(i)=idx;
            end
        end
    else
        handles.current.output.inspco2.x=posZeroCrossing(handles.current.data.flow.y);
    end
else
    handles.current.output.etco2.x=negZeroCrossing(handles.current.data.flow.y);
    handles.current.output.inspco2.x=posZeroCrossing(handles.current.data.flow.y);
end

% plot new suggestion
plotMarkers(hObject, eventdata, handles);

%catch
%end
% Update handles structure
guidata(hObject, handles);



function [handles]=LoadandDisplay(hObject, eventdata, handles)

%set(handles.uipanelNavigation, 'Enable','inactive');

% clears labels/markers
clearAllMarkers(hObject, eventdata, handles);

%loads new data
%handles.current=load(['data/' handles.data.name{handles.data.current}],'meta','data','param');
try
    load(['data/' handles.parameters.dataset '/' handles.data.name{handles.data.current} '_signal'],'data'); %load all data
catch
    load(['data/default'],'data');
end
try
    load(['data/' handles.parameters.dataset '/' handles.data.name{handles.data.current} '_meta'],'meta');
catch
    load(['data/default'],'meta');
end
try
    
    load(['data/' handles.parameters.dataset '/' handles.data.name{handles.data.current} '_param'],'param');
catch
    
    load(['data/default'],'param');
end
handles.current.data=data;
handles.current.param=param;
handles.current.meta=meta;



%set(handles.signalTitleText,'String',handles.data.name{handles.data.current});
set(handles.setEtCO2GUI,'Name',['1.2 Set EtCO2 and InspCO2: ' handles.data.name{handles.data.current}]);
set(handles.popupmenuJump,'Value',handles.data.current);

%axes(handles.axesCapnogram);
%cla
plot(handles.axesCapnogram,(1:length(handles.current.data.co2.y))./handles.current.param.samplingrate.co2,handles.current.data.co2.y,'k','Tag','CO2');
axis tight

grid on
ylabel(['pCO2 [' handles.current.meta.sensor.co2.units ']'],'Rotation',90)
xlabel(['seconds'])

set(handles.sliderZoom,'Enable','off');
set(handles.popupmenuZoom,'Value',1);
outputfile=[handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_output.mat'];

%loads the saved output if already stored
if (exist(outputfile,'file')>0)
    tmp=load(outputfile);
    handles.current.output=tmp.output;
    
    plotMarkers(hObject, eventdata, handles)
    
end

current=handles.data.current;
save(handles.parameters.settingFile,'current');

% set(handles.uipanelNavigation, 'Enable','on');
% Update handles structure
%guidata(hObject, handles);






% --- Executes on button press in pushbuttonReset.
function pushbuttonReset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg(['Are you sure you want to reset all markers to saved positions?'],...
    ['Reset Markers ...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end
[handles]=LoadandDisplay(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);



% --- Executes on selection change in popupmenuJump.
function popupmenuJump_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuJump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuJump contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuJump


handles.data.current=get(hObject,'Value');
% Update handles structure
guidata(hObject, handles);

setVisibility(hObject, eventdata, handles);
%resetGUI(hObject, eventdata, handles);
%load next data and ratings
%plot data and ratings
[handles]=LoadandDisplay(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);





% --- Executes on button press in checkboxMarkers.
function checkboxMarkers_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxMarkers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxMarkers
value=get(hObject,'Value');
if value
    set(handles.uipanelMarkers,'Visible','on');
    set(handles.pushbuttonSuggestion,'Enable','on');
    set(handles.pushbuttonClearAllMarkers,'Enable','on');
    set(handles.pushbuttonSave,'Enable','on');
    outputfile=[handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_output.mat'];
    if (exist(outputfile,'file')>0)
        tmp=load(outputfile);
        handles.current.output=tmp.output;
        plotMarkers(hObject, eventdata, handles)
    end
else
    
    selection = questdlg(['No markers will be saved when markers disabled. If you changed the markers position since the last saving they will be lost.'],...
        ['No Markers ...'],'OK','Cancel','OK');
    if strcmp(selection,'OK')
        set(handles.uipanelMarkers,'Visible','off');
        set(handles.pushbuttonSuggestion,'Enable','off');
        set(handles.pushbuttonClearAllMarkers,'Enable','off');
        set(handles.pushbuttonSave,'Enable','off');
        clearAllMarkers(hObject, eventdata, handles);
    else
        set(hObject,'Value',1);
        
    end
end



function editDataset_Callback(hObject, eventdata, handles)
% hObject    handle to editDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDataset as text
%        str2double(get(hObject,'String')) returns contents of editDataset as a double


% --- Executes during object creation, after setting all properties.
function editDataset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
