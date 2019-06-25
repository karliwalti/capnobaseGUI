function varargout = displayVolumeGUI(varargin)
% DISPLAYVOLUMEGUI M-file for displayVolumeGUI.fig
%      DISPLAYVOLUMEGUI, by itself, creates a new DISPLAYVOLUMEGUI or raises the existing
%      singleton*.
%
%      H = DISPLAYVOLUMEGUI returns the handle to a new DISPLAYVOLUMEGUI or the handle to
%      the existing singleton*.
%
%      DISPLAYVOLUMEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISPLAYVOLUMEGUI.M with the given input arguments.
%
%      DISPLAYVOLUMEGUI('Property','Value',...) creates a new DISPLAYVOLUMEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before displayVolumeGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to displayVolumeGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help displayVolumeGUI

% Last Modified by GUIDE v2.5 03-Mar-2010 18:37:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @displayVolumeGUI_OpeningFcn, ...
    'gui_OutputFcn',  @displayVolumeGUI_OutputFcn, ...
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

% --- Executes just before displayVolumeGUI is made visible.
function displayVolumeGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to displayVolumeGUI (see VARARGIN)

% Choose default command line output for displayVolumeGUI
%handles.output = hObject;
assignin('base', 'ShapeGUI', hObject);
checkAxes(hObject,2);
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
    %handles.parameters.outputFolder=['output'];
    %handles.parameters.ratingFolder=['data/' handles.parameters.dataset '/'];
    handles.parameters.outputFolder=['data/' handles.parameters.dataset '/'];
    %handles.parameters.shapeFolder=['data/' handles.parameters.dataset '/'];
    %  handles.parameters.outputFolder=['data/'];
    %     handles.parameters.ratingFolder=['ratings/' (raterID)];
    %     handles.parameters.shapeFolder=['shape/' (raterID)];
    %         handles.parameters.ratingFolder=['data/'];
    %     handles.parameters.shapeFolder=['data/' ];
%    if (~isdir(handles.parameters.ratingFolder))
 %       mkdir(handles.parameters.ratingFolder);
 %   end
    %     if (~isdir(handles.parameters.outputFolder))
    %         mkdir(handles.parameters.outputFolder);
    %     end
    %     if (~isdir(handles.parameters.shapeFolder))
    %         mkdir(handles.parameters.shapeFolder);
    %     end
    % read the data directory
    [handles, counter]=readDataDir(hObject,eventdata,handles);
end

%init shape axis
clearGraph(hObject, eventdata, handles);

if(counter>1)
    handles.parameters.settingFile=['settings/setVolume' num2str(raterID) '.mat'];
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
    
    handles.data.volume='flow';
    handles.data.window=10;
    % Update handles structure
    guidata(hObject, handles);
    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using displayVolumeGUI.
    %if strcmp(get(hObject,'Visible'),'off')
    % initialize current handle structure by loading first data file
    [handles]=LoadandDisplay(hObject, eventdata, handles);
    setVisibilityShape(hObject, eventdata, handles);
    % set first current shape %WK moved inside loadanddisplay
    %init slider
    % [handles]=initZoomSlider(handles);
    %end
else
    set(handles.pushbuttonPrevious,'Enable','off');
    set(handles.pushbuttonNext,'Enable','off');
end
% axes(handles.axesImage);
% pic=imread('image/phases.jpg');
% %pic=imread('image/capnogram_phases.png');
% image(pic);
% axis off
% axis image

% UIWAIT makes displayVolumeGUI wait for user response (see UIRESUME)
% uiwait(handles.displayVolumeGUI);
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = displayVolumeGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = 'rateShapes';


