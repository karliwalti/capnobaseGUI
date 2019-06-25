% --- Executes during object creation, after setting all properties.
function popupmenuZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'Value', 1);

set(hObject,'String',{'full record','120 s','60 s','30 s', '10 s','5s','1s'});
% Update handles structure
guidata(hObject, handles);


% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
