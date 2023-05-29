function varargout = alignGUI(varargin)
% ALIGNGUI M-file for alignGUI.fig
%      ALIGNGUI, by itself, creates a new ALIGNGUI or raises the existing
%      singleton*.
%
%      H = ALIGNGUI returns the handle to a new ALIGNGUI or the handle to
%      the existing singleton*.
%
%      ALIGNGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALIGNGUI.M with the given input arguments.
%
%      ALIGNGUI('Property','Value',...) creates a new ALIGNGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before alignGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to alignGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help alignGUI

% Last Modified by GUIDE v2.5 03-Dec-2009 11:14:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @alignGUI_OpeningFcn, ...
    'gui_OutputFcn',  @alignGUI_OutputFcn, ...
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

% --- Executes just before alignGUI is made visible.
function alignGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to alignGUI (see VARARGIN)

% Choose default command line output for alignGUI
%handles.output = hObject;
current=1;
checkAxes(hObject,2);
handles.thisGUI=hObject;
switch length(varargin)
    case 1
        raterID=cell2mat(varargin{1});
    case 2
        raterID=cell2mat(varargin{1});
        handles.menuFigure=varargin{2};
    case 3
        raterID=cell2mat(varargin{1});
        handles.menuFigure=varargin{2};
        current=varargin{3};
    otherwise
        % for development %TODO remove
        raterID='r1000';
        handles.menuFigure=[];
end


%if (varargin{1} == '')
if (strcmp(raterID,''))
    % no rater ID was set
else
    handles.parameters.raterID=raterID; %varargin{1};
    
    set(handles.editID,'String',raterID);
    handles.parameters.ratingFolder=['output'];
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
    
    
    setVisibility(hObject, eventdata, handles)
    
    handles.parameter.suggestion=0;
    % Update handles structure
    guidata(hObject, handles);
    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using alignGUI.
    % if strcmp(get(hObject,'Visible'),'off')
    % initialize current handle structure by loading first data file
    [handles]=LoadandDisplay(hObject, eventdata, handles);
    
    [handles]=initZoomSlider(handles);
    %end
else
    set(handles.pushbuttonPrevious,'Enable','off');
    set(handles.pushbuttonNext,'Enable','off');
end


      
        set(handles.pushbuttonSave,'Enable','off');

% UIWAIT makes alignGUI wait for user response (see UIRESUME)
% uiwait(handles.alignGUI);
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = alignGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = 'alignGUI';



% --- Executes on button press in pushbuttonPrevious.
function pushbuttonPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%save current ratings
saveLabel(hObject, eventdata, handles);

%update current data pointer
handles.data.current=handles.data.current-1;
% Update handles structure
guidata(hObject, handles);

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
saveLabel(hObject, eventdata, handles);
%update current data pointer
handles.data.current=handles.data.current+1;
% Update handles structure
guidata(hObject, handles);

setVisibility(hObject, eventdata, handles);

