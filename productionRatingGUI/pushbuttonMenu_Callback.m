% --- Executes on button press in pushbuttonMenu.
function pushbuttonMenu_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Start(handles.parameters.raterID);

evalin('base','figure(menuFigure)');

%delete(handles.figureGUI);
