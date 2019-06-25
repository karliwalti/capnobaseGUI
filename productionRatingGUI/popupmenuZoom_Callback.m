% --- Executes on selection change in popupmenuZoom.
function popupmenuZoom_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuZoom contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuZoom

windowlength=get(hObject,'Value');
set(handles.sliderZoom,'Enable','on');

signals=fieldnames(handles.current.data);

step=1;
switch windowlength
	case 7
		handles.data.window=1;
		step=10;
	case 6
		handles.data.window=5;
		step=5;
	case 5
		handles.data.window=10;
		step=3;
	case 4
		handles.data.window=30;
		step=1.5;
		% break;
	case 3
		handles.data.window=60;
		
		% break;
	case 2
		handles.data.window=120;
		
		% break;
	case 1
		step=1;
		try
			if isfield(handles.current.data,'co2')
				handles.data.window=length(handles.current.data.co2.y)./handles.current.param.samplingrate.co2;
			else
				handles.data.window=length(handles.current.data.(signals{1}).y)./handles.current.param.samplingrate.(signals{1});
				
			end
		catch
			handles.data.window=120;
		end
		set(handles.sliderZoom,'Enable','off');
		
		% break:
end
set(handles.sliderZoom,'Value',handles.data.window/2);
set(handles.sliderZoom,'Min',handles.data.window/2);
try
	if isfield(handles.current.data,'co2')
		set(handles.sliderZoom,'Max',max(length(handles.current.data.co2.y)./handles.current.param.samplingrate.co2-handles.data.window/2,handles.data.window/2+1));
	else
		set(handles.sliderZoom,'Max',max(length(handles.current.data.(signals{1}).y)./handles.current.param.samplingrate.(signals{1})-handles.data.window/2,handles.data.window/2+1));
	end
catch
end
%set(handles.sliderZoom,'SliderStep',[0.05 1]./step);
set(handles.sliderZoom,'SliderStep',[min(1,handles.data.window/(get(handles.sliderZoom,'Max')-get(handles.sliderZoom,'Min'))) 1./step]);


strfnames=fieldnames(handles);
idx = strncmp(strfnames', 'axes', 4);

for k=find(idx)
	strfnames{k};
	set(handles.(strfnames{k}),'XLim', [0 handles.data.window]);
	%set(handles.axesFlow,'XLim', [-handles.data.window/2 handles.data.window/2]+get(hObject,'Value'));
	
end


% Update handles structure
guidata(hObject, handles);

