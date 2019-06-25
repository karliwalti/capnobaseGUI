function NumberOfMarker=CreateMarkerType(fhandle, MarkerType, PosX, NumberOfMarker)
% scCreateMarker creates or replaces a vertical Marker
%
% Examples
% n=CreateMarker()
% n=CreateMarker(fighandle)
%n=CreateMarker(fighandle, MarkerType)
% n=CreateMarker(fighandle, MarkerType, PosX)
% n=CreateMarker(fighandle, MarkerType, PosX, MarkerNumber)
%
% Markers are specific to a figure. If the figure handle is not specified
% in fighandle, the current figure (returned by gcf) will be used.
% MarkerNumber is any positive number. If not specified the lowest numbered
% free Marker number will be used.
%
% Returns n, the number of the Marker created in the relevant figure.
%
% A record is kept of the Markers in the figure's application data
% area. Marker n occupies the nth element of a cell array. Each element is
% a structure containing the following fields:
%           Handles:    a list of objects associated with this Marker -
%                       one line for each axes and one or more text objects
%           IsActive:   true if this Marker is currently being moved. False
%                       otherwise. For manual Markers, IsActive is set by a
%                       button down on the Marker and cleared by a button
%                       up.
% Functions that affect the position of a Marker must explicitly update all
% the objects listed in Handles. A Marker is not an object itself.
%
% Revisions: 27.2.07 add restoration of gca

% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/07
% Copyright � The Author & King's College London 2007
% Modified : 2009  Walter Karlen
% Added: Marker Type Input
% -------------------------------------------------------------------------
%

% Note: These functions presently work with 2D views only

% Keep gca to restore current axes at end
current=gca;

% Figure details
if nargin<1
	fhandle=gcf;
end
AxesList=sort(findobj(fhandle, 'type', 'axes'));


% Get Marker info
newhandles=zeros(1, length(AxesList));
Markers=getappdata(fhandle, 'VerticalMarkers');


if nargin<2
	MarkerType='Default'; % WK: set default Marker type
end
% WK: defines Marker color
phasemarker=0;
switch MarkerType
	
	case 'InspCO2'
		MarkerColor='g';
	case 'EtCO2'
		MarkerColor='m';
	case 'P I'
		MarkerColor='b';
		phasemarker=1;
	case 'P II'
		MarkerColor=[0.392 0.475 0.635];
		phasemarker=1;
	case 'P III'
		MarkerColor=[0.749 0 .749];
		phasemarker=1;
	case 'P IV'
		MarkerColor='y';
		phasemarker=1;
	case 'P 0'
		MarkerColor=[0.847 .161 0];
		phasemarker=1;
	otherwise
		MarkerColor='k';
end



% Deal with this Marker number

if isempty(Markers)
	NumberOfMarker=1;
else
	if nargin<4
		FirstEmpty=0;
		if ~isempty(Markers)
			for i=1:length(Markers)
				if isempty(Markers{i})
					FirstEmpty=i;
					break
				end
			end
		end
		if FirstEmpty==0
			NumberOfMarker=length(Markers)+1;
			Markers{NumberOfMarker}=[];
		else
			NumberOfMarker=FirstEmpty;
		end
	end
end


if ~isempty(Markers) && ~isempty(Markers{NumberOfMarker}) &&...
		isfield(Markers{NumberOfMarker},'MarkerIsActive');
	if Markers{NumberOfMarker}.MarkerIsActive==true
		disp('CreateMarker: Ignored attempt to delete the currently active Marker');
		return
	else
		delete(Markers{NumberOfMarker}.Handles);
	end
end
Markers{NumberOfMarker}.IsActive=false;
Markers{NumberOfMarker}.Handles=[];
Markers{NumberOfMarker}.Type='';

for i=1:length(AxesList)
	DataHandle=findobj(AxesList(i),'Tag','CO2');
	if ~isempty(DataHandle)
		axisToUse=i;
		YDATA=get(DataHandle,'YData');
		XDATA=get(DataHandle,'XData');
		break;
	else
		DataHandle=findobj(AxesList(i),'Tag','co2');
		if ~isempty(DataHandle)
			axisToUse=i;
			YDATA=get(DataHandle,'YData');
			XDATA=get(DataHandle,'XData');
		end
	end
