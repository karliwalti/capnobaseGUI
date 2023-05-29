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
tasks={
      'Go to other task ',...
    '1.1 Set Insp and Exp Phases',...
    '1.2 Set EtCO2 and InspCO2',...
     '1.3 Display Volume',...
    '--',...
    '2.1 Rate Trends and Events'};%,'2.2 Rate Capnogram Shapes'};
set(hObject,'String',tasks);