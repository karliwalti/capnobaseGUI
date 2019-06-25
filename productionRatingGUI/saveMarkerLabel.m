function saveMarkerLabel(hObject, eventdata, handles)
try
    if isfield(handles.current,'output')
        output=handles.current.output;
    end
    if get(handles.checkboxMarkers,'Value') %Markers enabled
        output.inspco2.x=round(GetAllMarkerLocations('InspCO2').*handles.current.param.samplingrate.co2);
        output.etco2.x=round(GetAllMarkerLocations('EtCO2').*handles.current.param.samplingrate.co2);
        output.inspco2.y=handles.current.data.co2.y(output.inspco2.x);
        output.etco2.y=handles.current.data.co2.y(output.etco2.x);
        output.rater=get(handles.editID,'String');
        save([handles.parameters.ratingFolder '/' handles.data.name{handles.data.current} '_output'],'output');
        disp('Success: Annotations saved.');
    else
        disp('Info: No annotations saved because marker option not set.');
    end
catch
    disp('Error: A problem during the saving process occured.')
end