end

% no position specified
if nargin<3
	XLim=get(AxesList(axisToUse),'XLim');
	xhalf=XLim(1)+(0.5*(XLim(2)-XLim(1)));
else
	xhalf=PosX;
end
[XValue, Xidx]=find(XDATA>xhalf,1,'first');

for i=axisToUse%1:length(AxesList)
	% For each Marker there is a line object in each axes
	subplot(AxesList(i));
	YLim=get(AxesList(i),'YLim');
	% newhandles(i)=line([xhalf xhalf xhalf], [YLim(1) YDATA(Xidx) YLim(2)]);
	%newhandles(i)=line([xhalf], [ YDATA(Xidx) ]);
	newhandles=line([xhalf], [ YDATA(Xidx) ]);
	Markers{NumberOfMarker}.Type=MarkerType;
end


% Put a label at the top and make it behave as part of the Marker
if gca~=AxesList(axisToUse)
	axes(AxesList(axisToUse));
end
YLim=get(AxesList(axisToUse),'YLim');

loc=YLim(2);
dispnum=num2str(NumberOfMarker);
marker='x';
align='center';
if strcmp(MarkerType,'InspCO2')
	loc=YLim(1)-0.15;
end


if phasemarker
	dispnum='';
	loc= YDATA(Xidx)+.3;
	marker='.';
	align='left';
end

th=text(xhalf, loc, [MarkerType ' ' dispnum ],...
	'Tag','Marker',...
	'UserData', NumberOfMarker,...
	'FontSize', 7,...
	'HorizontalAlignment',align,...
	'VerticalAlignment','bottom',...
	'Color', 'k',...
	'EdgeColor', MarkerColor,...
	'Clipping','off',...
	'ButtonDownFcn',{@CursorButtonDownFcn} );

% Set line properties en bloc
% Note UserData has the Marker number
if ispc==1
	% Windows
	EraseMode='xor';
else
	% Mac etc: 'xor' may cause problems
	EraseMode='normal';
end
set(newhandles, 'Tag', 'Marker',...
	'Color',  MarkerColor,...
	'UserData', NumberOfMarker,...
	'Linewidth',2,...
	'Marker',marker,...
	'MarkerSize',15,...
	'Erasemode', EraseMode,...
	'ButtonDownFcn',{@CursorButtonDownFcn});

Markers{NumberOfMarker}.IsActive=false;
Markers{NumberOfMarker}.Handles=[newhandles th];

setappdata(fhandle, 'VerticalMarkers', Markers);
set(gcf, 'WindowButtonMotionFcn',{@CursorWindowButtonMotionFcn});
% Restore the axes on entry as the current axes if different
if gca~=current
	axes(current)
end
return
end

