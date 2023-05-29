% --- Executes on selection change in popupmenuJumpTask.
function popupmenuJumpTask_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSelect

if ~isfield(handles,'menuFigure')
    handles.menuFigure=1;%TODO handles.figureGUI;
end

assignin('base', 'raterID', num2str(get(handles.editID,'String')));
assignin('base', 'menuFigure', handles.menuFigure)
assignin('base', 'current', handles.data.current)
assignin('base', 'dataset', handles.parameters.dataset)
switch get(hObject,'Value')
    case 2
        
        handles.launch=['setRRGUI({raterID},menuFigure,current,dataset)'];
        
    case 3
        
        handles.launch=['setEtCO2GUI({raterID},menuFigure,current,dataset)'];
        case 4
        
        handles.launch=['displayVolumeGUI({raterID},menuFigure,current,dataset)'];
        
    case 6
        
        handles.launch=['ratingGUI({raterID},menuFigure,current,dataset)'];
 %   case 6    
  %      handles.launch=['rateShapeGUI({raterID},menuFigure,current,dataset)'];
    otherwise
        % Code for when there is no match.
        handles.launch=[];
        
end
%updates the handles structure
guidata(hObject, handles);

if ~isempty(handles.launch)
    %take rater ID and prepare for new folder
    idfolder=get(handles.editID,'String');
  %  ratingfolder=['ratings/' idfolder];
    %write rating folder for new rater
   % if (~isdir(ratingfolder))
   %     mkdir(ratingfolder);
   % end
    
   % ratingfolder=['output/' idfolder];
    %write output folder for new rater
   % if (~isdir(ratingfolder))
   %     mkdir(ratingfolder);
   % end
    
    
    
    returnval = evalin('base',handles.launch);
end
