function varargout = ratingGUI(varargin)
% RATINGGUI M-file for ratingGUI.fig
%      RATINGGUI, by itself, creates a new RATINGGUI or raises the existing
%      singleton*.
%
%      H = RATINGGUI returns the handle to a new RATINGGUI or the handle to
%      the existing singleton*.
%
%      RATINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RATINGGUI.M with the given input arguments.
%
%      RATINGGUI('Property','Value',...) creates a new RATINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ratingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ratingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ratingGUI

% Last Modified by GUIDE v2.5 19-Feb-2010 15:20:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ratingGUI_OpeningFcn, ...
    'gui_OutputFcn',  @ratingGUI_OutputFcn, ...
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

% --- Executes just before ratingGUI is made visible.
function ratingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ratingGUI (see VARARGIN)

% Choose default command line output for setRRGUI
%handles.output = hObject;
assignin('base', 'rGUI', hObject);
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
    return
else
    handles.parameters.raterID=raterID; %varargin{1};
    
    set(handles.editID,'String',raterID);
     set(handles.editDataset,'String',handles.parameters.dataset);
    %handles.parameters.ratingFolder=['ratings/' num2str(raterID)];
    handles.parameters.ratingFolder=['data/' handles.parameters.dataset '/'];
    % handles.parameters.ratingFolder=['data/'];
    if (~isdir(handles.parameters.ratingFolder))
        mkdir(handles.parameters.ratingFolder);
    end
    
    [handles, counter]=readDataDir(hObject,eventdata,handles);
end

if(counter>1)
    handles.parameters.settingFile=['settings/setRating' num2str(raterID) '.mat'];
    handles.data.current=current; % set pointer to first
    
    if current==1 %check for setting file
        if exist(handles.parameters.settingFile,'file')
            
            load (handles.parameters.settingFile)
            if (current<=counter)
                handles.data.current=current;
            end
            
        end
    end
    setVisibility(hObject, eventdata, handles);
    
    
    %     % Update handles structure
    %     guidata(hObject, handles);
    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using setRRGUI.
    %if strcmp(get(hObject,'Visible'),'off')
    % initialize current handle structure by loading first data file
    [handles]=LoadandDisplay(handles);
    
    %init slider
    [handles]=initZoomSlider(handles);
    %end
else
    set(handles.pushbuttonPrevious,'Enable','off');
    set(handles.pushbuttonNext,'Enable','off');
end
set(handles.etco2_buttongroup,'SelectionChangeFcn',@etco2_buttongroup_SelectionChangeFcn);
set(handles.inspco2_buttongroup,'SelectionChangeFcn',@inspco2_buttongroup_SelectionChangeFcn);
set(handles.rr_buttongroup,'SelectionChangeFcn',@rr_buttongroup_SelectionChangeFcn);

% save the changes to the structure
guidata(hObject,handles)




% --- Outputs from this function are returned to the command line.
function varargout = ratingGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = 'Rating';



% --- Executes on button press in pushbuttonPrevious.
function pushbuttonPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%save current ratings
err=saveRating(handles);
if err==0
    %update current data pointer
    handles.data.current=handles.data.current-1;
    % Update handles structure
    %guidata(hObject, handles);
    
    setVisibility(hObject, eventdata, handles);
    resetGUI(hObject, eventdata, handles);
    %load next data and ratings
    %plot data and ratings
    [handles]=LoadandDisplay(handles);
else
    popupError(err);
end

% save the changes to the structure
guidata(hObject,handles)


% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%save current ratings
err=saveRating(handles);
if err==0
    %update current data pointer
    handles.data.current=handles.data.current+1;
    % Update handles structure
    guidata(hObject, handles);
    
    setVisibility(hObject, eventdata, handles);
    resetGUI(hObject, eventdata, handles);
    %load next data and ratings
    %plot data and ratings
    [handles]=LoadandDisplay(handles);
else
    popupError(err);
end
% save the changes to the structure
guidata(hObject,handles)


