function varargout = metaGUI(varargin)
% METAGUI M-file for metaGUI.fig
%      METAGUI, by itself, creates a new METAGUI or raises the existing
%      singleton*.
%
%      H = METAGUI returns the handle to a new METAGUI or the handle to
%      the existing singleton*.
%
%      METAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in METAGUI.M with the given input arguments.
%
%      METAGUI('Property','Value',...) creates a new METAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before metaGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to metaGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help metaGUI

% Last Modified by GUIDE v2.5 19-Feb-2010 15:22:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @metaGUI_OpeningFcn, ...
    'gui_OutputFcn',  @metaGUI_OutputFcn, ...
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

% --- Executes just before metaGUI is made visible.
function metaGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to metaGUI (see VARARGIN)

% Choose default command line output for setRRGUI
%handles.output =
assignin('base', 'mGUI', hObject);
checkAxes(hObject,1);
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
    % handles.parameters.ratingFolder=['data'];
    handles.parameters.ratingFolder=['data/' handles.parameters.dataset '/'];
    
    if (~isdir(handles.parameters.ratingFolder))
        mkdir(handles.parameters.ratingFolder);
    end
    
    % save the changes to the structure
    guidata(hObject,handles)
    
    [handles, counter]=readDataDir(hObject,eventdata,handles);
    
end

if(counter>1)
    handles.parameters.settingFile=['settings/setMeta' num2str(raterID) '.mat'];
    handles.data.current=1; % set pointer to first
    if exist(handles.parameters.settingFile,'file')
        
        load (handles.parameters.settingFile)
        if (current<=counter)
            handles.data.current=current;
        end
        
    end
    setVisibility(hObject, eventdata, handles);
    
    
    %     % Update handles structure
    %     guidata(hObject, handles);
    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using setRRGUI.
    if strcmp(get(hObject,'Visible'),'off')
        % initialize current handle structure by loading first data file
        [handles]=LoadandDisplay(handles);
        
        %init slider
        [handles]=initZoomSlider(handles);
    end
else
    set(handles.pushbuttonPrevious,'Enable','off');
    set(handles.pushbuttonNext,'Enable','off');
end

% save the changes to the structure
guidata(hObject,handles)

% UIWAIT makes Start wait for user response (see UIRESUME)
% uiwait(handles.metaGUI);


% --- Outputs from this function are returned to the command line.
function varargout = metaGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
varargout{1} = 'Meta';

% The figure can be deleted now
%delete(handles.metaGUI);



% --- Executes when user attempts to close popupFigure.
function metaGUI_CloseRequestFcn(hObject, eventdata, handles)
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



% --- Executes on button press in pushbuttonPrevious.
function pushbuttonPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%save current ratings

err=saveMeta(handles);
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
    run popupError(err);
end

% save the changes to the structure
guidata(hObject,handles)


% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%save current ratings
err=saveMeta(handles);
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
    run popupError(err);
end
% save the changes to the structure
guidata(hObject,handles)




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
%[handles]=clearAllMarkers(handles);

%loads new data

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
set(handles.metaGUI,'Name',['0.1 Edit Metadata: ' handles.data.name{handles.data.current}]);
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
%handles.current.rating.events=[];

[handles]=fillForm(handles);


% set(handles.uipanelNavigation, 'Enable','on');
% Update handles structure
%guidata(hObject, handles);



function [handles]=fillForm(handles)


%fill all text form filds,

