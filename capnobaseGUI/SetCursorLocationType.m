function SetCursorLocationType(varargin)
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
    case 2
        fhandle=gcf;
        CursorNumber=varargin{1};
        Pos=varargin{2};
    case 3
        CursorType=varargin{3};
        CursorNumber=varargin{1};
        Pos=varargin{2};
         case 4
        fhandle=varargin{1};
        CursorNumber=varargin{2};
        Pos=varargin{3};
         CursorType=varargin{4};
    otherwise
        return
end

Cursors=getappdata(fhandle,'VerticalCursors');
if isempty(Cursors)
    % No cursors in figure
    x=[];
    return
end

try
    %Use try/catch as the selected cursor may not exist
    idx=strcmpi(get(Cursors{CursorNumber}.Handles,'type'),'line');
    set(Cursors{CursorNumber}.Handles(idx), 'XData', [Pos Pos]);
    idx=strcmpi(get(Cursors{CursorNumber}.Handles,'type'),'text');
    for i=1:length(idx)
        if idx(i)==1
            p=get(Cursors{CursorNumber}.Handles(i),'Position');
            p(1)=Pos;
            set(Cursors{CursorNumber}.Handles(i), 'Position', p);
        end
    end
catch
    return
end


return
end
