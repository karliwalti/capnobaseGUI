function varargout = browseSignalsGUI2(varargin)
% BROWSESIGNALSGUI2 M-file for browseSignalsGUI2.fig
%      BROWSESIGNALSGUI2, by itself, creates a new BROWSESIGNALSGUI2 or raises the existing
%      singleton*.
%
%      H = BROWSESIGNALSGUI2 returns the handle to a new BROWSESIGNALSGUI2 or the handle to
%      the existing singleton*.
%
%      BROWSESIGNALSGUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BROWSESIGNALSGUI2.M with the given input arguments.
%
%      BROWSESIGNALSGUI2('Property','Value',...) creates a new BROWSESIGNALSGUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before browseSignalsGUI2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to browseSignalsGUI2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help browseSignalsGUI2

% Last Modified by GUIDE v2.5 15-Mar-2011 15:27:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @browseSignalsGUI2_OpeningFcn, ...
    'gui_OutputFcn',  @browseSignalsGUI2_OutputFcn, ...
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

% --- Executes just before browseSignalsGUI2 is made visible.
function browseSignalsGUI2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to browseSignalsGUI2 (see VARARGIN)

% Choose default command line output for browseSignalsGUI2
%handles.output = hObject;
path(path,'utils')
assignin('base', 'RRGUI', hObject);
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

%init dataset folder
handles.parameters.dataset='default';
presence=strcmp(handles.parameters.dataset,get(handles.popupmenuDataset,'String'));
if sum(presence>0)
    set(handles.popupmenuDataset,'Value',find(presence,1));
end

if (strcmp(raterID,''))
    % no rater ID was set
else
    handles.parameters.raterID=raterID; %varargin{1};
    
    %    set(handles.editID,'String',raterID);
    %    set(handles.editDataset,'String',handles.parameters.dataset);
    %handles.parameters.ratingFolder=['output'];
    % handles.parameters.ratingFolder=['data/'];
    handles.parameters.ratingFolder=['data/' handles.parameters.dataset '/'];
    
    if (~isdir(handles.parameters.ratingFolder))
        mkdir(handles.parameters.ratingFolder);
    end
    
    % read the data directory
    [handles, counter]=readDataDir(hObject,eventdata,handles);
end


if(counter>1)
    handles.parameters.settingFile=['settings/setRR' num2str(raterID) '.mat'];
    
    handles.data.current=current; % set pointer to first
    
    %     if current==1 %check for setting file
    %         if exist(handles.parameters.settingFile,'file')
    %
    %             %load (handles.parameters.settingFile)
    %             if (current<=counter)
    %                 handles.data.current=current;
    %             end
    %
    %         end
    %     end
    
    
    setVisibility(hObject, eventdata, handles)
    set(handles.uipanelParam,'Visible','off');
    handles.parameter.suggestion=0;
    % Update handles structure
    guidata(hObject, handles);
    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using browseSignalsGUI2.
    % if strcmp(get(hObject,'Visible'),'off')
    % initialize current handle structure by loading first data file
    [handles]=LoadandDisplay(hObject, eventdata, handles);
    
    [handles]=initZoomSliderBrowseSignals(handles);
    %end
else
    set(handles.pushbuttonPrevious,'Enable','off');
    set(handles.pushbuttonNext,'Enable','off');
end

set(handles.uipanelLabels,'Visible','off');
set(handles.uipanelLabeltools,'Visible','off');
set(handles.pushbuttonSave,'Enable','off');
set(handles.uipanelQRSTools,'Visible','off');
set(handles.uipanelPleth,'Visible','off');
set(handles.uipanelQRSshift,'Visible','off');
set(handles.uipanelPlethShift,'Visible','off');

set(handles.uipanelButton,'SelectionChangeFcn',@uipanelButton_SelectionChangeFcn);
% UIWAIT makes browseSignalsGUI2 wait for user response (see UIRESUME)
% uiwait(handles.browseSignalsGUI2);
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = browseSignalsGUI2_OutputFcn(hObject, eventdata, handles)
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
%saveLabel(hObject, eventdata, handles);

%update current data pointer
handles.data.current=handles.data.current-1;
% Update handles structure
guidata(hObject, handles);

[handles]=setVisibility(hObject, eventdata, handles);
set(handles.editComments,'String','')
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
%saveLabel(hObject, eventdata, handles);
%update current data pointer
handles.data.current=handles.data.current+1;
% Update handles structure
guidata(hObject, handles);

[handles]=setVisibility(hObject, eventdata, handles);
set(handles.editComments,'String','')
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
%h=axes(handles.axesBottom);

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


% --- Executes on button press in pushbuttonCDelete.
function pushbuttonCDelete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DeleteCursor(str2double(get(handles.editDCursorNumber,'String')));

function handles=discoverAvailableSignals(handles);

handles.availableSignals=fieldnames(handles.current.data);
% comparison=strcmp('pleth',availableFields)
% [a b]=find(comparison)
%
% if ~isempty(a)
%     availableFields(a)=[];
% availableFields2=fieldnames(handles.current.data.pleth);
% availableFields=[availableFields availableFields2]
% end
contents=get(handles.popupmenuBottomDisplay,'String');
oldBottom=contents{get(handles.popupmenuBottomDisplay,'Value')};
oldTop=contents{get(handles.popupmenuTopDisplay,'Value')};

set(handles.popupmenuBottomDisplay,'String',handles.availableSignals);
presence=strcmp(oldBottom,handles.availableSignals);
if sum(presence)>0
    set(handles.popupmenuBottomDisplay,'Value',find(presence,1));
else
    set(handles.popupmenuBottomDisplay,'Value',1);
end
set(handles.popupmenuTopDisplay,'String',handles.availableSignals);

presence=strcmp(oldTop,handles.availableSignals);
if sum(presence)>0
    set(handles.popupmenuTopDisplay,'Value',find(presence,1));
else
    set(handles.popupmenuTopDisplay,'Value',1);
    
end

function plotAxis(CurrentAxis,signalNr,handles)

axes(CurrentAxis);
%cla(CurrentAxis);

