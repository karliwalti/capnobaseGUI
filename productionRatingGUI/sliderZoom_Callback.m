
% --- Executes on slider movement.
function sliderZoom_Callback(hObject, eventdata, handles)
% hObject    handle to sliderZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


strfnames=fieldnames(handles);
idx = strncmp(strfnames', 'axes', 4);

for k=find(idx)
try
set(handles.(strfnames{k}),'XLim', [-handles.data.window/2 handles.data.window/2]+get(hObject,'Value'));
%set(handles.axesFlow,'XLim', [-handles.data.window/2 handles.data.window/2]+get(hObject,'Value'));
catch
end
end