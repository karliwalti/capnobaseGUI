function varargout = popupHelp(varargin)
% POPUPHELP M-file for popupHelp.fig
%      POPUPHELP by itself, creates a new POPUPHELP or raises the
%      existing singleton*.
%
%      H = POPUPHELP returns the handle to a new POPUPHELP or the handle to
%      the existing singleton*.
%
%      POPUPHELP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POPUPHELP.M with the given input arguments.
%
%      POPUPHELP('Property','Value',...) creates a new POPUPHELP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before popupHelp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to popupHelp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help popupHelp

% Last Modified by GUIDE v2.5 02-Nov-2009 11:27:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @popupHelp_OpeningFcn, ...
                   'gui_OutputFcn',  @popupHelp_OutputFcn, ...
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

% --- Executes just before popupHelp is made visible.
function popupHelp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to popupHelp (see VARARGIN)

% Choose default command line output for popupHelp
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

checkAxes(hObject,0);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.textInstructions, 'String', varargin{index+1});
        end
    end
end





% Make the GUI modal
set(handles.popupFigure,'WindowStyle','modal')

% UIWAIT makes popupHelp wait for user response (see UIRESUME)
uiwait(handles.popupFigure);

% --- Outputs from this function are returned to the command line.
function varargout = popupHelp_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.popupFigure);

% --- Executes on button press in pushbuttonClose.
function pushbuttonClose_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');


% Update handles structure
guidata(hObject, handles);
% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.popupFigure);



% --- Executes when user attempts to close popupFigure.
function popupFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to popupFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    
    delete(hObject);
   
end


% --- Executes on key press over popupFigure with no controls selected.
function popupFigure_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to popupFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.popupFigure);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.popupFigure);
end    



function editIDField_Callback(hObject, eventdata, handles)
% hObject    handle to editIDField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIDField as text
%        str2double(get(hObject,'String')) returns contents of editIDField as a double


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
