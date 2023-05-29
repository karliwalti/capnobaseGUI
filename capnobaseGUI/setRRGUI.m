function varargout = setRRGUI(varargin)
% SETRRGUI M-file for setRRGUI.fig
%      SETRRGUI, by itself, creates a new SETRRGUI or raises the existing
%      singleton*.
%
%      H = SETRRGUI returns the handle to a new SETRRGUI or the handle to
%      the existing singleton*.
%
%      SETRRGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETRRGUI.M with the given input arguments.
%
%      SETRRGUI('Property','Value',...) creates a new SETRRGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setRRGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setRRGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setRRGUI

% Last Modified by GUIDE v2.5 19-Feb-2010 15:16:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @setRRGUI_OpeningFcn, ...
    'gui_OutputFcn',  @setRRGUI_OutputFcn, ...
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

% --- Executes just before setRRGUI is made visible.
function setRRGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setRRGUI (see VARARGIN)

% Choose default command line output for setRRGUI
run configure.m

%handles.output = hObject;
assignin('base', 'RRGUI', hObject);
current=1;
checkAxes(hObject,2);
handles.thisGUI=hObject;
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
    %handles.parameters.ratingFolder=['output'];
    handles.parameters.ratingFolder=[conf.data.rootfolder filesep handles.parameters.dataset filesep];
    
    if (~isdir(handles.parameters.ratingFolder))
        mkdir(handles.parameters.ratingFolder);
    end
    
    % read the data directory
    [handles, counter]=readDataDir(hObject,eventdata,handles);
end

if(counter>1)
    handles.parameters.settingFile=['settings/setRR' num2str(raterID) '.mat'];
    
    handles.data.current=current; % set pointer to first
    
    if current==1 %check for setting file
        if exist(handles.parameters.settingFile,'file')
            
            load (handles.parameters.settingFile)
            if (current<=counter)
                handles.data.current=current;
            end
            
        end
    end
    
    
    handles=setVisibility(hObject, eventdata, handles);
    
    handles.parameter.suggestion=0;
    % Update handles structure
    guidata(hObject, handles);
    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using setRRGUI.
    % if strcmp(get(hObject,'Visible'),'off')
    % initialize current handle structure by loading first data file
    [handles]=LoadandDisplay(hObject, eventdata, handles);
    
    [handles]=initZoomSlider(handles);
    %end
else
    set(handles.pushbuttonPrevious,'Enable','off');
    set(handles.pushbuttonNext,'Enable','off');
end

set(handles.uipanelLabels,'Visible','off');
set(handles.uipanelLabeltools,'Visible','off');
set(handles.pushbuttonSave,'Enable','off');

% UIWAIT makes setRRGUI wait for user response (see UIRESUME)
% uiwait(handles.setRRGUI);
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = setRRGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = 'RRGUI';



% --- Executes on button press in pushbuttonPrevious.
function pushbuttonPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%save current ratings
saveCursorLabel(hObject, eventdata, handles);

%update current data pointer
handles.data.current=handles.data.current-1;
% Update handles structure
guidata(hObject, handles);

[handles]=setVisibility(hObject, eventdata, handles);

