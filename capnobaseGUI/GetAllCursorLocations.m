function x=GetAllCursorLocations(varargin)
% GetCursorLocation returns the position of a cursor in x-axis units
%
% Example:
% x=GetCursorLocation(CursorNumber)
% x=GetCursorLocation(fhandle, CursorNumber)
%
% fhandle defaults to the current figure if not supplied or empty
%
% Returns x,  the x-axis position for the cursor in the figure
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/07
% Copyright � The Author & King's College London 2007
% Update: WK 2009/11/02
%         collect all cursors for given type 
%--------------------------------------------------------------------------

switch nargin
    case 1
        fhandle=gcf;
        CursorType=varargin{1};
    case 2
        fhandle=varargin{1};
        CursorType=varargin{2};
end

Cursors=getappdata(fhandle,'VerticalCursors');
if isempty(Cursors)
    % No cursors in figure
    x=[];
    return
end

% WK browse cursor handle
 %Use try/catch as the selected cursor may not exist
 try
     counter=1;
     x=[];
     for i=1:length(Cursors)
         if (isstruct(Cursors{i}))
             if(strcmp(Cursors{i}.Type,CursorType))
                 if (ishandle(Cursors{i}.Handles))
                     pos=get(Cursors{i}.Handles(1),'XData');
                     x(counter)=pos(1);
                     counter=counter+1;
                 end
             end
         end
         
     end
 catch
     x=[];
     disp('Error: GetAllCursors failed')
 end
 
 %WK put x in order 
 x=sort(x);
return
 end
