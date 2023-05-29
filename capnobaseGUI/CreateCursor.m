function NumberOfCursor=CreateCursor(fhandle, NumberOfCursor)
% scCreateCursor creates or replaces a vertical cursor
%
% Examples
% n=CreateCursor()
% n=CreateCursor(fighandle)
% n=CreateCursor(fighandle, CursorNumber)
%
% Cursors are specific to a figure. If the figure handle is not specified
% in fighandle, the current figure (returned by gcf) will be used.
% CursorNumber is any positive number. If not specified the lowest numbered
% free cursor number will be used. 
%
% Returns n, the number of the cursor created in the relevant figure.
%
% A record is kept of the cursors in the figure's application data
% area. Cursor n occupies the nth element of a cell array. Each element is
% a structure containing the following fields:
%           Handles:    a list of objects associated with this cursor -
%                       one line for each axes and one or more text objects
%           IsActive:   true if this cursor is currently being moved. False
%                       otherwise. For manual cursors, IsActive is set by a
%                       button down on the cursor and cleared by a button
%                       up. 
% Functions that affect the position of a cursor must explicitly update all
% the objects listed in Handles. A cursor is not an object itself.
%
% Revisions: 27.2.07 add restoration of gca

% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/07
% Copyright © The Author & King's College London 2007
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


% Get cursor info
newhandles=zeros(1, length(AxesList));
Cursors=getappdata(fhandle, 'VerticalCursors');

% Deal with this cursor number

if isempty(Cursors)
    NumberOfCursor=1;
else
    if nargin<2
        FirstEmpty=0;
        if ~isempty(Cursors)
            for i=1:length(Cursors)
                if isempty(Cursors{i})
                    FirstEmpty=i;
                    break
                end
            end
        end
        if FirstEmpty==0
            NumberOfCursor=length(Cursors)+1;
            Cursors{NumberOfCursor}=[];
        else
            NumberOfCursor=FirstEmpty;
        end
    end
end


if ~isempty(Cursors) && ~isempty(Cursors{NumberOfCursor}) &&...
        isfield(Cursors{NumberOfCursor},'CursorIsActive');
    if Cursors{NumberOfCursor}.CursorIsActive==true
        disp('CreateCursor: Ignored attempt to delete the currently active cursor');
        return
    else
        delete(Cursors{NumberOfCursor}.Handles);
    end
end
Cursors{NumberOfCursor}.IsActive=false;
Cursors{NumberOfCursor}.Handles=[];
Cursors{NumberOfCursor}.Type='';


XLim=get(AxesList(end),'XLim');
xhalf=XLim(1)+(0.5*(XLim(2)-XLim(1)));
for i=1:length(AxesList)
    % For each cursor there is a line object in each axes
    subplot(AxesList(i));
        YLim=get(AxesList(i),'YLim');
        newhandles(i)=line([xhalf xhalf], [YLim(1) YLim(2)]);
        Cursors{NumberOfCursor}.Type='2D';
end


% Put a label at the top and make it behave as part of the cursor
axes(AxesList(1));
YLim=get(AxesList(1),'YLim');
th=text(xhalf, YLim(2), ['C' num2str(NumberOfCursor)],...
    'Tag','Cursor',...
    'UserData', NumberOfCursor,...
    'FontSize', 7,...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'Color', 'k',...
    'EdgeColor',[26/255 133/255 5/255],...
    'Clipping','off',...
    'ButtonDownFcn',{@CursorButtonDownFcn});

% Set line properties en bloc
% Note UserData has the cursor number
if ispc==1
    % Windows
    EraseMode='xor';
else
    % Mac etc: 'xor' may cause problems
    EraseMode='normal';
end
set(newhandles, 'Tag', 'Cursor',...
    'Color', [26/255 133/255 5/255],...
    'UserData', NumberOfCursor,...
    'Linewidth',1,...
    'Erasemode', EraseMode,...
    'ButtonDownFcn',{@CursorButtonDownFcn});

Cursors{NumberOfCursor}.IsActive=false;
Cursors{NumberOfCursor}.Handles=[newhandles th];

setappdata(fhandle, 'VerticalCursors', Cursors);
set(gcf, 'WindowButtonMotionFcn',{@CursorWindowButtonMotionFcn});
% Restore the axes on entry as the current axes
axes(current)
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