%load previous data and ratings
%plot data and ratings
[handles]=LoadandDisplay(hObject, eventdata, handles);
[handles]=setVisibility(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%save current ratings
saveCursorLabel(hObject, eventdata, handles);
%update current data pointer
handles.data.current=handles.data.current+1;
% Update handles structure
guidata(hObject, handles);

[handles]=setVisibility(hObject, eventdata, handles);

%load next data and ratings
%plot data and ratings
[handles]=LoadandDisplay(hObject, eventdata, handles);
[handles]=setVisibility(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in pushbuttonCInsp.
function pushbuttonCInsp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCInsp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n1=CreateCursorType(handles.setRRGUI,'Insp');


% --- Executes on button press in pushbuttonCExp.
function pushbuttonCExp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%h=axes(handles.axesFlow);

n1=CreateCursorType(handles.setRRGUI,'Exp');
%SetCursorLocation(n1, 2.5);



function editDCursorNumber_Callback(hObject, eventdata, handles)
% hObject    handle to editDCursorNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDCursorNumber as text
%        str2double(get(hObject,'String')) returns contents of editDCursorNumber as a double


% --- Executes during object creation, after setting all properties.
function editDCursorNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDCursorNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');

% --- Executes on button press in pushbuttonCDelete.
function pushbuttonCDelete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DeleteCursor(str2double(get(handles.editDCursorNumber,'String')));

function [handles]=LoadandDisplay(hObject, eventdata, handles)

run configure.m

% clears labels/cursors
clearAllCursors(hObject, eventdata, handles);

%loads new data
%handles.current=load([conf.data.rootfolder filesep handles.data.name{handles.data.current}],'meta','data','param');
try
    load([conf.data.rootfolder filesep handles.parameters.dataset filesep handles.data.name{handles.data.current} '_signal'],'data'); %load all data
catch
    load(['data' filesep 'default'],'data');
    data.flow.y=data.flow.y-2;
end
try
    load([conf.data.rootfolder filesep handles.parameters.dataset filesep handles.data.name{handles.data.current} '_meta'],'meta');
catch
    load(['data' filesep 'default'],'meta');
end
try
    
    load([conf.data.rootfolder filesep handles.parameters.dataset filesep handles.data.name{handles.data.current} '_param'],'param');
catch
    
    load(['data' filesep 'default'],'param');
end
handles.current.data=data;
handles.current.param=param;
handles.current.meta=meta;


%set(handles.signalTitleText,'String',handles.data.name{handles.data.current});
set(handles.setRRGUI,'Name',['1.1 Set Insp and Exp: ' handles.data.name{handles.data.current}]);
set(handles.popupmenuJump,'Value',handles.data.current);

axes(handles.axesCapnogram);
cla(handles.axesCapnogram);
plot(handles.axesCapnogram,(1:length(handles.current.data.co2.y))./handles.current.param.samplingrate.co2,handles.current.data.co2.y,'k','Tag','CO2');
axis tight
ylabel(['pCO2 [' handles.current.meta.sensor.co2.units ']'],'Rotation',90)
xlabel(['seconds'])
axes(handles.axesFlow);
cla(handles.axesFlow);
plot(handles.axesFlow,(1:length(handles.current.data.flow.y))./handles.current.param.samplingrate.flow,handles.current.data.flow.y,'k');
axis tight
grid on
ylabel(['Flow  [' handles.current.meta.sensor.flow.units ']'],'Rotation',90)
xlabel(['seconds'])


set(handles.sliderZoom,'Enable','off');
set(handles.popupmenuZoom,'Value',1);
%set current axis
axes(handles.axesCapnogram);
outputfile=[handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_output.mat'];
%loads the saved output if already stored
if (exist(outputfile,'file')>0)
    tmp=load(outputfile);
    handles.current.output=tmp.output;
    
    plotCursors(hObject, eventdata, handles);
    
end

current=handles.data.current;
save(handles.parameters.settingFile,'current');

% % Update handles structure
% guidata(hObject, handles);





function editID_Callback(hObject, eventdata, handles)
% hObject    handle to editID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editID as text
%        str2double(get(hObject,'String')) returns contents of editID as a double


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


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveCursorLabel(hObject, eventdata, handles);




function [handles]=setVisibility(hObject, eventdata, handles)


set(handles.pushbuttonNext,'Enable','on');
set(handles.pushbuttonPrevious,'Enable','on');

if (handles.data.current >= length(handles.data.name))
    set(handles.pushbuttonNext,'Enable','off');
end
if (handles.data.current == 1)
    set(handles.pushbuttonPrevious,'Enable','off');
end


%reset pressure button
handles=reset_pressureButton(handles);
% Update handles structure
%guidata(hObject, handles);


function clearAllCursors(hObject, eventdata, handles)
Cursors=getappdata(handles.setRRGUI, 'VerticalCursors');
for (i=1:length(Cursors))
    DeleteCursor(handles.setRRGUI,i)
end
clear Cursors;

function clearAllCursorsType(hObject, eventdata, handles,Type)
Cursors=getappdata(handles.setRRGUI, 'VerticalCursors');
for (i=1:length(Cursors))
    if isstruct(Cursors{i})
        if strcmp(Cursors{i}.Type,Type)
            DeleteCursor(handles.setRRGUI,i)
        end
    end
end
clear Cursors;

function plotCursors(hObject, eventdata, handles)

if get(handles.checkboxCursors,'Value') %Markers enabled
    set(handles.uipanelNavigation,'Visible','off');
    set(handles.uipanelHelpers,'Visible','off');
    if(isfield(handles.current,'output'))
        if(isfield(handles.current.output,'startinsp'))
            for (i=1:length(handles.current.output.startinsp.x))
                n=CreateCursorType(handles.setRRGUI,'Insp',handles.current.output.startinsp.x(i)./handles.current.param.samplingrate.co2);
                %  SetCursorLocation(handles.setRRGUI,n,handles.current.output.startinsp.x(i)./handles.current.param.samplingrate);
            end
        end
        if(isfield(handles.current.output,'startexp'))
            for (i=1:length(handles.current.output.startexp.x))
                n=CreateCursorType(handles.setRRGUI,'Exp',handles.current.output.startexp.x(i)./handles.current.param.samplingrate.co2);
                %     SetCursorLocation(handles.setRRGUI,n,handles.current.output.startexp.x(i)./handles.current.param.samplingrate)
            end
        end
        if(isfield(handles.current.output,'endexpflow'))
            for (i=1:length(handles.current.output.endexpflow.x))
                n=CreateCursorType(handles.setRRGUI,'Eflow',handles.current.output.endexpflow.x(i)./handles.current.param.samplingrate.co2);
                %     SetCursorLocation(handles.setRRGUI,n,handles.current.output.startexp.x(i)./handles.current.param.samplingrate)
            end
        end
    end
    set(handles.uipanelNavigation,'Visible','on');
    set(handles.uipanelHelpers,'Visible','on');
end

function plotCursorsType(hObject, eventdata, handles,Type)

switch Type
    case 'Insp'
        field='startinsp';
    case 'Exp'
        field='startexp';
    case 'Eflow'
        field='endexpflow';
    otherwise
        
        return
end
set(handles.uipanelNavigation,'Visible','off');
set(handles.uipanelHelpers,'Visible','off');
pause(.3) %make sure tools are off
if(isfield(handles.current,'output'))
    if(isfield(handles.current.output,field))
        for (i=1:length(handles.current.output.(field).x))
            n=CreateCursorType(handles.setRRGUI,Type,handles.current.output.(field).x(i)./handles.current.param.samplingrate.co2);
            %  SetCursorLocation(handles.setRRGUI,n,handles.current.output.startinsp.x(i)./handles.current.param.samplingrate);
        end
    end
    
end
set(handles.uipanelNavigation,'Visible','on');
set(handles.uipanelHelpers,'Visible','on');



% --- Executes on button press in pushbuttonClearAllCursors.
function pushbuttonClearAllCursors_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearAllCursors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


selection = questdlg(['Are you sure you want to clear all cursors?'],...
    ['Clear All Cursors ...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end
clearAllCursors(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonSuggestionI.
function pushbuttonSuggestionI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSuggestionI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% TODO buffer for suggestion preview
startinsp_temp=negZeroCrossing(handles.current.data.flow.y,handles.current.param.samplingrate.flow);
%  for (i=1:length(handles.current.output.startinsp.x))
%                n=CreateCursorType(handles.setRRGUI,'Insp');
%                SetCursorLocation(handles.setRRGUI,n,handles.current.output.startinsp.x(i));
%             end
%         end
%
if isfield(handles.current,'output')
    
    if isfield(handles.current.output,'startexp')
        startinsp=zeros(size(handles.current.output.startexp.x));
        for i=1:length(handles.current.output.startexp.x)-1
            
            [a b]=find (startinsp_temp>handles.current.output.startexp.x(i) & startinsp_temp<handles.current.output.startexp.x(i+1),1,'last' );
            
            if isempty(a)
                startinsp(i)=(handles.current.output.startexp.x(i)+handles.current.output.startexp.x(i+1))/2;
                
            else
                startinsp(i)=startinsp_temp(a);
            end
        end
        
        handles.current.output.startinsp.x=startinsp;
    else
        handles.current.output.startinsp.x=startinsp_temp;
    end
else
    handles.current.output.startinsp.x=startinsp_temp;
end

clearAllCursorsType(hObject, eventdata, handles, 'Insp');

if handles.parameter.suggestion==0
    % plot new suggestion in batch mode
    plotCursorsType(hObject, eventdata, handles,'Insp');
    
else
    plotCursorsIterativeType(hObject, eventdata, handles,'Insp');
end
% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in togglebuttonSuggestion.
function togglebuttonSuggestion_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonSuggestion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonSuggestion

togglestate=get(hObject,'Value');
if togglestate==0
    set(hObject,'String','Batch Suggestion')
    handles.parameter.suggestion=0;
else
    set(hObject,'String','Iterative Suggestion')
    handles.parameter.suggestion=1;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbuttonReset.
function pushbuttonReset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg(['Are you sure you want to reset all cursors to saved positions?'],...
    ['Reset Cursors ...'],...
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


% --- Executes on button press in pushbuttonDisplayPressure.
function pushbuttonDisplayPressure_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDisplayPressure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%  axes(handles.axesFlow);
%      hold on;
%     plot((1:length(handles.current.data.pressure.y))./handles.current.param.samplingrate.pressure,handles.current.data.pressure.y,'g');
%  hold off
%TODO check if pressure is available
togglestate=get(hObject,'Value');
if togglestate
    handles.axesPressure = axes('Position',get(handles.axesFlow,'Position'));
    plot(handles.axesPressure,(1:length(handles.current.data.pressure.y))./handles.current.param.samplingrate.pressure,handles.current.data.pressure.y,'g');
    axis tight
    
    set(handles.axesPressure, 'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none',...
        'XColor','g','YColor','g', 'XLim',get(handles.axesFlow,'XLim' ));
    
    ylabel(['Pressure [' handles.current.meta.sensor.pressure.units ']'],'Rotation',90)
    
    set(hObject,'String','Hide Pressure')
    set(hObject,'BackgroundColor','g')
    
else
    %     if ishandle(handles.axesPressure)
    %         delete (handles.axesPressure)
    %         handles=rmfield(handles,'axesPressure');
    %     end
    %
    %     set(hObject,'String','Show Pressure')
    %     set(hObject,'BackgroundColor',[.7 .7 .7])
    handles=reset_pressureButton(handles);
end

% Update handles structure
guidata(hObject, handles);


function handles=reset_pressureButton(handles)

set(handles.pushbuttonDisplayPressure,'Enable','off');
set(handles.pushbuttonDisplayPressure,'String','Show Pressure');
set(handles.pushbuttonDisplayPressure,'Value',0);
set(handles.pushbuttonDisplayPressure,'BackgroundColor',[.7 .7 .7]);
if isfield(handles,'axesPressure')
    if ishandle(handles.axesPressure)
        delete (handles.axesPressure);
        handles=rmfield(handles,'axesPressure');
    end
end

set(handles.pushbuttonDisplayPressure,'Enable','off');
try
    if ~isempty(handles.current.data.pressure.y)
        set(handles.pushbuttonDisplayPressure,'Enable','on');
    end
catch
    disp('Info: No pressure data.')
end


% --- Executes on button press in pushbuttonCEndFlow.
function pushbuttonCEndFlow_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCEndFlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n1=CreateCursorType(handles.setRRGUI,'Eflow');





% --- Executes on button press in pushbuttonSuggestionE.
function pushbuttonSuggestionE_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSuggestionE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.current.output.startexp.x=posZeroCrossing(handles.current.data.flow.y,handles.current.param.samplingrate.flow);
% if(isfield(handles.current.output,'startexp'))
%             for (i=1:length(handles.current.output.startexp.x))
%                n=CreateCursorType(handles.setRRGUI,'Exp');
%                 SetCursorLocation(handles.setRRGUI,n,handles.current.output.startexp.x(i))
%             end
%         end
% clear previous cursors
clearAllCursorsType(hObject, eventdata, handles, 'Exp');

if handles.parameter.suggestion==0
    % plot new suggestion in batch mode
    plotCursorsType(hObject, eventdata, handles,'Exp');
    
else
    plotCursorsIterativeType(hObject, eventdata, handles,'Exp');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbuttonSuggestionEF.
function pushbuttonSuggestionEF_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSuggestionEF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.current.output.endexpflow.x=round(GetAllCursorLocations('Insp').*handles.current.param.samplingrate.co2);
% output.startinsp.x=round(GetAllCursorLocations('Insp').*handles.current.param.samplingrate.co2);
% output.startexp.x=round(GetAllCursorLocations('Exp').*handles.current.param.samplingrate.co2);
%  for i=1:length(output.startexp.x)
%    [val,handles.current.output.endexpflow.x(i)]=min(handles.current.data.flow.y(output.startexp.x(i):output.startinsp.x(i)));
%  end

clearAllCursorsType(hObject, eventdata, handles, 'Eflow');

if handles.parameter.suggestion==0
    % plot new suggestion in batch mode
    plotCursorsType(hObject, eventdata, handles,'Eflow');
    
else
    plotCursorsIterativeType(hObject, eventdata, handles,'Eflow');
end
% Update handles structure
guidata(hObject, handles);

function plotCursorsIterativeType(hObject, eventdata, handles,Type)


switch Type
    case 'Insp'
        field='startinsp';
    case 'Exp'
        field='startexp';
    case 'Eflow'
        field='endexpflow';
    otherwise
        
        return
end
set(handles.uipanelNavigation,'Visible','off');
set(handles.uipanelHelpers,'Visible','off');

if(isfield(handles.current,'output'))
    if(isfield(handles.current.output,field))
        for (i=1:length(handles.current.output.(field).x))
            n=CreateCursorType(handles.setRRGUI,Type,handles.current.output.(field).x(i)./handles.current.param.samplingrate.co2);
            %  SetCursorLocation(handles.setRRGUI,n,handles.current.output.startinsp.x(i)./handles.current.param.samplingrate);
            selection = questdlgNormal(['Do you want to set cursor ' Type ' ' num2str(n) ' ?'],...
                ['New Cursors ...'],...
                'Yes','No','Cancel','Yes');
            if strcmp(selection,'No')
                DeleteCursor(n);
            end
            if strcmp(selection,'Cancel')
                break;
            end
            
        end
    end
    
    
end
set(handles.uipanelNavigation,'Visible','on');
set(handles.uipanelHelpers,'Visible','on');


% --- Executes on button press in pushbuttonClearCInsp.
function pushbuttonClearCInsp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearCInsp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg(['Are you sure you want to clear all start inspiration cursors (blue)?'],...
    ['Clear Cursors ...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end
clearAllCursorsType(hObject, eventdata, handles,'Insp');


% --- Executes on button press in pushbuttonClearCExp.
function pushbuttonClearCExp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearCExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg(['Are you sure you want to clear all start expiration cursors (red) ?'],...
    ['Clear Cursors ...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end
clearAllCursorsType(hObject, eventdata, handles,'Exp');


% --- Executes on button press in pushbuttonClearCEFlow.
function pushbuttonClearCEFlow_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearCEFlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg(['Are you sure you want to clear all exnd expiration flow cursors (orange)?'],...
    ['Clear Cursors ...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end
clearAllCursorsType(hObject, eventdata, handles,'Eflow');


% --- Executes on button press in checkboxCursors.
function checkboxCursors_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxCursors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


value=get(hObject,'Value');
if value
    set(handles.uipanelLabels,'Visible','on');
    
    set(handles.pushbuttonSave,'Enable','on');
    set(handles.uipanelLabeltools,'Visible','on');
    outputfile=[handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_output.mat' ];
    if (exist(outputfile,'file')>0)
        tmp=load(outputfile);
        handles.current.output=tmp.output;
        plotCursors(hObject, eventdata, handles);
    end
else
    
    selection = questdlg(['No data will be saved when Cursors disabled. If you changed the cursor position since the last saving they will be lost.'],...
        ['No Cursors ...'],'OK','Cancel','OK');
    if strcmp(selection,'OK')
        set(handles.uipanelLabels,'Visible','off');
        set(handles.uipanelLabeltools,'Visible','off');
        set(handles.pushbuttonSave,'Enable','off');
        clearAllCursors(hObject, eventdata, handles);
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
