function varargout = Start(varargin)
% START M-file for Start.fig
%      START by itself, creates a new START or raises the
%      existing singleton*.
%
%      H = START returns the handle to a new START or the handle to
%      the existing singleton*.
%
%      START('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in START.M with the given input arguments.
%
%      START('Property','Value',...) creates a new START or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Start_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Start_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Start

% Last Modified by GUIDE v2.5 16-Feb-2010 18:46:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Start_OpeningFcn, ...
    'gui_OutputFcn',  @Start_OutputFcn, ...
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

% --- Executes just before Start is made visible.
function Start_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Start (see VARARGIN)

% Choose default command line output for Start
%handles.output = 'Yes';

% Update handles structure
%guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
% if(nargin > 3)
%     for index = 1:2:(nargin-3),
%         if nargin-3==index, break, end
%         switch lower(varargin{index})
%          case 'title'
%           set(hObject, 'Name', varargin{index+1});
%          case 'string'
%           set(handles.textInstructions, 'String', varargin{index+1});
%         end
%     end
% end

set(handles.ToDo_buttongroup,'Visible','off');
%set(handles.pushbuttonStart,'Enable','off');
% buttongroup selection
%set(handles.ToDo_buttongroup,'SelectionChangeFcn',@ToDo_buttongroup_SelectionChangeFcn);



%end
axes(handles.axesLogo);
pic=imread('ecem.jpg');
%pic=imread('image/capnogram_phases.png');
image(pic);
axis off
axis image


% Update handles structure
guidata(hObject, handles);



% Make the GUI modal
%set(handles.popupFigure,'WindowStyle','modal')

% UIWAIT makes Start wait for user response (see UIRESUME)
%uiwait(handles.popupFigure);

function id=askRaterID()
selection = inputdlg({'Enter Your Rater ID'},...
    ['Rater ID ...'],...
    1);

id=selection{1};


% --- Outputs from this function are returned to the command line.
function varargout = Start_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = 'END';%handles.output;

% The figure can be deleted now
%delete(handles.popupFigure);

% % --- Executes on button press in pushbuttonStart.
% function pushbuttonStart_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbuttonStart (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%
% %handles.output = get(hObject,'String');
%
% %take rater ID and prepare for new folder
% idfolder=get(handles.editIDField,'String');
% ratingfolder=['ratings/' idfolder];
% %write rating folder for new rater
% if (~isdir(ratingfolder))
%     mkdir(ratingfolder);
% end
%
% ratingfolder=['output/' idfolder];
% %write output folder for new rater
% if (~isdir(ratingfolder))
%     mkdir(ratingfolder);
% end
% raterID=get(handles.editIDField,'String');
% eval(handles.launch);
% % Update handles structure
% guidata(hObject, handles);
% % Use UIRESUME instead of delete because the OutputFcn needs
% % to get the updated handles structure.
% %uiresume(handles.popupFigure);



% % --- Executes when user attempts to close popupFigure.
function popupFigure_CloseRequestFcn(hObject, eventdata, handles)
% % hObject    handle to popupFigure (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%
% if isequal(get(hObject, 'waitstatus'), 'waiting')
%     % The GUI is still in UIWAIT, us UIRESUME
%     uiresume(hObject);
% else
%     % The GUI is no longer waiting, just close it
%

selection = questdlg(['Quit CapnoBase Rater Tool and all associated windows without saving?'],...
    ['Quit ' get(handles.popupFigure,'Name') '...'],...
    'Quit & save','Quit without saving','Cancel','Quit & save');
if strcmp(selection,'Cancel')
    return;
elseif strcmp(selection,'Quit & save')
    
    if evalin('base','exist(''mGUI'',''var'')')
       temphandles= evalin('base','guidata(mGUI)');
        err=saveMeta(temphandles);
        if err~=0
            popupError(err);
        end
    elseif evalin('base','exist(''rGUI'',''var'')')
        temphandles= evalin('base','guidata(rGUI)');
        err=saveRating(temphandles);
        if err~=0
            popupError(err);
        end
    elseif evalin('base','exist(''EtCO2GUI'',''var'')')
        temphandles= evalin('base','guidata(EtCO2GUI)');
        saveMarkerLabel(temphandles);
        
    elseif evalin('base','exist(''RRGUI'',''var'')')
        temphandles= evalin('base','guidata(RRGUI)');
        saveCursorLabel(temphandles);
%     else
%         disp('Warning: Selected "save & close" but nothing to save.')
    end
end
evalin('base',' var=whos(''-regexp'', ''GUI''); for i=1:length(var); if ishandle(eval(var(i).name))  ; delete(eval(var(i).name)); end; end;');
evalin('base', 'clear all')
delete(handles.popupFigure);
%
% end


% % --- Executes on key press over popupFigure with no controls selected.
% function popupFigure_KeyPressFcn(hObject, eventdata, handles)
% % hObject    handle to popupFigure (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%
% % Check for "enter" or "escape"
% if isequal(get(hObject,'CurrentKey'),'escape')
%     % User said no by hitting escape
%     handles.output = 'No';
%
%     % Update handles structure
%     guidata(hObject, handles);
%
%     uiresume(handles.popupFigure);
% end
%
% if isequal(get(hObject,'CurrentKey'),'return')
%     uiresume(handles.popupFigure);
% end
%


% function editIDField_Callback(hObject, eventdata, handles)
% % hObject    handle to editIDField (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%
% % Hints: get(hObject,'String') returns contents of editIDField as text
% %        str2double(get(hObject,'String')) returns contents of editIDField as a double
% set(handles.ToDo_buttongroup,'Visible','on');
% %set(handles.pushbuttonStart,'Enable','on');
% % set default selection
%  handles.launch=['setRRGUI(raterID)'];
%  % Update handles structure
%     guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editIDField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIDField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.



if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% function ToDo_buttongroup_SelectionChangeFcn(hObject, eventdata)
%
% %retrieve GUI data, i.e. the handles structure
% handles = guidata(hObject);
% % ID=get(handles.editIDField,'String');
%
% switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
%     case 'radiobuttonInspExp'
%       %execute this code when fontsize08_radiobutton is selected
%       handles.launch=['setRRGUI(raterID)'];
%
%     case 'radiobuttonEtInsp'
%       %execute this code when fontsize12_radiobutton is selected
%     handles.launch=['setEtCO2GUI(raterID)'];
%
%     case 'radiobuttonTrendEvent'
%       %execute this code when fontsize16_radiobutton is selected
%          handles.launch=['ratingGUI(raterID)'];
%    case 'radiobuttonShapes'
%       %execute this code when fontsize16_radiobutton is selected
%          handles.launch=['rateShapeGUI(raterID)'];
%     otherwise
%        % Code for when there is no match.
%
% end
% %updates the handles structure
% guidata(hObject, handles);


% --- Executes on selection change in popupmenuSelect.
function popupmenuSelect_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSelect


switch get(hObject,'Value')
    case 4
        
        handles.launch=['setRRGUI({raterID},menuFigure,current,dataset)'];
        
    case 5
        
        handles.launch=['setEtCO2GUI({raterID},menuFigure,current,dataset)'];
    case 2
        handles.launch=['metaGUI({raterID},menuFigure,current,dataset)'];
    case 6
        handles.launch=['displayVolumeGUI({raterID},menuFigure,current,dataset)'];
    case 8
        
        handles.launch=['ratingGUI({raterID},menuFigure,current,dataset)'];
        %    case 9
        %
        %          handles.launch=['rateShapeGUI({raterID},menuFigure,current,dataset)'];
    otherwise
        % Code for when there is no match.
        handles.launch=[];
        
end
%updates the handles structure
guidata(hObject, handles);

if ~isempty(handles.launch)
    %take rater ID and prepare for new folder
    idfolder=get(handles.editIDField,'String');
    %ratingfolder=['ratings/' idfolder];
    %write rating folder for new rater
    %if (~isdir(ratingfolder))
    %    mkdir(ratingfolder);
    %end
    
    %ratingfolder=['output/' idfolder];
    %write output folder for new rater
    %if (~isdir(ratingfolder))
    %    mkdir(ratingfolder);
    %end
    contents = get(handles.popupmenuDataset,'String');
    assignin('base', 'dataset', contents{get(handles.popupmenuDataset,'Value')}); %TODO
    assignin('base', 'raterID', num2str(get(handles.editIDField,'String')));
    assignin('base', 'menuFigure', handles.popupFigure)
    assignin('base', 'current', 1)
    
    returnval = evalin('base',handles.launch);
end

% Update handles structure
%guidata(hObject, handles);






% --- Executes on button press in pushbuttonEnd.
function pushbuttonEnd_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (seedelete(handles.popupFigure); GUIDATA)
popupFigure_CloseRequestFcn(hObject, eventdata, handles)
% selection = questdlg(['Close CapnoBase Signal Evaluation Tool (and all associated windows without saving)?'],...
%     ['Close ' get(handles.popupFigure,'Name') '...'],...
%     'Yes','No','Yes');
% if strcmp(selection,'No')
%     return;
% end
% evalin('base',' var=whos(''-regexp'', ''GUI''); for i=1:length(var); if ishandle(eval(var(i).name))  ; delete(eval(var(i).name)); end; end;');
% 
% evalin('base', 'clear all')
% 
% 
% delete(handles.popupFigure);



% --- Executes on button press in pushbuttonStart.
function pushbuttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

id = askRaterID();
%while strcmp(id,'')
if strcmp(id,'')
    selection = errordlg('You need to give a valid Rater ID','!! Warning !!')
    if ~exist('selection','var')
        id = askRaterID();
        clear selection
    end
    
elseif ~ischar(id)
    
    selection = errordlg('The Rater ID seems to be not valid!','!! Warning !!')
else
    set(handles.ToDo_buttongroup,'Visible','on');
    set(handles.editIDField,'String',id)
    
end


% --- Executes on selection change in popupmenuDataset.
function popupmenuDataset_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuDataset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuDataset

var=evalin('base',' whos(''-regexp'', ''GUI'')');
if length(var)>0
    selection = questdlg(['Changing the dataset will close all open task windows. Do you want to continue?'],...
        ['Work with new dataset'],...
             'Close & save','Close without saving','Cancel','Close & save');
if strcmp(selection,'Cancel')
    return;
elseif strcmp(selection,'Close & save')
    
  if evalin('base','exist(''mGUI'',''var'')')
       temphandles= evalin('base','guidata(mGUI)');
        err=saveMeta(temphandles);
        if err~=0
            popupError(err);
        end
    elseif evalin('base','exist(''rGUI'',''var'')')
        temphandles= evalin('base','guidata(rGUI)');
        err=saveRating(temphandles);
        if err~=0
            popupError(err);
        end
    elseif evalin('base','exist(''EtCO2GUI'',''var'')')
        temphandles= evalin('base','guidata(EtCO2GUI)');
        saveMarkerLabel(temphandles);
        
    elseif evalin('base','exist(''RRGUI'',''var'')')
        temphandles= evalin('base','guidata(RRGUI)');
        saveCursorLabel(temphandles);
%     else
%         disp('Warning: Selected "save & close" but nothing to save.')
    end
end
    evalin('base',' var=whos(''-regexp'', ''GUI''); for i=1:length(var); if ishandle(eval(var(i).name))  ; delete(eval(var(i).name));  clear(var(i).name); end; end;');
end
contents = get(hObject,'String');
     
disp(['Info: Dataset is now "' contents{get(hObject,'Value')} '".' ] );

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

function editNewDataset_Callback(hObject, eventdata, handles)
% hObject    handle to editNewDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNewDataset as text
%        str2double(get(hObject,'String')) returns contents of editNewDataset as a double


% --- Executes during object creation, after setting all properties.
function editNewDataset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNewDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonNewDataset.
function pushbuttonNewDataset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNewDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newfoldername=get(handles.editNewDataset,'String')
mkdir(['data/' newfoldername])

fillpopupmenuDataset(handles.popupmenuDataset);
