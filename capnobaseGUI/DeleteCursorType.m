function DeleteCursorType(varargin)
% DeleteCursor deletes a cursor created by CreateCursor
%
% Examples:
% scDeleteCursor(CursorNumber)
% scDeleteCursor(fhandle, CursorNumber)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/07
% Copyright � The Author & King's College London 2007
% Update: WK 2009/11/2
%           added check if cursor exist before deleting
% -------------------------------------------------------------------------

if nargin==1
    fhandle=gcf;
    CursorType=varargin{1};
else
    fhandle=varargin{1};
    CursorType=varargin{2};
end

%WK check for numeric CursorNumber
%if (isnumeric(CursorNumber))
% Retrieve cursor info
Cursors=getappdata(fhandle, 'VerticalCursors');

try
    counter=1;
    x=[];
    for i=1:length(Cursors)
        if (isstruct(Cursors{i}))
            if(strcmp(Cursors{i}.Type,CursorType))
                if (ishandle(Cursors{i}.Handles))
                    % pos=get(Cursors{i}.Handles(1),'XData');
                    x(counter)=i;%pos(1);
                    counter=counter+1;
                end
            end
        end
        
    end
catch
    x=[];
end

%WK check for existing cursor
%if (CursorNumber<= length(Cursors))
for i=1:length(x)
    % Delete associated lines and text
    CursorNumber=x(i);
    %wk added validity check
    if (isstruct(Cursors{CursorNumber}))
        if (ishandle(Cursors{CursorNumber}.Handles))
            delete(Cursors{CursorNumber}.Handles);
        end
    end
    % Empty the cell array element - can be re-used
    Cursors{CursorNumber}={};
    % Trim if last cell is empty
    if isempty(Cursors{end})
        Cursors(end)=[];
    end
    % Update in application data area
    setappdata(fhandle, 'VerticalCursors', Cursors);
end
end
%end