% --- Executes on button press in pushbuttonAddCursorEvent.
function pushbuttonAddCursorEvent_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddCursorEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

n1=CreateCursorType(handles.ratingGUI,'Event');

% strfnames=fieldnames(handles);
% idx = strncmp(strfnames', 'edit', 4);
%
% for k=find(idx)
%
%     if strcmp(get(handles.(strfnames{k}),'Selected'),'on')
%         set(handles.(strfnames{k}),'String',num2str(n1));
%     end
% end



function setVisibility(hObject, eventdata, handles)


set(handles.pushbuttonNext,'Enable','on');
set(handles.pushbuttonPrevious,'Enable','on');

if (handles.data.current >= length(handles.data.name))
    set(handles.pushbuttonNext,'Enable','off');
end
if (handles.data.current == 1)
    set(handles.pushbuttonPrevious,'Enable','off');
end

function [handles]=LoadandDisplay(handles)

%set(handles.uipanelNavigation, 'Enable','inactive');

% clears labels/cursors
[handles]=clearAllMarkers(handles);

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
set(handles.ratingGUI,'Name',['2.1 Rate Trends and Events: ' handles.data.name{handles.data.current}]);
set(handles.popupmenuJump,'Value',handles.data.current);

axes(handles.axesCapnogram);
cla;
plot((1:length(handles.current.data.co2.y))./handles.current.param.samplingrate.co2,handles.current.data.co2.y,'k','Tag','CO2');
axis tight
ylabel(['pCO2 [' handles.current.meta.sensor.co2.units ']'],'Rotation',90)
xlabel(['seconds'])

%     axes(handles.axesFlow);
%      cla;
%     plot((1:length(handles.current.data.flow.y))./handles.current.param.samplingrate,handles.current.data.flow.y,'k');
%      axis tight
grid on

% init ratings
handles.current.rating.events=[];
handles.current.rating.quality=[];

% set demographics
fields=fieldnames(handles.current.meta.subject);
for i=1:length(fields)
    textfield{i}=[fields{i} ':  ' getfield(handles.current.meta.subject,fields{i}) ' '];
end
fields=fieldnames(handles.current.meta.treatment);
for k=i+1:i+length(fields)
    textfield{k}=[fields{k-i} ':  ' getfield(handles.current.meta.treatment,fields{k-i}) ' '];
end
%set(handles.textDemographics, 'Interpreter', 'latex')
set(handles.textDemographics, 'String', textfield);

[handles]=loadRating(handles);


% set(handles.uipanelNavigation, 'Enable','on');
% Update handles structure
%guidata(hObject, handles);


function [handles]=clearAllMarkers(handles)
Cursors=getappdata(handles.ratingGUI, 'VerticalCursors');
for i=1:length(Cursors)
    DeleteCursor(handles.ratingGUI,i);
end
clear Cursors;


function [handles]=plotMarkers(handles)
set(handles.uipanelNavigation,'Visible','off');
if(isfield(handles.current,'output'))
    if(isfield(handles.current.output,'etco2'))
        for (i=1:length(handles.current.output.etco2.x))
            n=CreateMarkerType(handles.ratingGUI,'EtCO2',handles.current.output.etco2.x(i)./handles.current.param.samplingrate.co2);
            % SetMarkerLocation(handles.ratingGUI,n,handles.current.output.etco2.x(i)./handles.current.param.samplingrate,handles.current.data.co2.y(handles.current.output.etco2.x(i)));
        end
    end
    if(isfield(handles.current.output,'inspco2'))
        for (i=1:length(handles.current.output.inspco2.x))
            n=CreateMarkerType(handles.ratingGUI,'InspCO2',handles.current.output.inspco2.x(i)./handles.current.param.samplingrate.co2);
            % SetMarkerLocation(handles.ratingGUI,n,handles.current.output.inspco2.x(i)./handles.current.param.samplingrate,handles.current.data.co2.y(handles.current.output.inspco2.x(i)))
        end
    end
end
set(handles.uipanelNavigation,'Visible','on');




function [handles]=loadRating(handles)

outputfile=[handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_rating.mat'];

%loads the saved output if already stored
if (exist(outputfile,'file')>0)
    tmp=load(outputfile,'rating');
    handles.current.rating=tmp.rating;
    if isfield(handles.current.rating,'comment')
        set(handles.editRaterComment,'String',handles.current.rating.comment);
    end
    
    if isfield(handles.current.rating,'review')
        set(handles.checkboxReview,'Value',handles.current.rating.review);
    end
    
    if isfield(handles.current.rating,'trend')
        if isstruct(handles.current.rating.trend)
            trendFields=fieldnames(handles.current.rating.trend);
            for i=1:length(trendFields)
                try
                    set(handles.(['radiobuttonTrend_' trendFields{i} '_' num2str(handles.current.rating.trend.(trendFields{i}))]),'Value',1);
                catch
                end
            end
        end
    end
    
    if isfield(handles.current.rating,'events')
        if isstruct(handles.current.rating.events)
            eventFields=fieldnames(handles.current.rating.events);
            counter=1;
            for i=1:length(eventFields)
                
                
                for m=1:handles.current.rating.events.(eventFields{i}).present %>0
                    namefields = regexp(eventFields{i}, '_', 'split');
                    
                    id=namefields{2};
                    set(handles.(['popupmenuEventSelect_'  num2str(counter)]),'Value',str2num(id));
                    minCursor=CreateCursorType(handles.ratingGUI,'Event');
                    %TODO set multiple ranges for same event,
                    
                    SetCursorLocation(minCursor,handles.current.rating.events.(eventFields{i}).range(m,1));
                    maxCursor=CreateCursorType(handles.ratingGUI,'Event');
                    SetCursorLocation(maxCursor,handles.current.rating.events.(eventFields{i}).range(m,2));
                    try
                        set(handles.(['editEvent_' num2str(counter) '_Max']),'String',maxCursor);
                        set(handles.(['editEvent_'  num2str(counter) '_Min']),'String',minCursor);
                        set(handles.(['editEvent_'  num2str(counter) '_Max']),'Enable','on');
                        set(handles.(['editEvent_'  num2str(counter) '_Min']),'Enable','on');
                    catch
                        disp('Warning: Could not load on of the event assessments.')
                    end
                    counter=counter+1;
                end
            end
        end
    end
    if isfield(handles.current.rating,'quality')
        if isstruct(handles.current.rating.quality)
            qualityFields=fieldnames(handles.current.rating.quality);
            counter=1;
            for i=1:length(qualityFields)
                
                
                for m=1: handles.current.rating.quality.(qualityFields{i}).present %>0
                    namefields = regexp(qualityFields{i}, '_', 'split');
                    
                    id=namefields{2};
                    set(handles.(['popupmenuQualitySelect_'  num2str(counter)]),'Value',str2num(id));
                    minCursor=CreateCursorType(handles.ratingGUI,'Quality');
                    %TODO set multiple ranges for same event,
                    
                    SetCursorLocation(minCursor,handles.current.rating.quality.(qualityFields{i}).range(m,1));
                    maxCursor=CreateCursorType(handles.ratingGUI,'Quality');
                    SetCursorLocation(maxCursor,handles.current.rating.quality.(qualityFields{i}).range(m,2));
                    try
                        set(handles.(['editQuality_' num2str(counter) '_Max']),'String',maxCursor);
                        set(handles.(['editQuality_'  num2str(counter) '_Min']),'String',minCursor);
                        set(handles.(['editQuality_'  num2str(counter) '_Max']),'Enable','on');
                        set(handles.(['editQuality_'  num2str(counter) '_Min']),'Enable','on');
                    catch
                        disp('Warning: Could not load one of the quality assessments.')
                    end
                    counter=counter+1;
                end
            end
        end
    end
    
    
% else
%     XLim=get(gca,'XLim');
%     n1=CreateCursorType(handles.ratingGUI,'Quality');
%     SetCursorLocation(n1,XLim(1));
%     n2=CreateCursorType(handles.ratingGUI,'Quality');
%     SetCursorLocation(n2, XLim(2));
%     set(handles.(['editQuality_1_Max']),'Enable','on','String',num2str(n2));
%     set(handles.(['editQuality_1_Min']),'Enable','on','String',num2str(n1));
end

%updates the handles structure
%guidata(hObject, handles);



function etco2_buttongroup_SelectionChangeFcn(hObject, eventdata)

%retrieve GUI data, i.e. the handles structure
handles = guidata(hObject);

switch get(eventdata.NewValue,'String')   % Get Tag of selected object
    case 'Rising'
        %execute this code when fontsize08_radiobutton is selected
        handles.current.rating.trend.etco2=1;
        
    case 'Falling'
        %execute this code when fontsize12_radiobutton is selected
        handles.current.rating.trend.etco2=2;
        
    case 'Constant'
        %execute this code when fontsize16_radiobutton is selected
        handles.current.rating.trend.etco2=0;
    case 'Inconsistent'
        %execute this code when fontsize16_radiobutton is selected
        handles.current.rating.trend.etco2=3;
    otherwise
        % Code for when there is no match.
        
end
%updates the handles structure
guidata(hObject, handles);

function rr_buttongroup_SelectionChangeFcn(hObject, eventdata)

%retrieve GUI data, i.e. the handles structure
handles = guidata(hObject);

switch get(eventdata.NewValue,'String')   % Get Tag of selected object
    case 'Rising'
        %execute this code when fontsize08_radiobutton is selected
        handles.current.rating.trend.rr=1;
        
    case 'Falling'
        %execute this code when fontsize12_radiobutton is selected
        handles.current.rating.trend.rr=2;
        
    case 'Constant'
        %execute this code when fontsize16_radiobutton is selected
        handles.current.rating.trend.rr=0;
    case 'Inconsistent'
        %execute this code when fontsize16_radiobutton is selected
        handles.current.rating.trend.rr=3;
    otherwise
        % Code for when there is no match.
        
end
%updates the handles structure
guidata(hObject, handles);

function inspco2_buttongroup_SelectionChangeFcn(hObject, eventdata)

%retrieve GUI data, i.e. the handles structure
handles = guidata(hObject);

switch get(eventdata.NewValue,'String')   % Get Tag of selected object
    case 'Rising'
        %execute this code when fontsize08_radiobutton is selected
        handles.current.rating.trend.inspco2=1;
        
    case 'Falling'
        %execute this code when fontsize12_radiobutton is selected
        handles.current.rating.trend.inspco2=2;
        
    case 'Constant High'
        %execute this code when fontsize16_radiobutton is selected
        handles.current.rating.trend.inspco2=3;
    case 'Constant Low'
        %execute this code when fontsize16_radiobutton is selected
        handles.current.rating.trend.inspco2=4;
    case 'Constant Zero'
        %execute this code when fontsize16_radiobutton is selected
        handles.current.rating.trend.inspco2=0;
    otherwise
        % Code for when there is no match.
        
end
%updates the handles structure
guidata(hObject, handles);

function resetGUI(hObject, eventdata, handles)

%fields={'CO','Reg','curare','hypovent','hypervent','obstructive','cardiacoutput','other','rebreathing','leak','deadspace'};

for i=1:7 %length(fields)
    
    %identifier=fields{i};
    set(handles.(['editEvent_' num2str(i) '_Min']),'String','');
    set(handles.(['editEvent_' num2str(i) '_Max']),'String','');
    
    set(handles.(['popupmenuEventSelect_' num2str(i)]),'Value',1);
    
    [handles]=changeEventState(handles.(['popupmenuEventSelect_' num2str(i)]), eventdata, handles);
    
end




for i=1:3 %length(fields)
    
    %identifier=fields{i};
    set(handles.(['editQuality_' num2str(i) '_Min']),'String','');
    set(handles.(['editQuality_' num2str(i) '_Max']),'String','');
    
    set(handles.(['popupmenuQualitySelect_' num2str(i)]),'Value',1);
    
    [handles]=changeQualityState(handles.(['popupmenuQualitySelect_' num2str(i)]), eventdata, handles);
    
end
set(handles.(['popupmenuQualitySelect_1']),'Value',1);

set(handles.(['radiobuttonTrend_etco2_0']),'Value',1);
set(handles.(['radiobuttonTrend_rr_0']),'Value',1);
set(handles.(['radiobuttonTrend_inspco2_0']),'Value',1);
set(handles.textDemographics, 'String', '');
set(handles.editRaterComment,'String','');
set(handles.checkboxReview,'Value',0);

set(handles.sliderZoom,'Enable','off');
set(handles.popupmenuZoom,'Value',1);
% save the changes to the structure
guidata(hObject,handles)





function editRaterComment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRaterComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function editID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function editEvent_2_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_2_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');


% --- Executes during object creation, after setting all properties.
function editEvent_2_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_2_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');



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
resetGUI(hObject, eventdata, handles);
%load next data and ratings
%plot data and ratings
[handles]=LoadandDisplay(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenuJump_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuJump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
err=saveRating(handles);
if err~=0
    popupError(err);
end
% save the changes to the structure
guidata(hObject,handles)








% --- Executes on key press with focus on editEvent_2_Min and none of its controls.
function edit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_2_Min (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
tag=get(hObject,'Tag');
namefields = regexp(tag, 'Quality');


switch (eventdata.Key)
    case 'space'
        if isempty(namefields)
            n1=CreateCursorType(handles.ratingGUI,'Event');
        else
            n1=CreateCursorType(handles.ratingGUI,'Quality');
        end
        set(hObject, 'String', n1)
    case {'1','2','3','4','5','6','7','8','9','0'}
        %    set(hObject, 'String', eventdata.Key)
    otherwise
        set(hObject, 'String', '')
end


% --- Executes during object creation, after setting all properties.
function textDemographics_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textDemographics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function popupmenuEventSelect_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEvent_2_Min_Callback(hObject, eventdata, handles)
% hObject    handle to editEvent_2_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvent_2_Min as text
%        str2double(get(hObject,'String')) returns contents of editEvent_2_Min as a double



function editEvent_2_Max_Callback(hObject, eventdata, handles)
% hObject    handle to editEvent_2_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvent_2_Max as text
%        str2double(get(hObject,'String')) returns contents of editEvent_2_Max as a double



function editEvent_7_Max_Callback(hObject, eventdata, handles)
% hObject    handle to editEvent_7_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvent_7_Max as text
%        str2double(get(hObject,'String')) returns contents of editEvent_7_Max as a double


% --- Executes during object creation, after setting all properties.
function editEvent_7_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_7_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');

% --- Executes on selection change in popupmenuEventSelect_7.
function popupmenuEventSelect_7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuEventSelect_7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuEventSelect_7


% --- Executes during object creation, after setting all properties.
function popupmenuEventSelect_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEvent_7_Min_Callback(hObject, eventdata, handles)
% hObject    handle to editEvent_7_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvent_7_Min as text
%        str2double(get(hObject,'String')) returns contents of editEvent_7_Min as a double


% --- Executes during object creation, after setting all properties.
function editEvent_7_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_7_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');


function editEvent_6_Max_Callback(hObject, eventdata, handles)
% hObject    handle to editEvent_6_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvent_6_Max as text
%        str2double(get(hObject,'String')) returns contents of editEvent_6_Max as a double


% --- Executes during object creation, after setting all properties.
function editEvent_6_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_6_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');

% --- Executes on selection change in popupmenuEventSelect_6.
function popupmenuEventSelect_6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuEventSelect_6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuEventSelect_6


% --- Executes during object creation, after setting all properties.
function popupmenuEventSelect_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEvent_6_Min_Callback(hObject, eventdata, handles)
% hObject    handle to editEvent_6_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvent_6_Min as text
%        str2double(get(hObject,'String')) returns contents of editEvent_6_Min as a double


% --- Executes during object creation, after setting all properties.
function editEvent_6_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_6_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');


function editEvent_5_Max_Callback(hObject, eventdata, handles)
% hObject    handle to editEvent_5_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvent_5_Max as text
%        str2double(get(hObject,'String')) returns contents of editEvent_5_Max as a double


% --- Executes during object creation, after setting all properties.
function editEvent_5_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_5_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');

% --- Executes on selection change in popupmenuEventSelect_5.
function popupmenuEventSelect_5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuEventSelect_5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuEventSelect_5


% --- Executes during object creation, after setting all properties.
function popupmenuEventSelect_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEvent_5_Min_Callback(hObject, eventdata, handles)
% hObject    handle to editEvent_5_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvent_5_Min as text
%        str2double(get(hObject,'String')) returns contents of editEvent_5_Min as a double
set(hObject,'String','');

% --- Executes during object creation, after setting all properties.
function editEvent_5_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_5_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');


function editEvent_4_Max_Callback(hObject, eventdata, handles)
% hObject    handle to editEvent_4_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvent_4_Max as text
%        str2double(get(hObject,'String')) returns contents of editEvent_4_Max as a double


% --- Executes during object creation, after setting all properties.
function editEvent_4_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_4_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');

% --- Executes on selection change in popupmenuEventSelect_4.
function popupmenuEventSelect_4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuEventSelect_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuEventSelect_4


% --- Executes during object creation, after setting all properties.
function popupmenuEventSelect_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEvent_4_Min_Callback(hObject, eventdata, handles)
% hObject    handle to editEvent_4_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvent_4_Min as text
%        str2double(get(hObject,'String')) returns contents of editEvent_4_Min as a double
set(hObject,'String','');

% --- Executes during object creation, after setting all properties.
function editEvent_4_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_4_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');


function editEvent_3_Min_Callback(hObject, eventdata, handles)
% hObject    handle to editEvent_3_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvent_3_Min as text
%        str2double(get(hObject,'String')) returns contents of editEvent_3_Min as a double


% --- Executes during object creation, after setting all properties.
function editEvent_3_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_3_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');

% --- Executes on selection change in popupmenuEventSelect_3.
function popupmenuEventSelect_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuEventSelect_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuEventSelect_3
[handles]=changeEventState(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in popupmenuEventSelect_3.
function popupmenuQualitySelect_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuEventSelect_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuEventSelect_3
[handles]=changeQualityState(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);

function [handles]=changeEventState(hObject, eventdata, handles)


value=get(hObject,'Value');
tag=get(hObject,'Tag');

%identifier=strrep(tag, 'checkbox_','');
namefields = regexp(tag, '_', 'split');

id=namefields{2};

if value >1
    
    set(handles.(['editEvent_' id '_Min']),'Enable','on');
    set(handles.(['editEvent_' id '_Max']),'Enable','on');
    % handles.current.rating.events.(identifier).present=1;
    
else
    set(handles.(['editEvent_' id '_Min']),'Enable','off');
    set(handles.(['editEvent_' id '_Max']),'Enable','off');
    % handles.current.rating.events.(identifier).present=0;
end
% Update handles structure
%guidata(hObject, handles);

function [handles]=changeQualityState(hObject, eventdata, handles)


value=get(hObject,'Value');
tag=get(hObject,'Tag');

%identifier=strrep(tag, 'checkbox_','');
namefields = regexp(tag, '_', 'split');

id=namefields{2};

if value >1
    
    set(handles.(['editQuality_' id '_Min']),'Enable','on');
    set(handles.(['editQuality_' id '_Max']),'Enable','on');
    % handles.current.rating.events.(identifier).present=1;
    
else
    set(handles.(['editQuality_' id '_Min']),'Enable','off');
    set(handles.(['editQuality_' id '_Max']),'Enable','off');
    % handles.current.rating.events.(identifier).present=0;
end


% --- Executes during object creation, after setting all properties.
function popupmenuEventSelect_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEvent_3_Max_Callback(hObject, eventdata, handles)
% hObject    handle to editEvent_3_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvent_3_Max as text
%        str2double(get(hObject,'String')) returns contents of editEvent_3_Max as a double


% --- Executes during object creation, after setting all properties.
function editEvent_3_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_3_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');

% --- Executes during object creation, after setting all properties.
function editEvent_1_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_1_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');



% --- Executes during object creation, after setting all properties.
function popupmenuEventSelect_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuEventSelect_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editEvent_1_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvent_1_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');

% --- Executes on button press in pushbuttonAddCursorQuality.
function pushbuttonAddCursorQuality_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddCursorQuality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n1=CreateCursorType(handles.ratingGUI,'Quality');


function editQuality_2_Max_Callback(hObject, eventdata, handles)
% hObject    handle to editQuality_2_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQuality_2_Max as text
%        str2double(get(hObject,'String')) returns contents of editQuality_2_Max as a double


% --- Executes during object creation, after setting all properties.
function editQuality_2_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQuality_2_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQuality_2_Min_Callback(hObject, eventdata, handles)
% hObject    handle to editQuality_2_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQuality_2_Min as text
%        str2double(get(hObject,'String')) returns contents of editQuality_2_Min as a double


% --- Executes during object creation, after setting all properties.
function editQuality_2_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQuality_2_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuQualitySelect_2.
function popupmenuQualitySelect_2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuQualitySelect_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuQualitySelect_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuQualitySelect_2


% --- Executes during object creation, after setting all properties.
function popupmenuQualitySelect_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuQualitySelect_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQuality_3_Min_Callback(hObject, eventdata, handles)
% hObject    handle to editQuality_3_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQuality_3_Min as text
%        str2double(get(hObject,'String')) returns contents of editQuality_3_Min as a double


% --- Executes during object creation, after setting all properties.
function editQuality_3_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQuality_3_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQuality_3_Max_Callback(hObject, eventdata, handles)
% hObject    handle to editQuality_3_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQuality_3_Max as text
%        str2double(get(hObject,'String')) returns contents of editQuality_3_Max as a double


% --- Executes during object creation, after setting all properties.
function editQuality_3_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQuality_3_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuQualitySelect_3.
function popupmenuQualitySelect_3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuQualitySelect_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuQualitySelect_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuQualitySelect_3


% --- Executes during object creation, after setting all properties.
function popupmenuQualitySelect_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuQualitySelect_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQuality_1_Min_Callback(hObject, eventdata, handles)
% hObject    handle to editQuality_1_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQuality_1_Min as text
%        str2double(get(hObject,'String')) returns contents of editQuality_1_Min as a double


% --- Executes during object creation, after setting all properties.
function editQuality_1_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQuality_1_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQuality_1_Max_Callback(hObject, eventdata, handles)
% hObject    handle to editQuality_1_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQuality_1_Max as text
%        str2double(get(hObject,'String')) returns contents of editQuality_1_Max as a double


% --- Executes during object creation, after setting all properties.
function editQuality_1_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQuality_1_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuQualitySelect_1.
function popupmenuQualitySelect_1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuQualitySelect_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuQualitySelect_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuQualitySelect_1


% --- Executes during object creation, after setting all properties.
function popupmenuQualitySelect_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuQualitySelect_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on editQuality_1_Min and none of its controls.
function editQuality_1_Min_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editQuality_1_Min (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on editQuality_1_Max and none of its controls.
function editQuality_1_Max_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editQuality_1_Max (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on editQuality_2_Min and none of its controls.
function editQuality_2_Min_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editQuality_2_Min (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on editQuality_2_Max and none of its controls.
function editQuality_2_Max_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editQuality_2_Max (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on editQuality_3_Min and none of its controls.
function editQuality_3_Min_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editQuality_3_Min (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on editQuality_3_Max and none of its controls.
function editQuality_3_Max_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editQuality_3_Max (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkboxReview.
function checkboxReview_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxReview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxReview
handles.current.rating.review=get(hObject,'Value');
% Update handles structure
guidata(hObject, handles);



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