strfnames=fieldnames(handles);
idx = strncmp(strfnames', 'edit_', 5);

for k=find(idx)
    
    namefields = regexp(strfnames(k), '_', 'split');
    name='';
    for i=2:length(namefields{1})-1
        
        name=[name '.' char(namefields{1}(i))];
    end
    % name(1)=[];
    strucname=name;
    name=[name '.' char(namefields{1}(i+1))]; %add last field
    try
        if isstruct(eval(['handles.current' strucname]))
            if(isfield(eval(['handles.current' strucname]),char(namefields{1}(i+1))))
                eval(['set(handles.(char(strfnames(k))),''String'', handles.current' name ');'])
            end
        end
    catch
    end
end


% the same for jumpMenues
idx = strncmp(strfnames', 'popupForm', 9);

for k=find(idx)
    
    
    namefields = regexp(strfnames(k), '_', 'split');
    name='';
    for i=2:length(namefields{1})-1
        
        name=[name '.' char(namefields{1}(i))];
    end
    % name(1)=[];
    strucname=name;
    name=[name '.' char(namefields{1}(i+1))]; %add last field
    
    
    %try
    if isstruct(eval(['handles.current' strucname]))
        if(isfield(eval(['handles.current' strucname]),char(namefields{1}(i+1))))
            eval(['contents = get(handles.( char(strfnames(k))),''String'');'] )
            value=eval(['handles.current' name]);
            idx= find(strcmp(contents,value));
            if ~isempty(idx)
                eval(['set(handles.(char(strfnames(k))),''Value'', idx);'])
            end
        end
    end
    %catch
    %end
end

try
    set(handles.checkboxCuff,'Value',handles.current.meta.treatment.cuff)
catch
end


% function [handles]=loadMeta(handles)
%
% outputfile=[handles.parameters.ratingFolder '/' handles.data.name{handles.data.current} ];
%
% %loads the saved output if already stored
% if (exist(outputfile,'file')>0)
%     tmp=load(outputfile,'rating');
%     handles.current.rating=tmp.rating;
%     if isstruct(handles.current.rating.events)
%         eventFields=fieldnames(handles.current.rating.events);
%         for i=1:length(eventFields)
%
%             set(handles.(['checkbox_' eventFields{i}]),'Value',handles.current.rating.events.(eventFields{i}).present);
%             if handles.current.rating.events.(eventFields{i}).present>0
%
%
%             end
%         end
%     end
%     if isfield(handles.current.rating,'trend')
%         if isstruct(handles.current.rating.trend)
%             trendFields=fieldnames(handles.current.rating.trend);
%             for i=1:length(trendFields)
%
%                 set(handles.(['radiobuttonTrend_' trendFields{i} '_' num2str(handles.current.rating.trend.(trendFields{i}))]),'Value',1);
%
%             end
%         end
%     end
%     if isfield(handles.current.rating,'comment')
%         set(handles.editRaterComment,'String',handles.current.rating.comment);
%     end
%
% else
%     XLim=get(gca,'XLim');
%
% end
%
% %updates the handles structure
% %guidata(hObject, handles);





function resetGUI(hObject, eventdata, handles)

%fill all text form filds,

strfnames=fieldnames(handles);
idx = strncmp(strfnames', 'edit_', 5);

for k=find(idx)
    
    try
        eval(['set(handles.(char(strfnames(k))),''String'', '''');'])
    catch
    end
end


% the same for jumpMenues
idx = strncmp(strfnames', 'popupForm', 9);

for k=find(idx)
    
    try
        eval(['set(handles.(char(strfnames(k))),''Value'', 1);'])
    catch
    end
end
% set(handles.(['radiobuttonTrend_etco2_0']),'Value',1);
% set(handles.(['radiobuttonTrend_rr_0']),'Value',1);
% set(handles.(['radiobuttonTrend_inspco2_0']),'Value',1);
%
% set(handles.editRaterComment,'String','');

% save the changes to the structure
guidata(hObject,handles)



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



% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveMeta(handles);







% --- Executes during object creation, after setting all properties.
function editComment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit_param_samplingrate_co2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_samplingrate_co2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_meta_sensor_co2_model_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_sensor_co2_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_meta_sensor_co2_manufacturer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_sensor_co2_manufacturer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_meta_sensor_co2_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_sensor_co2_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_meta_subject_weight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_subject_weight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit_meta_subject_age_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_subject_age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit_meta_comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edit_meta_credits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_credits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupForm_meta_treatment_ventilation.
function popupForm_meta_treatment_ventilation_Callback(hObject, eventdata, handles)
% hObject    handle to popupForm_meta_treatment_ventilation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupForm_meta_treatment_ventilation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupForm_meta_treatment_ventilation
contents = get(hObject,'String') ;
handles.current.meta.treatment.ventilation= contents{get(hObject,'Value')};

%updates the handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupForm_meta_treatment_ventilation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupForm_meta_treatment_ventilation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupForm_meta_treatment_delivery.
function popupForm_meta_treatment_delivery_Callback(hObject, eventdata, handles)
% hObject    handle to popupForm_meta_treatment_delivery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupForm_meta_treatment_delivery contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupForm_meta_treatment_delivery

contents = get(hObject,'String') ;
handles.current.meta.treatment.delivery= contents{get(hObject,'Value')};

%updates the handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupForm_meta_treatment_delivery_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupForm_meta_treatment_delivery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit_param_samplingrate_pressure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_samplingrate_pressure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edit_meta_sensor_pressure_model_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_sensor_pressure_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_meta_sensor_pressure_manufacturer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_sensor_pressure_manufacturer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_meta_sensor_pressure_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_sensor_pressure_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function edit_param_samplingrate_flow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_samplingrate_flow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function edit_meta_sensor_flow_model_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_sensor_flow_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edit_meta_sensor_flow_manufacturer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_sensor_flow_manufacturer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edit_meta_sensor_flow_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_sensor_flow_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_param_offset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_param_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_param_offset as text
%        str2double(get(hObject,'String')) returns contents of edit_param_offset as a double


% --- Executes during object creation, after setting all properties.
function edit_param_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_param_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_meta_treatment_comments_Callback(hObject, eventdata, handles)
% hObject    handle to edit_meta_treatment_comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_meta_treatment_comments as text
%        str2double(get(hObject,'String')) returns contents of edit_meta_treatment_comments as a double


% --- Executes during object creation, after setting all properties.
function edit_meta_treatment_comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_treatment_comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupForm_meta_subject_gender.
function popupForm_meta_subject_gender_Callback(hObject, eventdata, handles)
% hObject    handle to popupForm_meta_subject_gender (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupForm_meta_subject_gender contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupForm_meta_subject_gender
contents = get(hObject,'String') ;
handles.current.meta.subject.gender= contents{get(hObject,'Value')};

%updates the handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupForm_meta_subject_gender_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupForm_meta_subject_gender (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonLoad.
function pushbuttonLoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filepath=get(handles.editLoadPath,'String');
error=0;
if exist(filepath,'file')
    [pathstr, name, ext, versn] = fileparts(filepath) ;
    switch ext
        case '.mat'
            newData=load (filepath);
            if isfield(newData,'data') %& isfield(newData,'param')
                [handles error]=makeNewEntry(hObject,eventdata,handles,newData,get(handles.editLoadName,'String'));
            else
                selection = warndlg('The mat file did not contain a "data" and "param" field. Data was not imported.','Wrong file content.')
                
            end
        case '.csv'
            importData = importdata(filepath);
            for i=1:length(importData.textdata)
                newData.data.(importData.textdata{i}).y=importData.data(i,:);
                newData.param.samplingrate.(importData.textdata{i})=10;
            end
            [handles error]=makeNewEntry(hObject,eventdata,handles,newData,get(handles.editLoadName,'String'));
            selection = warndlg('The samplingrate has been set to default 10 Hz.','Could not automatically determine the sampling rate')
        otherwise
            selection = warndlg('Wrong file format. Data was not imported.','Wrong format')
            
    end
    
end
if error>0
    selection = warndlg('There was an unexpected error importing your data. Please see the terminal for additional information.','Import Error')
else
    selection = warndlg('The data has been imported. Please enter the missing information now.','Import Success')
    
end
% --- Executes on button press in pushbuttonBrowse.
function pushbuttonBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile({'*.mat';'*.csv'},'Select the File to import');

set(handles.editLoadPath,'String',[PathName FileName]);

function editLoadPath_Callback(hObject, eventdata, handles)
% hObject    handle to editLoadPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLoadPath as text
%        str2double(get(hObject,'String')) returns contents of editLoadPath as a double


% --- Executes during object creation, after setting all properties.
function editLoadPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLoadPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLoadName_Callback(hObject, eventdata, handles)
% hObject    handle to editLoadName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLoadName as text
%        str2double(get(hObject,'String')) returns contents of editLoadName as a double


% --- Executes during object creation, after setting all properties.
function editLoadName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLoadName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [handles error]=makeNewEntry(hObject,eventdata,handles,datastructure,name)

error=1;
try
    data=datastructure.data;
    data.id=name;
    if isfield(datastructure,'param')
        param=datastructure.param;
    else
        run initparam
    end
    param.id=name;
    if isfield(datastructure,'meta')
        meta=datastructure.meta;
    else
        run initmeta
    end
    
    %create new subdirectory
    mkdir(['data/' handles.parameters.dataset '/' name]);
    
    save(['data/' handles.parameters.dataset '/' name '/' name '_signal'],'data');
    save(['data/' handles.parameters.dataset '/' name '/' name '_param'],'param');
    save(['data/' handles.parameters.dataset '/' name '/' name '_meta'],'meta');
    [handles, counter]=readDataDir(hObject,eventdata,handles);
    
    idx=find(strcmp(handles.data.name,[name '/' name] ));
    if ~isempty(idx)
        handles.data.current=idx;
    end
    setVisibility(hObject, eventdata, handles);
    
    % initialize current handle structure by loading first data file
    [handles]=LoadandDisplay(handles);
    
    %init slider
    [handles]=initZoomSlider(handles);
    error=0;
catch
    error=1;
end


% --- Executes on selection change in popupForm_meta_sensor_pressure_units.
function popupForm_meta_sensor_co2_units_Callback(hObject, eventdata, handles)
% hObject    handle to popupForm_meta_sensor_pressure_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupForm_meta_sensor_pressure_units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupForm_meta_sensor_pressure_units
contents = get(hObject,'String') ;
handles.current.meta.sensor.co2.units= contents{get(hObject,'Value')};

%updates the handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupForm_meta_sensor_co2_units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupForm_meta_sensor_pressure_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popupForm_meta_sensor_pressure_units.
function popupForm_meta_sensor_pressure_units_Callback(hObject, eventdata, handles)
% hObject    handle to popupForm_meta_sensor_pressure_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupForm_meta_sensor_pressure_units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupForm_meta_sensor_pressure_units
contents = get(hObject,'String') ;
handles.current.meta.sensor.pressure.units= contents{get(hObject,'Value')};

%updates the handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupForm_meta_sensor_pressure_units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupForm_meta_sensor_pressure_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupForm_meta_sensor_flow_units.
function popupForm_meta_sensor_flow_units_Callback(hObject, eventdata, handles)
% hObject    handle to popupForm_meta_sensor_flow_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupForm_meta_sensor_flow_units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupForm_meta_sensor_flow_units
contents = get(hObject,'String') ;
handles.current.meta.sensor.flow.units= contents{get(hObject,'Value')};

%updates the handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popupForm_meta_sensor_flow_units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupForm_meta_sensor_flow_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_meta_treatment_procedure_Callback(hObject, eventdata, handles)
% hObject    handle to edit_meta_treatment_procedure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_meta_treatment_procedure as text
%        str2double(get(hObject,'String')) returns contents of edit_meta_treatment_procedure as a double


% --- Executes during object creation, after setting all properties.
function edit_meta_treatment_procedure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_meta_treatment_procedure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonCopyMeta.
function pushbuttonCopyMeta_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCopyMeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=grabForm(handles);
handles.clipboard.meta=handles.current.meta;
set(handles.pushbuttonPasteMeta,'Enable','on')
%updates the handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbuttonPasteMeta.
function pushbuttonPasteMeta_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPasteMeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg(['Overwrite the current metadata?'],...
    ['Paste Meta ' '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end
handles.current.meta=handles.clipboard.meta;
[handles]=fillForm(handles);

%updates the handles structure
guidata(hObject, handles);


% --- Executes on button press in checkboxCuff.
function checkboxCuff_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxCuff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxCuff



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
