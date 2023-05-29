function FixCursor(varargin)
% SetCursorPos returns the position of a cursor in x-axis units
% TODO: this function is obsolete..
% Example:
% x=SetCursorLocation(CursorNumber, Position)
% x=SetCursorLocation(CursorNumber, Position, Type)
% x=SetCursorLocation(fhandle, CursorNumber, Position, Type)
%
% fhandle defaults to the current figure if not supplied or empty
%
% Sets the x-axis position for the cursor in the figure
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/07
% Copyright � The Author & King's College London 2007
% Update : WK 5.11.2009
%--------------------------------------------------------------------------

switch nargin
    case 1
        fhandle=gcf;
        CursorNumber=varargin{1};
        
    case 2
        fhandle=varargin{1};
        CursorNumber=varargin{2};
       
    otherwise
        return
end

Cursors=getappdata(fhandle,'VerticalMarkers');
if isempty(Cursors)
    % No cursors in figure
    x=[];
    return
end

try
    %Use try/catch as the selected cursor may not exist
    idx=strcmpi(get(Cursors{CursorNumber}.Handles,'type'),'line');
    set(Cursors{CursorNumber}.Handles(idx), 'ButtonDownFcn','');
    idx=strcmpi(get(Cursors{CursorNumber}.Handles,'type'),'text');
    for i=1:length(idx)
        if idx(i)==1
           set(Cursors{CursorNumber}.Handles(i),  'ButtonDownFcn','');
        end
    end%
catch
    return
end


return
end