%load next data and ratings
%plot data and ratings
[handles]=LoadandDisplay(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in pushbuttonAlignLabel.
function pushbuttonAlignLabel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAlignLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%h=axes(handles.axesFlow);

n1=CreateCursorType(handles.alignGUI);
%SetCursorLocation(n1, 2.5);



function [handles]=LoadandDisplay(hObject, eventdata, handles)


% clears labels/cursors
clearAllCursors(hObject, eventdata, handles);

run configure.m

%loads new data
handles.current=load([conf.data.rootfolder filesep handles.data.name{handles.data.current}],'meta','data','param');
outputfile=[handles.parameters.ratingFolder filesep handles.data.name{handles.data.current} ];

%set(handles.signalTitleText,'String',handles.data.name{handles.data.current});
set(handles.alignGUI,'Name',handles.data.name{handles.data.current});
set(handles.popupmenuJump,'Value',handles.data.current);

axes(handles.axesCapnogram);
cla;
plot((1:length(handles.current.data.co2.y)),handles.current.data.co2.y,'k','Tag','CO2');
axis tight
ylabel(['pCO2 [' handles.current.meta.sensor.co2.units ']'],'Rotation',90)
xlabel(['samples'])

shift=0;
shiftfile=[conf.data.rootfolder filesep 'shift' handles.data.name{handles.data.current} ];
if (exist(shiftfile,'file')>0)
    tmp=load(shiftfile,'shift');
    handles.current.shift=tmp.shift;
    shift=tmp.shift;
   
end
 set(handles.editShift,'String',num2str(shift));

axes(handles.axesFlow);
cla;
plot((1:length(handles.current.data.flow.y))+shift,handles.current.data.flow.y,'k');
axis tight
grid on
ylabel(['Flow  [' handles.current.meta.sensor.flow.units ']'],'Rotation',90)
xlabel(['samples'])

set(handles.popupmenuZoom,'Value',1);

%loads the saved output if already stored



% % Update handles structure
% guidata(hObject, handles);




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
saveLabel(hObject, eventdata, handles)


function saveLabel(hObject, eventdata, handles)
try
    shift=str2double(get(handles.editShift,'String'));
    save(['data/shift' handles.data.name{handles.data.current} ],'shift');
     disp('Success: Shift saved.')
catch
    disp('Error: A problem during the saving process occured.')
end


function setVisibility(hObject, eventdata, handles)


set(handles.pushbuttonNext,'Enable','on');
set(handles.pushbuttonPrevious,'Enable','on');

if (handles.data.current >= length(handles.data.name))
    set(handles.pushbuttonNext,'Enable','off');
end
if (handles.data.current == 1)
    set(handles.pushbuttonPrevious,'Enable','off');
end

%reset pressure button
set(handles.pushbuttonDisplayPressure,'String','Show Pressure');
set(handles.pushbuttonDisplayPressure,'Value',0);
if isfield(handles,'axesPressure')
    if ishandle(handles.axesPressure)
        delete (handles.axesPressure)
    end
end


function clearAllCursors(hObject, eventdata, handles)
Cursors=getappdata(handles.alignGUI, 'VerticalCursors');
for (i=1:length(Cursors))
    DeleteCursor(handles.alignGUI,i)
end
clear Cursors;






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
    plot(handles.axesPressure,(1:length(handles.current.data.pressure.y))+str2double(get(handles.editShift,'String')),handles.current.data.pressure.y,'g');
    axis tight
    
    set(handles.axesPressure, 'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none',...
        'XColor','g','YColor','g', 'XLim',get(handles.axesFlow,'XLim' ));
 
    ylabel(['Pressure [' handles.current.meta.sensor.pressure.units ']'],'Rotation',90)

    set(hObject,'String','Hide Pressure')
    set(hObject,'BackgroundColor','g')
    
else
    if ishandle(handles.axesPressure)
        delete (handles.axesPressure)
    end
    set(hObject,'String','Show Pressure')
    set(hObject,'BackgroundColor',[.7 .7 .7])
end

% Update handles structure
guidata(hObject, handles);








function editShift_Callback(hObject, eventdata, handles)
% hObject    handle to editShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editShift as text
%        str2double(get(hObject,'String')) returns contents of editShift as a double
shift=str2double(get(hObject,'String'));

location=GetAllCursorLocations('Default');
clearAllCursors(hObject, eventdata, handles);
axes(handles.axesFlow);
plot((1:length(handles.current.data.flow.y))+shift,handles.current.data.flow.y,'k');

axis tight
grid minor
set(handles.axesFlow,'XLim',get(handles.axesCapnogram,'Xlim'));
for i=1:length(location)
    n=CreateCursorType(handles.alignGUI,'Default',location(i));
end

% --- Executes during object creation, after setting all properties.
function editShift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenuZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'Value', 1);
set(hObject,'String',{'full record','1000', '100'});
% Update handles structure
guidata(hObject, handles);


% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function  [handles]=initZoomSlider(handles);

handles.data.window=length(handles.current.data.co2.y);

        set(handles.sliderZoom,'Value',handles.data.window/2)
        set(handles.sliderZoom,'Min',handles.data.window/2)
        set(handles.sliderZoom,'Max',max(length(handles.current.data.co2.y)-handles.data.window/2,handles.data.window/2+1))
        set(handles.sliderZoom,'SliderStep',[0.05 1])

        set(handles.axesCapnogram,'XLim', [0 handles.data.window]);
        % --- Executes on selection change in popupmenuZoom.
function popupmenuZoom_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuZoom contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuZoom

windowlength=get(hObject,'Value');
switch windowlength
 
    case 3
         handles.data.window=100;
       % break;
    case 2
         handles.data.window=1000;
       % break;
    case 1
         handles.data.window=length(handles.current.data.co2.y);
       % break:
end
set(handles.sliderZoom,'Value',handles.data.window/2);
set(handles.sliderZoom,'Min',handles.data.window/2);
set(handles.sliderZoom,'Max',max(length(handles.current.data.co2.y)-handles.data.window/2,handles.data.window/2+1));
set(handles.sliderZoom,'SliderStep',[0.005 1]);



strfnames=fieldnames(handles);
idx = strncmp(strfnames', 'axes', 4);
try
for k=find(idx)

set(handles.(strfnames{k}),'XLim', [0 handles.data.window]);
%set(handles.axesFlow,'XLim', [-handles.data.window/2 handles.data.window/2]+get(hObject,'Value'));

end

catch
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