function clearGraph(hObject, eventdata, handles)
axes(handles.axesVolume);
cla;
reset(gca);
ylabel(['pCO2 '],'Rotation',90)
xlabel(['Volume'])
set(handles.axesVolume,'YLim',[0 8]);
set(handles.axesVolume,'XLim',[0 10]);
grid on
%set(handles.pushbuttonAddPhase4,'String','Add Phase IV Marker','Value',0);
%set(handles.pushbuttonPaste,'Enable','off');
%set(handles.popupmenuShapeScale,'Value',3);
handles.data.window=10;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbuttonPrevious.
function pushbuttonPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%save current ratings
%saveShape(hObject, eventdata, handles);

%update current data pointer
handles.data.current=handles.data.current-1;
% Update handles structure
guidata(hObject, handles);
clearGraph(hObject, eventdata, handles);
setVisibility(hObject, eventdata, handles);

%load previous data and ratings
%plot data and ratings
[handles]=LoadandDisplay(hObject, eventdata, handles);
%setVisibilityShape(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%save current ratings
%saveShape(hObject, eventdata, handles);
%update current data pointer
handles.data.current=handles.data.current+1;
% Update handles structure
guidata(hObject, handles);
clearGraph(hObject, eventdata, handles);
setVisibility(hObject, eventdata, handles);

%load next data and ratings
%plot data and ratings
[handles]=LoadandDisplay(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbuttonHelp.
function pushbuttonHelp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
run popupHelp




function [handles]=LoadandDisplay(hObject, eventdata, handles)


% clears labels/cursors
clearAllCursors(hObject, eventdata, handles);
%reset pointer
handles.data.currentShape=0;

%loads new data
%handles.current=load(['data/' handles.data.name{handles.data.current}],'meta','data','param');
%outputfile=[handles.parameters.ratingFolder '/' handles.data.name{handles.data.current} ];

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

if isfield(handles.current, 'output')
handles.current=rmfield(handles.current,'output');
end

%set(handles.signalTitleText,'String',handles.data.name{handles.data.current});
set(handles.displayVolumeGUI,'Name',['1.3 Browse Volumes: ' handles.data.name{handles.data.current}]);
set(handles.popupmenuJump,'Value',handles.data.current);

axes(handles.axesCapnogram);
cla;
plot((1:length(handles.current.data.co2.y))./handles.current.param.samplingrate.co2,handles.current.data.co2.y,'k','Tag','fullCO2');
axis tight
ylabel(['pCO2 [' handles.current.meta.sensor.co2.units ']'],'Rotation',90)
xlabel(['seconds'])

%
%loads the saved output if already stored
try
    
    load(['data/' handles.parameters.dataset '/' handles.data.name{handles.data.current} '_output'],'output');
handles.current.output=output;
catch
  %  handles.current=rmfield(handles.current,'output');
    selection = warndlg('Insp and Exp times have not yet been determined for this dataset. No shapes can be rated. Perform first step 1 on this data.','No Insp and Exp times','modal');
    
end
%[handles]=loadShape(hObject, eventdata, handles);
if isfield(handles.current, 'output')
    if isfield(handles.current.output, 'startexp')
        %set dummy values
        %     handles.current.output.startexp.x(1)=1;
        %     handles.current.output.startexp.x(2)=length(handles.current.data.co2.y);%*handles.current.param.samplingrate;
        
        if length(handles.current.output.startexp.x)>1
            handles.data.currentShape=1;
            CreateCursorType(handles.axesCapnogram,'Exp',handles.current.output.startexp.x(1)./handles.current.param.samplingrate.co2,1);
            CreateCursorType(handles.axesCapnogram,'Exp',handles.current.output.startexp.x(2)./handles.current.param.samplingrate.co2,2);
            [handles]=DisplayShape(hObject, eventdata, handles);
        else
            selection = warndlg('Insp and Exp times have not yet been determined for this dataset. No shapes can be rated.','No Insp and Exp times','modal');
            
        end
    else
        selection = warndlg('Insp and Exp times have not yet been determined for this dataset. No shapes can be rated.','No Insp and Exp times','modal');
        
    end
else
    selection = warndlg('Insp and Exp times have not yet been determined for this dataset. No shapes can be rated. Perform first step 1 on this data.','No Insp and Exp times','modal');
    
end

setVisibilityShape(hObject, eventdata, handles);
% plotCursors(hObject, eventdata, handles)





function [handles]=DisplayShape(hObject, eventdata, handles)

%move cursors

posSE1=handles.current.output.startexp.x(handles.data.currentShape);
posSE2=handles.current.output.startexp.x(handles.data.currentShape+1);
Y=handles.current.data.co2.y(posSE1:posSE2);
X=handles.current.data.flow.y(posSE1:posSE2);
ylimits=get(handles.axesCapnogram,'YLim');

SetCursorLocation(handles.axesCapnogram,1,posSE1./handles.current.param.samplingrate.co2);
SetCursorLocation(handles.axesCapnogram,2,posSE2./handles.current.param.samplingrate.co2);
%line([posSE2./handles.current.param.samplingrate.co2 posSE2./handles.current.param.samplingrate.co2], ylimits)
% handles.data.currentShape

% fix the 2 cursors
FixCursor(handles.axesCapnogram,1);
FixCursor(handles.axesCapnogram,2);

[a b]=find (handles.current.output.startinsp.x>posSE1 & handles.current.output.startinsp.x<posSE2,1,'first' );

if isempty(b)
    %posSI1=(posSE1+posSE2)/2;
    selection = warndlg('No Insp time found. Check in tool 1 for correct annotations.','No Insp time','modal');
    %clearGraph(hObject, eventdata, handles);
    
%     axes(handles.axesVolume);
%     plot((1:length(Y))./handles.current.param.samplingrate.co2,Y,'k','Tag','CO2');
%     ylabel(['pCO2 [' handles.current.meta.sensor.co2.units ']'],'Rotation',90);
%     set(handles.axesVolume,'XLim',[0 handles.data.window]);
    %grid minor
    %set(handles.pushbuttonAddPhase4,'Enable','off');
    %setSingleRating(hObject, eventdata, handles);
    return
else
   posSI1=handles.current.output.startinsp.x(b);
end

axes(handles.axesVolume);
cla;

if exist('posSI1','var')

    Ye=handles.current.data.co2.y(posSE1:posSI1);
    Xe=handles.current.data.flow.y(posSE1:posSI1);  
    Yi=handles.current.data.co2.y(posSI1:posSE2);
    Xi=handles.current.data.flow.y(posSI1:posSE2);

    Vole=cumtrapz(Xe)./25./60;
    Voli=Vole(end)+(cumtrapz(Xi)./25./60);
end

if strcmp(handles.data.volume,'capno')
    if exist('posSI1','var')
    plot(Vole,Ye,'b')
    hold on
    plot(Voli,Yi,'r')
    hold off

else
    plot((cumtrapz(X)./25./60),Y,'k');%./handles.current.param.samplingrate.flow
    end
    ylabel(['pCO2 [' handles.current.meta.sensor.co2.units ']'],'Rotation',90)
     title('Volume-Capnogram')
else
     if exist('posSI1','var')
    plot(Vole,Xe,'b')
    hold on
    plot(Voli,Xi,'r')
    plot(Voli(1),Xi(1),'.r','MarkerSize',20)
    hold off
    text(Voli(1),Xi(1),[' Volume = ',num2str(Voli(1)) ' l'],...
 'VerticalAlignment','top',...
 'HorizontalAlignment','right',...
 'FontSize',14)

else
    plot((cumtrapz(X)./25./60),Y,'k');%./handles.current.param.samplingrate.flow
     end
     ylabel(['Flow [' handles.current.meta.sensor.flow.units ']'],'Rotation',90)
     title('Volume-Flow')
     xlimits=get(gca,'XLim');
     ylimits=get(gca,'YLim');
     
      text(xlimits(1)+mean(xlimits),ylimits(1)+2/3*(ylimits(2)-ylimits(1)),[' \color{blue} Expiration'],...
 'VerticalAlignment','top',...
 'HorizontalAlignment','right',...
 'FontSize',14)
 text(xlimits(1)+mean(xlimits),ylimits(1)+1/3*(ylimits(2)-ylimits(1)),[' \color{red} Inspiration'],...
 'VerticalAlignment','top',...
 'HorizontalAlignment','right',...
 'FontSize',14)
     
end



xlabel(['Volume [l]'])
%set(handles.axesVolume,'YLim',ylimits);

%set(handles.axesVolume,'XLim',[0 handles.data.window]);
%hold on
%try
 %   rectangle('Position',[relPosSE1,ylimits(1),max(relPosSI1,0.001),(ylimits(2)/10)],'FaceColor',[0.871 0.922 0.98], 'EdgeColor','none')
  %  rectangle('Position',[relPosSI1,ylimits(1),max(relPosSE2-relPosSI1,0.001),(ylimits(2)/10)],'FaceColor',[0.992 0.918 0.769], 'EdgeColor','none')
    
   % line([relPosSI1 relPosSI1],ylimits,'Color',[0.992 0.918 0.769] );
    
%catch
%end
%
% hold on
%plot((1:length(Y))./handles.current.param.samplingrate.co2,Y,'k','Tag','CO2');
%hold off
grid on
%grid minor
%set(handles.axesVolume,'YLim',ylimits);
%set(handles.axesVolume,'XLim',[0 handles.data.window]);

%n1=CreateMarkerType(handles.axesVolume, 'P I', 0);
%n0=CreateMarkerType(handles.axesVolume, 'P 0', relPosSI1);
%FixMarker(handles.axesVolume,n1);
%FixMarker(handles.axesVolume,n0);
%place other markers
%setSingleShape(hObject, eventdata, handles);
%setSingleRating(hObject, eventdata, handles);

% % Update handles structure
% guidata(hObject, handles);




% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[handles]=getSingleShape(hObject, eventdata, handles);
saveShape(hObject, eventdata, handles);
% % Update handles structure
guidata(hObject, handles);






function setVisibility(hObject, eventdata, handles)


set(handles.pushbuttonNext,'Enable','on');
set(handles.pushbuttonPrevious,'Enable','on');

if (handles.data.current >= length(handles.data.name))
    set(handles.pushbuttonNext,'Enable','off');
end
if (handles.data.current == 1)
    set(handles.pushbuttonPrevious,'Enable','off');
end

function setVisibilityShape(hObject, eventdata, handles)

set(handles.pushbuttonNextShape,'Enable','off');
set(handles.pushbuttonPreviousShape,'Enable','off');
%set(handles.pushbuttonAddPhase4,'Enable','off');
set(handles.uipanelShapeNav,'Visible','off');
if isfield(handles.data,'currentShape')
    if handles.data.currentShape > 0
        set(handles.pushbuttonNextShape,'Enable','on');
        set(handles.pushbuttonPreviousShape,'Enable','on');
 %       set(handles.pushbuttonAddPhase4,'Enable','on');
        if (handles.data.currentShape >= length(handles.current.output.startexp.x)-1)
            set(handles.pushbuttonNextShape,'Enable','off');
        end
        if (handles.data.currentShape == 1)
            set(handles.pushbuttonPreviousShape,'Enable','off');
        end
    end
end
set(handles.uipanelShapeNav,'Visible','on');


function clearAllCursors(hObject, eventdata, handles)
Cursors=getappdata(handles.displayVolumeGUI, 'VerticalCursors');
for (i=1:length(Cursors))
    DeleteCursor(handles.displayVolumeGUI,i)
end
clear Cursors;


function plotCursors(hObject, eventdata, handles)
set(handles.uipanelNavigation,'Visible','off');
if(isfield(handles.current,'output'))
    if(isfield(handles.current.output,'startinsp'))
        for (i=1:length(handles.current.output.startinsp.x))
            n=CreateCursorType(handles.displayVolumeGUI,'Insp',handles.current.output.startinsp.x(i)./handles.current.param.samplingrate.co2);
            %  SetCursorLocation(handles.displayVolumeGUI,n,handles.current.output.startinsp.x(i)./handles.current.param.samplingrate);
            FixCursor(n);
        end
    end
    if(isfield(handles.current.output,'startexp'))
        for (i=1:length(handles.current.output.startexp.x))
            n=CreateCursorType(handles.displayVolumeGUI,'Exp',handles.current.output.startexp.x(i)./handles.current.param.samplingrate.co2);
            %     SetCursorLocation(handles.displayVolumeGUI,n,handles.current.output.startexp.x(i)./handles.current.param.samplingrate)
            FixCursor(n);
        end
    end
end
set(handles.uipanelNavigation,'Visible','on');


% --- Executes on button press in pushbuttonNextShape.
function pushbuttonNextShape_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNextShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.uipanelShapeNav,'Visible','off');
%[handles]=getSingleShape(hObject, eventdata, handles);
handles.data.currentShape=max(min(handles.data.currentShape+1,length(handles.current.output.startexp.x)-1),1);
setVisibilityShape(hObject, eventdata, handles);
[handles]=DisplayShape(hObject, eventdata, handles);
set(handles.uipanelShapeNav,'Visible','on');
% % Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbuttonPreviousShape.
function pushbuttonPreviousShape_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPreviousShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.uipanelShapeNav,'Visible','off');
%[handles]=getSingleShape(hObject, eventdata, handles);
handles.data.currentShape=max(handles.data.currentShape-1,1);
setVisibilityShape(hObject, eventdata, handles);
[handles]=DisplayShape(hObject, eventdata, handles);
set(handles.uipanelShapeNav,'Visible','on');
% % Update handles structure
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



