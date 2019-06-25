function  [handles]=initZoomSlider(handles);

 if isfield(handles.current.data,'co2')
     
handles.data.window=length(handles.current.data.co2.y)./handles.current.param.samplingrate.co2;

        set(handles.sliderZoom,'Value',handles.data.window/2)
        set(handles.sliderZoom,'Min',handles.data.window/2)
        set(handles.sliderZoom,'Max',max(length(handles.current.data.co2.y)./handles.current.param.samplingrate.co2-handles.data.window/2,handles.data.window/2+1))
        set(handles.sliderZoom,'SliderStep',[0.05 1])

       % set(handles.axesTop,'XLim', [0 handles.data.window]);
 else
   signals=fieldnames(handles.current.data);  
     handles.data.window=length(handles.current.data.(signals{1}).y)./handles.current.param.samplingrate.(signals{1});

        set(handles.sliderZoom,'Value',handles.data.window/2)
        set(handles.sliderZoom,'Min',handles.data.window/2)
        set(handles.sliderZoom,'Max',max(length(handles.current.data.(signals{1}).y)./handles.current.param.samplingrate.(signals{1})-handles.data.window/2,handles.data.window/2+1))
        set(handles.sliderZoom,'SliderStep',[0.05 1])

 end