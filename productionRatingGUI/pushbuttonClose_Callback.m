
% --- Executes on button press in pushbuttonClose.
function pushbuttonClose_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close this tool window?'],...
    ['Close window...'],...
    'Save & close','Close without saving','Cancel','Save & close');

if strcmp(selection,'Cancel')
    return;
elseif strcmp(selection,'Close without saving')
    
    assignin('base','closinghandle',handles.thisGUI)
    evalin('base',' var=whos(''-regexp'', ''GUI''); for i=1:length(var); if eval(var(i).name)==closinghandle  ; delete(eval(var(i).name)); clear(var(i).name); end; end;');
    %             delete(handles.thisGUI);
elseif strcmp(selection,'Save & close')
    
    if isfield(handles,'metaGUI')
        err=saveMeta(handles);
        if err~=0
            popupError(err);
        end
    elseif isfield(handles,'ratingGUI')
        err=saveRating(handles);
        if err~=0
            popupError(err);
        end
    elseif isfield(handles,'setEtCO2GUI')
        saveMarkerLabel(handles);
        
    elseif isfield(handles,'setRRGUI')
        saveCursorLabel(handles);
    else
        disp('Warning: Selected "save & close" but nothing to save.')
    end
    
    assignin('base','closinghandle',handles.thisGUI)
    evalin('base',' var=whos(''-regexp'', ''GUI''); for i=1:length(var); if eval(var(i).name)==closinghandle  ; delete(eval(var(i).name)); clear(var(i).name); end; end;');
    
end
