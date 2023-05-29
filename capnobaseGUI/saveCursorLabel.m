
function saveCursorLabel(hObject, eventdata, handles)
try
    if isfield(handles.current,'output')
        output=handles.current.output;
    end
     if get(handles.checkboxCursors,'Value') %Markers enabled
    output.startinsp.x=round(GetAllCursorLocations('Insp').*handles.current.param.samplingrate.co2);
    output.startexp.x=round(GetAllCursorLocations('Exp').*handles.current.param.samplingrate.co2);
    output.endexpflow.x=round(GetAllCursorLocations('Eflow').*handles.current.param.samplingrate.co2);
    output.rater=get(handles.editID,'String');
    save([handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_output'],'output');
    disp('Success: Annotations saved.');
    else
         disp('Info: No annotations saved because marker option not set.');
    end
catch
    disp('Error: A problem during the saving process occured.')
end