% Flag the active cursor
Cursors=getappdata(gcf, 'VerticalCursors');
for i=1:length(Cursors)
    if isempty(Cursors{i})
        continue
    end
    if any(Cursors{i}.Handles==hObject)
            % Set flag
            Cursors{i}.IsActive=true;
            break
    end
end
setappdata(gcf, 'VerticalCursors', Cursors);

% Set up
StoreWindowButtonDownFcn=get(gcf,'WindowButtonDownFcn');
StoreWindowButtonUpFcn=get(gcf,'WindowButtonUpFcn');
StoreWindowButtonMotionFcn=get(gcf,'WindowButtonMotionFcn');
% Store these values in the CursorButtonUpFcn persistent variables so they
% can be used/restored later
CursorButtonUpFcn({hObject,...
    StoreWindowButtonDownFcn,...
    StoreWindowButtonUpFcn,...
    StoreWindowButtonMotionFcn});
% Motion callback needs only the current cursor number
CursorButtonMotionFcn({hObject});

% Set up callbacks
set(gcf, 'WindowButtonUpFcn',{@CursorButtonUpFcn});
set(gcf, 'WindowButtonMotionFcn',{@CursorButtonMotionFcn});
return
end

%--------------------------------------------------------------------------
function CursorButtonUpFcn(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
% These persistent values are set by a call from CursorButtonDownFcn
persistent ActiveHandle;
persistent StoreWindowButtonDownFcn;
persistent StoreWindowButtonUpFcn;
persistent StoreWindowButtonMotionFcn;

% Called from CursorButtonDownFcn - hObject is a cell with values to seed
% the persistent variables
if iscell(hObject)
    ActiveHandle=hObject{1};
    StoreWindowButtonDownFcn=hObject{2};
    StoreWindowButtonUpFcn=hObject{3};
    StoreWindowButtonMotionFcn=hObject{4};
    return
end

% Called by button up in a figure window - use the stored CurrentCursor
% value
UpdateCursorPosition(ActiveHandle)

% Restore the figure's original callbacks - make sure we do this in the
% same figure that we had when the mouse button-down was detected
h=ancestor(ActiveHandle,'figure');
set(h, 'WindowButtonDownFcn', StoreWindowButtonDownFcn);
set(h, 'WindowButtonUpFcn', StoreWindowButtonUpFcn);
set(h, 'WindowButtonMotionFcn',StoreWindowButtonMotionFcn);


% Remove the active cursor flag
Cursors=getappdata(gcf, 'VerticalCursors');
for i=1:length(Cursors)
    if isempty(Cursors{i})
        continue
    end
    if any(Cursors{i}.Handles==ActiveHandle)
        Cursors{i}.IsActive=false;
        break
    end
end
setappdata(gcf, 'VerticalCursors', Cursors);

return
end

%--------------------------------------------------------------------------
function CursorButtonMotionFcn(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
% This replaces the CursorWindowButtonMotionFcn while a cursor is being
% moved
persistent ActiveHandle;

% Called from CursorButtonDownFcn
if iscell(hObject)
    ActiveHandle=hObject{1};
    return
end
%Called by button up
UpdateCursorPosition(ActiveHandle)
return
end

%--------------------------------------------------------------------------
function UpdateCursorPosition(ActiveHandle)
%--------------------------------------------------------------------------
% Get all lines in all axes in the current figure that are
% associated with the current cursor....
CursorHandles=findobj(gcf, 'Type', 'line',...
    'Tag', 'Cursor',...
    'UserData', get(ActiveHandle,'UserData'));
% ... and update them:
% Get the pointer position in the current axes
cpos=get(gca,'CurrentPoint');
if cpos(1,1)==cpos(2,1) && cpos(1,2)==cpos(2,2)
    % 2D Cursor
    % Limit to the x-axis limits
    XLim=get(gca,'XLim');
    if cpos(1)<XLim(1)
        cpos(1)=XLim(1);
    end
    if cpos(1)>XLim(2)
        cpos(1)=XLim(2);
    end
    % Set
    set(CursorHandles,'XData',[cpos(1) cpos(1)]);
else
    % TODO: Include support for 3D cursors
    return
end

% Now update the cursor Label
LabelHandle=findobj(gcf, 'Type', 'text', 'Tag', 'Cursor', 'UserData',...
    get(ActiveHandle,'UserData'));
tpos=get(LabelHandle,'position');
tpos(1)=cpos(1);
set(LabelHandle,'position',tpos);
return
end