% use x vector if available
if isfield(handles.current.data.(handles.availableSignals{signalNr}),'x')
    plot(CurrentAxis,(handles.current.data.(handles.availableSignals{signalNr}).x)./handles.current.param.samplingrate.(handles.availableSignals{signalNr}),handles.current.data.(handles.availableSignals{signalNr}).y,'*r','Tag',handles.availableSignals{signalNr});
    if isfield(handles.current.param, 'normalrange')
        if isfield(handles.current.param.normalrange,handles.availableSignals{signalNr})
            yLim(CurrentAxis,handles.current.param.normalrange.(handles.availableSignals{signalNr}));
        end
    end
else
    maxlength=length(handles.current.data.(handles.availableSignals{1}).y)./handles.current.param.samplingrate.(handles.availableSignals{1});
    difflength=maxlength-length(handles.current.data.(handles.availableSignals{signalNr}).y)./handles.current.param.samplingrate.(handles.availableSignals{signalNr});
    plot(CurrentAxis,(1:length(handles.current.data.(handles.availableSignals{signalNr}).y))./handles.current.param.samplingrate.(handles.availableSignals{signalNr})+difflength,handles.current.data.(handles.availableSignals{signalNr}).y,'b','Tag',handles.availableSignals{signalNr});
end
grid on;
%axis tight
strfnames=fieldnames(handles);
idx = strncmp(strfnames', 'axes', 4);
for k=find(idx)
    if(handles.(strfnames{k})~=CurrentAxis)
        OtherAxis=handles.(strfnames{k});
    end
    % set y limits
    if(strfind(strfnames{k},'Top'))
        limit=get(handles.(strfnames{k}),'YLim');
        %       set(handles.sliderTopYhigh,'Value',limit(2));
        %       set(handles.sliderTopYlow,'Value',limit(1));
        %       set(handles.sliderTopYhigh,'SliderStep',[abs(limit(2)-limit(1))/1000,abs(limit(2)-limit(1))/100]);
        %       set(handles.sliderTopYlow,'SliderStep',[abs(limit(2)-limit(1))/1000,abs(limit(2)-limit(1))/100]);
        %        set(handles.sliderTopYhigh,'Min',limit(1));
        %       set(handles.sliderTopYlow,'Max',limit(2));
        
    end
    if(strfind(strfnames{k},'Bottom'))
        limit=get(handles.(strfnames{k}),'YLim');
        %       set(handles.sliderBottomYhigh,'Value',limit(2));
        %       set(handles.sliderBottomYlow,'Value',limit(1));
        %        set(handles.sliderBottomYhigh,'SliderStep',[abs(limit(2)-limit(1))/1000,abs(limit(2)-limit(1))/100]);
        %       set(handles.sliderBottomYlow,'SliderStep',[abs(limit(2)-limit(1))/1000,abs(limit(2)-limit(1))/100]);
        %       set(handles.sliderBottomYhigh,'Min',limit(1));
        %       set(handles.sliderBottomYlow,'Max',limit(2));
        
    end
    
end
set(CurrentAxis,'XLim', get(OtherAxis,'XLim'));

try
    ylabel([' [' handles.current.meta.sensor.(handles.availableSignals{signalNr}).units ']'],'Rotation',90)
catch
    ylabel([' [ unknown ]'],'Rotation',90)
    
end

xlabel(['seconds'])

function [handles]=LoadandDisplay(hObject, eventdata, handles)


% clears labels/cursors
clearAllCursors(hObject, eventdata, handles);

%loads new data
%handles.current=load(['data/' handles.data.name{handles.data.current}],'meta','data','param');
try
    load(['data/' handles.parameters.dataset '/' handles.data.name{handles.data.current} '_signal'],'data'); %load all data
catch
    load(['data/default'],'data');
    data.flow.y=data.flow.y-2;
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
try
    
    load(['data/' handles.parameters.dataset '/' handles.data.name{handles.data.current} '_trend'],'trend');
    trendparam=load(['data/' handles.parameters.dataset '/' handles.data.name{handles.data.current} '_trend'],'param');
    
catch
    trend=struct([]);
    load(['data/default'],'trend');
    trendparam=load(['data/default'],'param');
end
try
    
    load(['data/' handles.parameters.dataset '/' handles.data.name{handles.data.current} '_prediction'],'prediction');
    predictionparam=load(['data/' handles.parameters.dataset '/' handles.data.name{handles.data.current} '_prediction'],'param');
    
catch
    prediction=struct([]);
    load(['data/default'],'prediction');
    predictionparam=load(['data/default'],'param');
end

try
    load(['data/' handles.parameters.dataset '/' handles.data.name{handles.data.current} '_comment'],'comment');
    set(handles.editComments,'String',comment)
catch
end
% merge structures
data=catstruct(data, trend, prediction);
param.samplingrate=catstruct(trendparam.param.samplingrate,predictionparam.param.samplingrate,param.samplingrate); %param will be the most trusted valuefor duplicates
if isfield(predictionparam.param, 'normalrange')
    param.normalrange=predictionparam.param.normalrange; %param will be the most trusted valuefor duplicates
end


handles.current.data=data;
handles.current.param=param;
handles.current.meta=meta;
%handles.current.trend=trend;
%handles.current.prediction=prediction;

outputfile=[handles.parameters.ratingFolder '/' handles.data.name{handles.data.current} '_output.mat' ];

handles=discoverAvailableSignals(handles);
%set(handles.signalTitleText,'String',handles.data.name{handles.data.current});
set(handles.setRRGUI,'Name',handles.data.name{handles.data.current});
set(handles.popupmenuJump,'Value',handles.data.current);

plotAxis(handles.axesTop,get(handles.popupmenuTopDisplay,'Value'),handles);
plotAxis(handles.axesBottom,get(handles.popupmenuBottomDisplay,'Value'),handles);


set(handles.sliderZoom,'Enable','off');
%set(handles.popupmenuZoom,'Value',1);
popupmenuZoom_Callback(handles.popupmenuZoom, eventdata, handles);
%set current axis
axes(handles.axesTop);

%loads the saved output if already stored
if (exist(outputfile,'file')>0)
    tmp=load(outputfile,'output');
    handles.current.output=tmp.output;
    
    plotCursors(hObject, eventdata, handles)
    
end

%current=handles.data.current;
%save(handles.parameters.settingFile,'current');

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
handles=saveLabel(hObject, eventdata, handles);


function handles=saveLabel(hObject, eventdata, handles)
try
    if isfield(handles.current,'output')
        output=handles.current.output;
    end
    %if get(handles.checkboxCursors,'Value') %Markers enabled
    if get(handles.radiobuttonResp,'Value')
        output.startinsp.x=round(GetAllCursorLocations('Insp').*handles.current.param.samplingrate.co2);
        output.startexp.x=round(GetAllCursorLocations('Exp').*handles.current.param.samplingrate.co2);
        output.endexpflow.x=round(GetAllCursorLocations('Eflow').*handles.current.param.samplingrate.co2);
        % output.rater=get(handles.editID,'String');
        save([handles.parameters.ratingFolder '/' handles.data.name{handles.data.current} '_output'],'output');
        disp('Success: Annotations saved.');
        %elseif get(handles.checkboxQRS,'Value') %QRS enabled
    elseif get(handles.radiobuttonQRS,'Value')
        output.qrs.x=round(GetAllCursorLocations('QRS').*handles.current.param.samplingrate.co2);
        output.artif.x=round(GetAllCursorLocations('Artif').*handles.current.param.samplingrate.co2);
        idx=find(diff( output.qrs.x )==0);
        if ~isempty(idx)
        output.qrs.x(idx)=[];
        disp('Warning: removed duplicate qrs points');
        end
        handles.current.output.qrs.x=output.qrs.x;
        handles.current.output.artif.x=output.artif.x;
        % output.rater=get(handles.editID,'String');
        save([handles.parameters.ratingFolder '/' handles.data.name{handles.data.current} '_output'],'output');
        disp('Success: QRS Annotations saved.');
        %elseif get(handles.checkboxPleth,'Value') %Pleth enabled
    elseif get(handles.radiobuttonPleth,'Value')
        output.pleth_peak.x=round(GetAllCursorLocations('PlethPeak').*handles.current.param.samplingrate.pleth);
        
        output.plethartif.x=round(GetAllCursorLocations('PlethArtif').*handles.current.param.samplingrate.pleth);
        
        idx=find(diff( output.pleth_peak.x )==0);
        if ~isempty(idx)
        output.pleth_peak.x(idx)=[];
        disp('Warning: removed duplicate pleth peak points');
        end
        
        handles.current.output.plethartif.x=output.plethartif.x;
        handles.current.output.pleth_peak.x=output.pleth_peak.x;
        % output.rater=get(handles.editID,'String');
        save([handles.parameters.ratingFolder '/' handles.data.name{handles.data.current} '_output'],'output');
        disp('Success: Pleth Annotations saved.');
    else
        disp('Warning: No annotations saved because marker option not set.');
    end
catch
    disp('Error: A problem during the saving process occured.')
end
% Update handles structure
guidata(hObject, handles);

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
set(handles.uipanelNavigation,'Visible','off');
set(handles.uipanelHelpers,'Visible','off');
pause(.5);
AxesList=sort(findobj(handles.setRRGUI, 'type', 'axes'));
ylimits=[];
%if get(handles.checkboxCursors,'Value') %Markers enabled
if get(handles.radiobuttonResp,'Value') %Markers enabled
    
    if(isfield(handles.current,'output'))
        %get right axis, reduce to one
        for k=1:length(AxesList)
            DataHandle=findobj(AxesList(k),'Tag','co2');
            if ~isempty(DataHandle)
                ylimits=get(AxesList(k),'YLim');
                AxesList=AxesList(k);
                
                break;
            end
        end
        if(isfield(handles.current.output,'startinsp'))
            for (i=1:length(handles.current.output.startinsp.x))
                n=CreateCursorType(handles.setRRGUI,'Insp',handles.current.output.startinsp.x(i)./handles.current.param.samplingrate.co2,i,AxesList,ylimits);
                %  SetCursorLocation(handles.browseSignalsGUI2,n,handles.current.output.startinsp.x(i)./handles.current.param.samplingrate);
            end
        end
        if(isfield(handles.current.output,'startexp'))
            for (i=1:length(handles.current.output.startexp.x))
                n=CreateCursorType(handles.setRRGUI,'Exp',handles.current.output.startexp.x(i)./handles.current.param.samplingrate.co2,[]);              %AxesList,ylimits
                %     SetCursorLocation(handles.browseSignalsGUI2,n,handles.current.output.startexp.x(i)./handles.current.param.samplingrate)
            end
        end
        if(isfield(handles.current.output,'endexpflow'))
            for (i=1:length(handles.current.output.endexpflow.x))
                n=CreateCursorType(handles.setRRGUI,'Eflow',handles.current.output.endexpflow.x(i)./handles.current.param.samplingrate.co2,[],AxesList,ylimits);
                %     SetCursorLocation(handles.browseSignalsGUI2,n,handles.current.output.startexp.x(i)./handles.current.param.samplingrate)
            end
        end
        
        
    end
    %elseif  get(handles.checkboxQRS,'Value') %Markers enabled
elseif  get(handles.radiobuttonQRS,'Value') %Markers enabled
    if isfield (handles.current.param.samplingrate,'ecg')
        if(isfield(handles.current,'output'))
            for k=1:length(AxesList)
                DataHandle=findobj(AxesList(k),'Tag','ecg');
                if ~isempty(DataHandle)
                    ylimits=get(AxesList(k),'YLim');
                    AxesList=AxesList(k);
                    
                    break;
                end
            end
            if(isfield(handles.current.output,'qrs'))
                
                for (i=1:length(handles.current.output.qrs.x))
                    n=CreateCursorType(handles.setRRGUI,'QRS',handles.current.output.qrs.x(i)./handles.current.param.samplingrate.ecg,i,AxesList,ylimits);
                    %n=CreateMarkerType(handles.setRRGUI,'QRS',handles.current.output.qrs.x(i)./handles.current.param.samplingrate.ecg);
                    
                    %     SetCursorLocation(handles.browseSignalsGUI2,n,handles.current.output.startexp.x(i)./handles.current.param.samplingrate)
                end
            end
            if(isfield(handles.current.output,'artif'))
                for (i=1:length(handles.current.output.artif.x))
                    n=CreateCursorType(handles.setRRGUI,'Artif',handles.current.output.artif.x(i)./handles.current.param.samplingrate.ecg,[],AxesList,ylimits);
                    %     SetCursorLocation(handles.browseSignalsGUI2,n,handles.current.output.startexp.x(i)./handles.current.param.samplingrate)
                end
            end
        end
    end
    
    %elseif  get(handles.checkboxPleth,'Value') %Markers enabled
elseif  get(handles.radiobuttonPleth,'Value') %Markers enabled
    
    if isfield (handles.current.param.samplingrate,'pleth')
        if(isfield(handles.current,'output'))
            for k=1:length(AxesList)
                DataHandle=findobj(AxesList(k),'Tag','pleth');
                if ~isempty(DataHandle)
                    ylimits=get(AxesList(k),'YLim');
                    AxesList=AxesList(k);
                    break;
                end
            end
            
            
            
            
            if(isfield(handles.current.output,'pleth_peak'))
                
                for (i=1:length(handles.current.output.pleth_peak.x))
                    n=CreateCursorType(handles.setRRGUI,'PlethPeak',handles.current.output.pleth_peak.x(i)./handles.current.param.samplingrate.pleth,i,AxesList,ylimits);
                    %n=CreateMarkerType(handles.setRRGUI,'QRS',handles.current.output.qrs.x(i)./handles.current.param.samplingrate.ecg);
                    
                    %     SetCursorLocation(handles.browseSignalsGUI2,n,handles.current.output.startexp.x(i)./handles.current.param.samplingrate)
                end
            end
            if(isfield(handles.current.output,'plethartif'))
                for (i=1:length(handles.current.output.plethartif.x))
                    n=CreateCursorType(handles.setRRGUI,'PlethArtif',handles.current.output.plethartif.x(i)./handles.current.param.samplingrate.pleth,[],AxesList);
                    %     SetCursorLocation(handles.browseSignalsGUI2,n,handles.current.output.startexp.x(i)./handles.current.param.samplingrate)
                end
            end
        end
    end
    
end
set(handles.uipanelNavigation,'Visible','on');
set(handles.uipanelHelpers,'Visible','on');

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
AxesList=sort(findobj(handles.setRRGUI, 'type', 'axes'));
set(handles.uipanelNavigation,'Visible','off');
set(handles.uipanelHelpers,'Visible','off');
pause(.3) %make sure tools are off
if(isfield(handles.current,'output'))
    if(isfield(handles.current.output,field))
        for (i=1:length(handles.current.output.(field).x))
            n=CreateCursorType(handles.setRRGUI,Type,handles.current.output.(field).x(i)./handles.current.param.samplingrate.co2,[],AxesList);
            %  SetCursorLocation(handles.browseSignalsGUI2,n,handles.current.output.startinsp.x(i)./handles.current.param.samplingrate);
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

if isfield(handles.current.data,'flow')
    startinsp_temp=getInspFlow(handles.current.data.flow.y,handles.current.param.samplingrate.flow);
    
else
    startinsp_temp=getInsp(handles.current.data.co2.y,handles.current.param.samplingrate.co2);
end
%  for (i=1:length(handles.current.output.startinsp.x))
%                n=CreateCursorType(handles.browseSignalsGUI2,'Insp');
%                SetCursorLocation(handles.browseSignalsGUI2,n,handles.current.output.startinsp.x(i));
%             end
%         end
%
if isfield(handles.current,'output')
    
    if isfield(handles.current.output,'startexp')
        startinsp=zeros(size(handles.current.output.startexp.x));
        for i=1:length(handles.current.output.startexp.x)-1
            
            %         [a b]=find (startinsp_temp>handles.current.output.startexp.x(i) & startinsp_temp<handles.current.output.startexp.x(i+1),1,'first' );
            %
            %         if isempty(a)
            %             startinsp(i)=(handles.current.output.startexp.x(i)+handles.current.output.startexp.x(i+1))/2;
            %
            %         else
            %             startinsp(i)=startinsp_temp(a);
            %         end
            
            %% find first positive flow  value before exp
            [a b]=find (handles.current.data.flow.y(handles.current.output.startexp.x(i):handles.current.output.startexp.x(i+1))>=0,1,'last' );
            %
            if ~isempty(a)
                startinsp(i)=a+handles.current.output.startexp.x(i);
                
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
% function pushbuttonDisplayPressure_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbuttonDisplayPressure (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% %  axes(handles.axesBottom);
% %      hold on;
% %     plot((1:length(handles.current.data.pressure.y))./handles.current.param.samplingrate.pressure,handles.current.data.pressure.y,'g');
% %  hold off
% %TODO check if pressure is available
% togglestate=get(hObject,'Value');
% if togglestate
%     handles.axesPressure = axes('Position',get(handles.axesBottom,'Position'));
%     plot(handles.axesPressure,(1:length(handles.current.data.pressure.y))./handles.current.param.samplingrate.pressure,handles.current.data.pressure.y,'g');
%     axis tight
%
%     set(handles.axesPressure, 'XAxisLocation','top',...
%         'YAxisLocation','right',...
%         'Color','none',...
%         'XColor','g','YColor','g', 'XLim',get(handles.axesBottom,'XLim' ));
%
%     ylabel(['Pressure [' handles.current.meta.sensor.pressure.units ']'],'Rotation',90)
%
%     set(hObject,'String','Hide Pressure')
%     set(hObject,'BackgroundColor','g')
%
% else
% %     if ishandle(handles.axesPressure)
% %         delete (handles.axesPressure)
% %         handles=rmfield(handles,'axesPressure');
% %     end
% %
% %     set(hObject,'String','Show Pressure')
% %     set(hObject,'BackgroundColor',[.7 .7 .7])
%     handles=reset_pressureButton(handles);
% end
%
% % Update handles structure
% guidata(hObject, handles);
%

function handles=reset_pressureButton(handles)

% set(handles.pushbuttonDisplayPressure,'String','Show Pressure');
% set(handles.pushbuttonDisplayPressure,'Value',0);
% set(handles.pushbuttonDisplayPressure,'BackgroundColor',[.7 .7 .7])
% if isfield(handles,'axesPressure')
%     if ishandle(handles.axesPressure)
%         delete (handles.axesPressure)
%         handles=rmfield(handles,'axesPressure');
%     end
% end
%
% set(handles.pushbuttonDisplayPressure,'Enable','off');
% try
% if ~isempty(handles.current.data.pressure.y)
%      set(handles.pushbuttonDisplayPressure,'Enable','on');
% end
% catch
% end


% --- Executes on button press in pushbuttonCEndFlow.
function pushbuttonCEndFlow_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCEndFlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n1=CreateCursorType(handles.setRRGUI,'Eflow');



% --- Executes during object creation, after setting all properties.
function popupmenuJumpTask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuJumpTask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSuggestionE.
function pushbuttonSuggestionE_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSuggestionE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles.current.data,'flow')
    handles.current.output.startexp.x=getExpFlow(handles.current.data.flow.y,handles.current.param.samplingrate.flow,-0.5);
    
else
    handles.current.output.startexp.x=getExp(handles.current.data.co2.y,handles.current.param.samplingrate.co2,1.5);
end
% if(isfield(handles.current.output,'startexp'))
%             for (i=1:length(handles.current.output.startexp.x))
%                n=CreateCursorType(handles.browseSignalsGUI2,'Exp');
%                 SetCursorLocation(handles.browseSignalsGUI2,n,handles.current.output.startexp.x(i))
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
            %  SetCursorLocation(handles.browseSignalsGUI2,n,handles.current.output.startinsp.x(i)./handles.current.param.samplingrate);
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
    set(handles.popupmenuTopDisplay,'Enable','off');
    set(handles.popupmenuBottomDisplay,'Enable','off');
    set(handles.uipanelLabeltools,'Visible','on');
    outputfile=[handles.parameters.ratingFolder '/' handles.data.name{handles.data.current} ];
    if (exist(outputfile,'file')>0)
        tmp=load(outputfile);
        handles.current.output=tmp.output;
        plotCursors(hObject, eventdata, handles)
    end
else
    
    % selection = warndlg(['No data will be saved when Cursors disabled. If you changed the cursor position since the last saving they will be lost.'],...
    %     ['No Cursors ...']);
    set(handles.uipanelLabels,'Visible','off');
    set(handles.uipanelLabeltools,'Visible','off');
    set(handles.pushbuttonSave,'Enable','off');
    set(handles.popupmenuTopDisplay,'Enable','on');
    set(handles.popupmenuBottomDisplay,'Enable','on');
    clearAllCursors(hObject, eventdata, handles);
end


% --- Executes on selection change in popupmenuTopDisplay.
function popupmenuTopDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTopDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuTopDisplay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTopDisplay

plotAxis(handles.axesTop,get(hObject,'Value'),handles)

% --- Executes during object creation, after setting all properties.
function popupmenuTopDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTopDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuBottomDisplay.
function popupmenuBottomDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuBottomDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuBottomDisplay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuBottomDisplay
plotAxis(handles.axesBottom,get(hObject,'Value'),handles);

% --- Executes during object creation, after setting all properties.
function popupmenuBottomDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuBottomDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxDataCursor.
function checkboxDataCursor_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDataCursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxDataCursor
datacursormode


% --- Executes on button press in checkboxAUC.
function checkboxAUC_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAUC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAUC
Type='AUC';
if get(hObject,'Value')
    n=CreateCursorType(handles.setRRGUI,Type);
    m=CreateCursorType(handles.setRRGUI,Type);
    set(handles.uipanelParam,'Visible','on');
    set(handles.popupmenuTopDisplay,'Enable','off');
    set(handles.popupmenuBottomDisplay,'Enable','off');
else
    DeleteCursorType(Type);
    set(handles.uipanelParam,'Visible','off');
    set(handles.popupmenuTopDisplay,'Enable','on');
    set(handles.popupmenuBottomDisplay,'Enable','on');
    
end

function [auc, vect, base, ampli,width] =calculateAUC(handles,signalNr)
vect=round(GetAllCursorLocations('AUC').*handles.current.param.samplingrate.(handles.availableSignals{signalNr}));
vect(1)=max(1,vect(1));
auc=trapz(handles.current.data.(handles.availableSignals{signalNr}).y(vect(1):vect(2)));
base=mean(handles.current.data.(handles.availableSignals{signalNr}).y([vect(1),vect(2)]));
auc=auc-(vect(2)-vect(1))*base;
auc=auc./handles.current.param.samplingrate.(handles.availableSignals{signalNr});
[ampli.v ampli.x]=max(handles.current.data.(handles.availableSignals{signalNr}).y(vect(1):vect(2))-base);
ampli.x=(ampli.x+vect(1))./handles.current.param.samplingrate.(handles.availableSignals{signalNr});

vect=vect./handles.current.param.samplingrate.(handles.availableSignals{signalNr});
width=vect(2)-vect(1);
% --- Executes on button press in pushbuttonAUCRefresh.
function pushbuttonAUCRefresh_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAUCRefresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal=get(handles.popupmenuTopDisplay,'Value');
[auc,vect,base,ampli,width]=calculateAUC(handles,signal);
set(handles.textAUC,'String',num2str(auc));
set(handles.textWidth,'String',num2str(width));
set(handles.textAmplitude,'String',num2str(ampli.v));
DeleteTaggedLine(handles.axesTop,'Base');
DeleteTaggedLine(handles.axesTop,'Ampli');
hold on
plot(handles.axesTop,vect,[base base],'-*m','Tag','Base')
plot(handles.axesTop,[ampli.x ampli.x],[base base+ampli.v],'-dm','Tag','Ampli')
hold off

% --- Executes on selection change in popupmenuDataset.
function popupmenuDataset_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuDataset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuDataset

% var=evalin('base',' whos(''-regexp'', ''GUI'')');
% if length(var)>0
%     selection = questdlg(['Changing the dataset will close all open task windows. Do you want to continue?'],...
%         ['Work with new dataset'],...
%              'Close & save','Close without saving','Cancel','Close & save');
% if strcmp(selection,'Cancel')
%     return;
% elseif strcmp(selection,'Close & save')
%
%   if evalin('base','exist(''mGUI'',''var'')')
%        temphandles= evalin('base','guidata(mGUI)');
%         err=saveMeta(temphandles);
%         if err~=0
%             popupError(err);
%         end
%     elseif evalin('base','exist(''rGUI'',''var'')')
%         temphandles= evalin('base','guidata(rGUI)');
%         err=saveRating(temphandles);
%         if err~=0
%             popupError(err);
%         end
%     elseif evalin('base','exist(''EtCO2GUI'',''var'')')
%         temphandles= evalin('base','guidata(EtCO2GUI)');
%         saveMarkerLabel(temphandles);
%
%     elseif evalin('base','exist(''RRGUI'',''var'')')
%         temphandles= evalin('base','guidata(RRGUI)');
%         saveCursorLabel(temphandles);
% %     else
% %         disp('Warning: Selected "save & close" but nothing to save.')
%     end
% end
%     evalin('base',' var=whos(''-regexp'', ''GUI''); for i=1:length(var); if ishandle(eval(var(i).name))  ; delete(eval(var(i).name));  clear(var(i).name); end; end;');
% end
contents = get(hObject,'String');
handles.parameters.dataset=     contents{get(hObject,'Value')};
disp(['Info: Dataset is now "' contents{get(hObject,'Value')} '".' ] );

handles.parameters.ratingFolder=['data/' handles.parameters.dataset '/'];

if (~isdir(handles.parameters.ratingFolder))
    mkdir(handles.parameters.ratingFolder);
end

% read the data directory
[handles, counter]=readDataDir(hObject,eventdata,handles);

handles.data.current=1; % set pointer to first



setVisibility(hObject, eventdata, handles);
set(handles.uipanelParam,'Visible','off');
handles.parameter.suggestion=0;
% Update handles structure
guidata(hObject, handles);
% This sets up the initial plot - only do when we are invisible
% so window can get raised using browseSignalsGUI2.
% if strcmp(get(hObject,'Visible'),'off')
% initialize current handle structure by loading first data file
[handles]=LoadandDisplay(hObject, eventdata, handles);

[handles]=initZoomSliderBrowseSignals(handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuDataset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

fillpopupmenuDataset(hObject);


function fillpopupmenuDataset(hObject)
counter=1;
dircontent=dir('data');
a=3;
if isunix
    a=3;
end
for i=a:length(dircontent)
    if (dircontent(i).isdir)
        dataset{counter}=dircontent(i).name;
        counter=counter+1;
    end
end
set(hObject,'String',dataset);



function editComments_Callback(hObject, eventdata, handles)
% hObject    handle to editComments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editComments as text
%        str2double(get(hObject,'String')) returns contents of editComments as a double
disp('comments callback')
comment=get(hObject,'String');
save(['data/' handles.parameters.dataset '/' handles.data.name{handles.data.current} '_comment'],'comment');


% --- Executes during object creation, after setting all properties.
function editComments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editComments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderBottomYlow_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBottomYlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
current=get(handles.axesBottom,'YLim');
current(2)=get(hObject,'Value');
set(handles.axesBottom,'YLim',current);
set(handles.sliderBottomYhigh,'Min',current(1));

% --- Executes during object creation, after setting all properties.
function sliderBottomYlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBottomYlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',-1000);

set(hObject,'Max',1000);

% --- Executes on slider movement.
function sliderBottomYhigh_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBottomYhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
current=get(handles.axesBottom,'YLim');
current(2)=get(hObject,'Value');
set(handles.axesBottom,'YLim',current);
set(handles.sliderBottomYlow,'Max',current(2));

% --- Executes during object creation, after setting all properties.
function sliderBottomYhigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBottomYhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',-1000);

set(hObject,'Max',1000);

% --- Executes on slider movement.
function sliderTopYlow_Callback(hObject, eventdata, handles)
% hObject    handle to sliderTopYlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
current=get(handles.axesTop,'YLim');
current(1)=get(hObject,'Value');
set(handles.axesTop,'YLim',current);
set(handles.sliderTopYhigh,'Min',current(1));

% --- Executes during object creation, after setting all properties.
function sliderTopYlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderTopYlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',-1000);

set(hObject,'Max',1000);

% --- Executes on slider movement.
function sliderTopYhigh_Callback(hObject, eventdata, handles)
% hObject    handle to sliderTopYhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
current=get(handles.axesTop,'YLim');
current(2)=get(hObject,'Value');
set(handles.axesTop,'YLim',current);
set(handles.sliderTopYlow,'Max',current(2));

% --- Executes during object creation, after setting all properties.
function sliderTopYhigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderTopYhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',-1000);

set(hObject,'Max',1000);



function editTopYHigh_Callback(hObject, eventdata, handles)
% hObject    handle to editTopYHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTopYHigh as text
%        str2double(get(hObject,'String')) returns contents of editTopYHigh as a double
current=get(handles.axesTop,'YLim');
current(2)= str2double(get(hObject,'String'));
try
    set(handles.axesTop,'YLim',current);
catch
    disp('Invalid Y Axis Limit')
end
set(hObject,'String','')
% --- Executes during object creation, after setting all properties.
function editTopYHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTopYHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTopYLow_Callback(hObject, eventdata, handles)
% hObject    handle to editTopYLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTopYLow as text
%        str2double(get(hObject,'String')) returns contents of editTopYLow as a double
current=get(handles.axesTop,'YLim');
current(1)= str2double(get(hObject,'String'));
try
    set(handles.axesTop,'YLim',current);
catch
    disp('Invalid Y Axis Limit')
    
end
set(hObject,'String','')
% --- Executes during object creation, after setting all properties.
function editTopYLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTopYLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBottomYHigh_Callback(hObject, eventdata, handles)
% hObject    handle to editBottomYHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBottomYHigh as text
%        str2double(get(hObject,'String')) returns contents of editBottomYHigh as a double
current=get(handles.axesBottom,'YLim');
current(2)= str2double(get(hObject,'String'));
try
    set(handles.axesBottom,'YLim',current);
catch
    disp('Invalid Y Axis Limit')
    
end
set(hObject,'String','')
% --- Executes during object creation, after setting all properties.
function editBottomYHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBottomYHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBottomYLow_Callback(hObject, eventdata, handles)
% hObject    handle to editBottomYLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBottomYLow as text
%        str2double(get(hObject,'String')) returns contents of editBottomYLow as a double
current=get(handles.axesBottom,'YLim');
current(1)= str2double(get(hObject,'String'));
try
    set(handles.axesBottom,'YLim',current);
catch
    disp('Invalid Y Axis Limit')
    
end
set(hObject,'String','')

% --- Executes during object creation, after setting all properties.
function editBottomYLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBottomYLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxQRS.
function checkboxQRS_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxQRS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxQRS
value=get(hObject,'Value');

if value
    if isfield(handles.current.param.samplingrate,'ecg')
        
        set(handles.popupmenuTopDisplay,'Enable','off');
        set(handles.popupmenuBottomDisplay,'Enable','off');
        
        outputfile=[handles.parameters.ratingFolder '/' handles.data.name{handles.data.current} '_output.mat'];
        if (exist(outputfile,'file')>0)
            tmp=load(outputfile,'output');
            handles.current.output=tmp.output;
            plotCursors(hObject, eventdata, handles)
        end
        set(handles.uipanelQRSTools,'Visible','on');
        set(handles.pushbuttonSave,'Enable','on');
    else
        disp('Warning: no ECG for labeling QRS');
    end
else
    
    % selection = warndlg(['No data will be saved when Cursors disabled. If you changed the cursor position since the last saving they will be lost.'],...
    %     ['No Cursors ...']);
    set(handles.uipanelQRSTools,'Visible','off');
    set(handles.pushbuttonSave,'Enable','off');
    set(handles.popupmenuTopDisplay,'Enable','on');
    set(handles.popupmenuBottomDisplay,'Enable','on');
    clearAllCursors(hObject, eventdata, handles);
end



% --- Executes on button press in pushbuttonNoiseLabel.
function pushbuttonNoiseLabel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNoiseLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n1=CreateCursorType(handles.setRRGUI,'Artif');



% --- Executes on button press in pushbuttonQRSlabel.
function pushbuttonQRSlabel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonQRSlabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n1=CreateCursorType(handles.setRRGUI,'QRS');


% --- Executes on button press in pushbuttonPlethArtif.
function pushbuttonPlethArtif_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlethArtif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n1=CreateCursorType(handles.setRRGUI,'PlethArtif');

% --- Executes on button press in checkboxPleth.
function checkboxPleth_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPleth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPleth
value=get(hObject,'Value');

if value
    if isfield(handles.current.param.samplingrate,'pleth')
        set(handles.uipanelPleth,'Visible','on');
        set(handles.popupmenuTopDisplay,'Enable','off');
        set(handles.popupmenuBottomDisplay,'Enable','off');
        set(handles.pushbuttonSave,'Enable','on');
        outputfile=[handles.parameters.ratingFolder '/' handles.data.name{handles.data.current} '_output.mat'];
        if (exist(outputfile,'file')>0)
            tmp=load(outputfile,'output');
            handles.current.output=tmp.output;
            plotCursors(hObject, eventdata, handles)
        end
    else
        disp('Warning: no Pleth for labeling PPG');
    end
else
    
    % selection = warndlg(['No data will be saved when Cursors disabled. If you changed the cursor position since the last saving they will be lost.'],...
    %     ['No Cursors ...']);
    set(handles.uipanelPleth,'Visible','off');
    set(handles.pushbuttonSave,'Enable','off');
    set(handles.popupmenuTopDisplay,'Enable','on');
    set(handles.popupmenuBottomDisplay,'Enable','on');
    clearAllCursors(hObject, eventdata, handles);
end

function uipanelButton_SelectionChangeFcn(hObject, eventdata)
%retrieve GUI data, i.e. the handles structure
handles = guidata(hObject);
%reset view
datacursormode off
set(handles.uipanelPleth,'Visible','off');
set(handles.uipanelLabels,'Visible','off');
set(handles.uipanelLabeltools,'Visible','off');
set(handles.pushbuttonSave,'Enable','off');
set(handles.popupmenuTopDisplay,'Enable','off');
set(handles.popupmenuBottomDisplay,'Enable','off');
set(handles.uipanelParam,'Visible','off');
set(handles.uipanelQRSTools,'Visible','off');
set(handles.uipanelQRSshift,'Visible','off');
set(handles.uipanelPlethShift,'Visible','off');
Type='AUC';
DeleteCursorType(Type);

clearAllCursors(hObject, eventdata, handles);



switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'radiobuttonResp'
        
        set(handles.uipanelLabels,'Visible','on');
        set(handles.pushbuttonSave,'Enable','on');
        set(handles.uipanelLabeltools,'Visible','on');
        outputfile=[handles.parameters.ratingFolder '/' handles.data.name{handles.data.current}  '_output.mat' ];
        if (exist(outputfile,'file')>0)
            tmp=load(outputfile);
            handles.current.output=tmp.output;
            plotCursors(hObject, eventdata, handles)
        end
        
        
        % selection = warndlg(['No data will be saved when Cursors disabled. If you changed the cursor position since the last saving they will be lost.'],...
        %     ['No Cursors ...']);
        
    case 'radiobuttonQRS'
        if isfield(handles.current.param.samplingrate,'ecg')
            
            outputfile=[handles.parameters.ratingFolder '/' handles.data.name{handles.data.current} '_output.mat'];
            if (exist(outputfile,'file')>0)
                tmp=load(outputfile,'output');
                handles.current.output=tmp.output;
                plotCursors(hObject, eventdata, handles)
            end
            set(handles.uipanelQRSTools,'Visible','on');
            set(handles.pushbuttonSave,'Enable','on');
            set(handles.uipanelQRSshift,'Visible','on');
        else
            disp('Warning: no ECG for labeling QRS');
        end
    case 'radiobuttonPleth'
        if isfield(handles.current.param.samplingrate,'pleth')
            set(handles.uipanelPleth,'Visible','on');
            set(handles.pushbuttonSave,'Enable','on');
            set(handles.uipanelPlethShift,'Visible','on');
            outputfile=[handles.parameters.ratingFolder '/' handles.data.name{handles.data.current} '_output.mat'];
            if (exist(outputfile,'file')>0)
                tmp=load(outputfile,'output');
                handles.current.output=tmp.output;
                plotCursors(hObject, eventdata, handles)
            end
        else
            disp('Warning: no Pleth for labeling PPG');
        end
    case 'radiobuttonDataCursor'
        set(handles.popupmenuTopDisplay,'Enable','on');
        set(handles.popupmenuBottomDisplay,'Enable','on');
        datacursormode on
    case 'radiobuttonAUC'
        Type='AUC';
        n=CreateCursorType(handles.setRRGUI,Type);
        m=CreateCursorType(handles.setRRGUI,Type);
        set(handles.uipanelParam,'Visible','on');
        
    case 'radiobuttonNone'
        set(handles.popupmenuTopDisplay,'Enable','on');
        set(handles.popupmenuBottomDisplay,'Enable','on');
        
    otherwise
        
end
%updates the handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbuttonShiftQRS.
function pushbuttonShiftQRS_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonShiftQRS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

shiftvalue=str2double(get(handles.num_shift_cursor,'String'));
if isfield (handles.current.param.samplingrate,'ecg')
    if(isfield(handles.current,'output'))
        if(isfield(handles.current.output,'qrs'))
            handles.current.output.qrs.x=handles.current.output.qrs.x+shiftvalue*handles.current.param.samplingrate.ecg;
        end
    end
end
clearAllCursors(hObject, eventdata, handles);
plotCursors(hObject, eventdata, handles);
%updates the handles structure
guidata(hObject, handles);

function num_shift_cursor_Callback(hObject, eventdata, handles)
% hObject    handle to num_shift_cursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_shift_cursor as text
%        str2double(get(hObject,'String')) returns contents of num_shift_cursor as a double


% --- Executes during object creation, after setting all properties.
function num_shift_cursor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_shift_cursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonNearestMax.
function pushbuttonNearestMax_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNearestMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%save
handles=saveLabel(hObject, eventdata, handles);
%reset
%[handles]=LoadandDisplay(hObject, eventdata, handles);

winsize=str2double(get(handles.editNearestMaxWin,'String'));
if isfield (handles.current.param.samplingrate,'ecg')
    if(isfield(handles.current,'output'))
        if(isfield(handles.current.output,'qrs'))
            if isfield(handles.current.data.ecg,'x')
                x=handles.current.data.ecg.x;
            else
                x=1:length(handles.current.data.ecg.y);%./handles.current.param.samplingrate.ecg;
            end
            
            for k=1:length(handles.current.output.qrs.x)
                [a maxidx]=find(x<handles.current.output.qrs.x(k)+winsize/2*handles.current.param.samplingrate.ecg,1,'last');
                [a minidx]=find(x>handles.current.output.qrs.x(k)-winsize/2*handles.current.param.samplingrate.ecg,1,'first');
                [val idx]=max(handles.current.data.ecg.y(minidx:maxidx));
                shiftvalue=idx+minidx-1;
                handles.current.output.qrs.x(k)=(shiftvalue);
            end
        end
    end
end
clearAllCursors(hObject, eventdata, handles);
plotCursors(hObject, eventdata, handles);
%updates the handles structure
guidata(hObject, handles);


function editNearestMaxWin_Callback(hObject, eventdata, handles)
% hObject    handle to editNearestMaxWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNearestMaxWin as text
%        str2double(get(hObject,'String')) returns contents of editNearestMaxWin as a double


% --- Executes during object creation, after setting all properties.
function editNearestMaxWin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNearestMaxWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonPeakPleth.
function pushbuttonPeakPleth_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPeakPleth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n1=CreateCursorType(handles.setRRGUI,'PlethPeak');



% --- Executes on button press in pushbuttonPlethPeakShift.
function pushbuttonPlethPeakShift_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlethPeakShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editPlethpeakShiftWin_Callback(hObject, eventdata, handles)
% hObject    handle to editPlethpeakShiftWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPlethpeakShiftWin as text
%        str2double(get(hObject,'String')) returns contents of editPlethpeakShiftWin as a double


% --- Executes during object creation, after setting all properties.
function editPlethpeakShiftWin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPlethpeakShiftWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonPlethNearestMax.
function pushbuttonPlethNearestMax_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlethNearestMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%save
handles=saveLabel(hObject, eventdata, handles);
%updates the handles structure
guidata(hObject, handles);
%reset
%[handles]=LoadandDisplay(hObject, eventdata, handles);

winsize=str2double(get(handles.editPlethNearestMaxWin,'String'));
if isfield (handles.current.param.samplingrate,'pleth')
    if(isfield(handles.current,'output'))
        if(isfield(handles.current.output,'pleth_peak'))
            if isfield(handles.current.data.pleth,'x')
                x=handles.current.data.pleth.x;
            else
                x=1:length(handles.current.data.pleth.y);%./handles.current.param.samplingrate.ecg;
            end
            
            for k=1:length(handles.current.output.pleth_peak.x)
                [a maxidx]=find(x<handles.current.output.pleth_peak.x(k)+winsize/2*handles.current.param.samplingrate.pleth,1,'last');
                [a minidx]=find(x>handles.current.output.pleth_peak.x(k)-winsize/2*handles.current.param.samplingrate.pleth,1,'first');
                [val idx]=max(handles.current.data.pleth.y(minidx:maxidx));
                shiftvalue=idx+minidx-1;
                handles.current.output.pleth_peak.x(k)=(shiftvalue);
            end
        end
    end
end
clearAllCursors(hObject, eventdata, handles)
plotCursors(hObject, eventdata, handles);
%updates the handles structure
guidata(hObject, handles);


function editPlethNearestMaxWin_Callback(hObject, eventdata, handles)
% hObject    handle to editPlethNearestMaxWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPlethNearestMaxWin as text
%        str2double(get(hObject,'String')) returns contents of editPlethNearestMaxWin as a double


% --- Executes during object creation, after setting all properties.
function editPlethNearestMaxWin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPlethNearestMaxWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