function ClearAllMarkerType(hObject, eventdata, handles,Type)
Cursors=getappdata(handles.axesVolume, 'VerticalMarkers');
for (i=1:length(Cursors))
    if isstruct(Cursors{i})
        if strcmp(Cursors{i}.Type,Type)
            DeleteMarker(handles.axesVolume,i);
        end
    end
end
clear Cursors;

% --- Executes on selection change in popupmenuShapeScale.
function popupmenuShapeScale_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuShapeScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuShapeScale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuShapeScale

windowlength=get(hObject,'Value');
switch windowlength
    
    case 4
        handles.data.window=8;
        % break;
    case 3
        handles.data.window=10;
        % break;
    case 2
        handles.data.window=12;
        % break;
    case 1
        shapelength=handles.current.output.startexp.x(handles.data.currentShape+1)-handles.current.output.startexp.x(handles.data.currentShape);
        
        handles.data.window=shapelength./handles.current.param.samplingrate.co2;
        % break:
end
% set(handles.sliderZoom,'Value',handles.data.window/2);
% set(handles.sliderZoom,'Min',handles.data.window/2);
% set(handles.sliderZoom,'Max',max(length(handles.current.data.co2.y)./handles.current.param.samplingrate.co2-handles.data.window/2,handles.data.window/2+1));
% set(handles.sliderZoom,'SliderStep',[0.05 1]);




set(handles.axesVolume,'XLim', [0 handles.data.window]);



% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popupmenuShapeScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuShapeScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


% --- Executes on button press in togglebuttonVolume.
function togglebuttonVolume_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonVolume
if get(hObject,'Value')
 set(hObject,'String','Flow-Volume ')
  handles.data.volume='capno';
  [handles]=DisplayShape(hObject, eventdata, handles);
else
 set(hObject,'String','Volume Capnogram')
handles.data.volume='flow';
[handles]=DisplayShape(hObject, eventdata, handles);
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function togglebuttonVolume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to togglebuttonVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','Volume Capnogram')
handles.data.volume='flow';
% Update handles structure
guidata(hObject, handles);