%--------------------------------------------------------------------------
function CursorButtonDownFcn(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------

% Make sure we have a left button click
type=get(ancestor(hObject,'figure'), 'SelectionType');
flag=strcmp(type, 'normal');
if flag==0
	% Not so, return and let matlab call the required callback,
	% e.g. the uicontextmenu, which will be in the queue
	return
end;

% Flag the active Marker
Markers=getappdata(gcf, 'VerticalMarkers');
for i=1:length(Markers)
	if isempty(Markers{i})
		continue
	end
	LabelHandle=findobj(Markers{i}.Handles, 'Type', 'text', 'Tag', 'Marker');
	if get(LabelHandle,'LineWidth')==2
		
		set(LabelHandle,'LineWidth',1);
	end
	if any(Markers{i}.Handles==hObject)
		% Set flag
		Markers{i}.IsActive=true;
		%LabelHandle=findobj(Markers{i}.Handles, 'Type', 'text', 'Tag', 'Marker');
		set(LabelHandle,'LineWidth',2);
		
		%break
	end
	%     if any(Markers{i}.Handles==hObject)
	%         % Set flag
	%         Markers{i}.IsActive=true;
	%         break
	%     end
end
setappdata(gcf, 'VerticalMarkers', Markers);

% Set up
StoreWindowButtonDownFcn=get(gcf,'WindowButtonDownFcn');
StoreWindowButtonUpFcn=get(gcf,'WindowButtonUpFcn');
StoreWindowButtonMotionFcn=get(gcf,'WindowButtonMotionFcn');
% Store these values in the MarkerButtonUpFcn persistent variables so they
% can be used/restored later
CursorButtonUpFcn({hObject,...
	StoreWindowButtonDownFcn,...
	StoreWindowButtonUpFcn,...
	StoreWindowButtonMotionFcn});
% Motion callback needs only the current Marker number
CursorButtonMotionFcn({hObject});

% Delete callback send persistent variables so they
% can be used/restored later
deleteActiveMarkerFnc({hObject,...
	StoreWindowButtonDownFcn,...
	StoreWindowButtonUpFcn,...
	StoreWindowButtonMotionFcn});

% Set up callbacks
set(gcf, 'WindowButtonUpFcn',{@CursorButtonUpFcn});
set(gcf, 'WindowButtonMotionFcn',{@CursorButtonMotionFcn});
set(gcf, 'KeyReleaseFcn',{@deleteActiveMarkerFnc})
return
end

%--------------------------------------------------------------------------
function CursorButtonUpFcn(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
% These persistent values are set by a call from MarkerButtonDownFcn
persistent ActiveHandle;
persistent StoreWindowButtonDownFcn;
persistent StoreWindowButtonUpFcn;
persistent StoreWindowButtonMotionFcn;

% Called from MarkerButtonDownFcn - hObject is a cell with values to seed
% the persistent variables
if iscell(hObject)
	ActiveHandle=hObject{1};
	StoreWindowButtonDownFcn=hObject{2};
	StoreWindowButtonUpFcn=hObject{3};
	StoreWindowButtonMotionFcn=hObject{4};
	return
end

% Called by button up in a figure window - use the stored CurrentMarker
% value
UpdateMarkerPosition(ActiveHandle)

% Restore the figure's original callbacks - make sure we do this in the
% same figure that we had when the mouse button-down was detected
h=ancestor(ActiveHandle,'figure');
set(h, 'WindowButtonDownFcn', StoreWindowButtonDownFcn);
set(h, 'WindowButtonUpFcn', StoreWindowButtonUpFcn);
set(h, 'WindowButtonMotionFcn',StoreWindowButtonMotionFcn);
%set(h, 'WindowKeyReleaseFcn',StoreWindowDeleteFcn);

% Remove the active Marker flag
Markers=getappdata(gcf, 'VerticalMarkers');
for i=1:length(Markers)
	if isempty(Markers{i})
		continue
	end
	if any(Markers{i}.Handles==ActiveHandle)
		Markers{i}.IsActive=false;
		break
	end
end
setappdata(gcf, 'VerticalMarkers', Markers);

return
end

%--------------------------------------------------------------------------
function CursorButtonMotionFcn(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
% This replaces the MarkerWindowButtonMotionFcn while a Marker is being
% moved
persistent ActiveHandle;

% Called from MarkerButtonDownFcn
if iscell(hObject)
	ActiveHandle=hObject{1};
	return
end
%Called by button up
UpdateMarkerPosition(ActiveHandle)
return
end

%--------------------------------------------------------------------------
function UpdateMarkerPosition(ActiveHandle)
%--------------------------------------------------------------------------
% Get all lines in all axes in the current figure that are
% associated with the current Marker....
MarkerHandles=findobj(gcf, 'Type', 'line',...
	'Tag', 'Marker',...
	'UserData', get(ActiveHandle,'UserData'));
% ... and update them:

%WK get values of CO2 graph %works only for one axes so far
DataHandle=findobj(gca,'Tag','CO2');
YDATA=get(DataHandle,'YData');
XDATA=get(DataHandle,'XData');

% Get the pointer position in the current axes
cpos=get(gca,'CurrentPoint');
if cpos(1,1)==cpos(2,1) && cpos(1,2)==cpos(2,2)
	% 2D Marker
	% Limit to the x-axis limits
	XLim=get(gca,'XLim');
	XLim=[max(XLim(1),XDATA(1)) min(XLim(2),XDATA(end))];
	YLim=get(gca,'YLim');
	if cpos(1)<XLim(1)
		cpos(1)=XLim(1);
	end
	if cpos(1)>XLim(2)
		cpos(1)=XLim(2);
	end
	[XValue, Xidx]=find(XDATA>=cpos(1),1,'first');
	% Set
	%set(MarkerHandles,'XData',[cpos(1) cpos(1) cpos(1)], 'YData',[YLim(1) YDATA(Xidx) YLim(2)]);
	set(MarkerHandles,'XData',[cpos(1)], 'YData',[ YDATA(Xidx)]);
	
else
	% TODO: Include support for 3D Markers
	return
end

% Now update the Marker Label
LabelHandle=findobj(gcf, 'Type', 'text', 'Tag', 'Marker', 'UserData',...
	get(ActiveHandle,'UserData'));
tpos=get(LabelHandle,'position');
tpos(1)=cpos(1);
set(LabelHandle,'position',tpos);
return
end

%--------------------------------------------------------------------------
function deleteActiveMarkerFnc(hObject, EventData)%ActiveHandle)
%--------------------------------------------------------------------------
% Get all lines in all axes in the current figure that are
% associated with the current Marker....
persistent ActiveHandle;

if iscell(hObject)
	ActiveHandle=hObject{1};
	return
end
switch EventData.Key
	
	case {'d', 'delete'}
		try
			num=get(ActiveHandle,'UserData'); %WK added dummy
			CursorButtonUpFcn(hObject, EventData)
			DeleteMarker(num);
		catch
			disp('Warning: No or invalid marker for deletion selected.')
		end
		
		%clear up and motion functions
		%    set(gcf, 'WindowButtonUpFcn','');
		%set(gcf, 'WindowButtonMotionFcn','');
		set(gcf, 'WindowKeyReleaseFcn','');
	case 'leftarrow'
		UpdateMarkerPositionKey(ActiveHandle,-.010);
	case 'rightarrow'
		UpdateMarkerPositionKey(ActiveHandle, .010);
		
end
return
end


%--------------------------------------------------------------------------
function UpdateMarkerPositionKey(ActiveHandle,steps)
%--------------------------------------------------------------------------
% steps in seconds
% Get all lines in all axes in the current figure that are
% associated with the current Marker....
MarkerHandles=findobj(gcf, 'Type', 'line',...
	'Tag', 'Marker',...
	'UserData', get(ActiveHandle,'UserData'));
% ... and update them:

%WK get values of CO2 graph %works only for one axes so far
DataHandle=findobj(gca,'Tag','CO2');
YDATA=get(DataHandle,'YData');
XDATA=get(DataHandle,'XData');

% Get the current positionof the marker
cpos=get(MarkerHandles,'XData')+steps;

%if cpos(1,1)==cpos(2,1) && cpos(1,2)==cpos(2,2)
% 2D Marker
% Limit to the x-axis limits
XLim=get(gca,'XLim');
XLim=[max(XLim(1),XDATA(1)) min(XLim(2),XDATA(end))];
YLim=get(gca,'YLim');
if cpos(1)<XLim(1)
	cpos(1)=XLim(1);
end
if cpos(1)>XLim(2)
	cpos(1)=XLim(2);
end
[XValue, Xidx]=find(XDATA>cpos(1),1,'first');
% Set
%set(MarkerHandles,'XData',[cpos(1) cpos(1) cpos(1)], 'YData',[YLim(1) YDATA(Xidx) YLim(2)]);
set(MarkerHandles,'XData',[cpos(1)], 'YData',[ YDATA(Xidx)]);

%else
% TODO: Include support for 3D Markers
%   return
%end

% Now update the Marker Label
LabelHandle=findobj(gcf, 'Type', 'text', 'Tag', 'Marker', 'UserData',...
	get(ActiveHandle,'UserData'));
tpos=get(LabelHandle,'position');
tpos(1)=cpos(1);
set(LabelHandle,'position',tpos);
return
end