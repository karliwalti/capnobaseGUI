function  [handles]=initZoomSlider(handles);

handles.data.window=length(handles.current.data.co2.y)./handles.current.param.samplingrate.co2;

        set(handles.sliderZoom,'Value',handles.data.window/2)
        set(handles.sliderZoom,'Min',handles.data.window/2)
        set(handles.sliderZoom,'Max',max(length(handles.current.data.co2.y)./handles.current.param.samplingrate.co2-handles.data.window/2,handles.data.window/2+1))
        set(handles.sliderZoom,'SliderStep',[0.05 1])

        set(handles.axesCapnogram,'XLim', [0 handles.data.window]);