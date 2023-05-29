function x=GetAllMarkerLocations(varargin)
% GetMarkerLocation returns the position of a Marker in x-axis units
%
% Example:
% x=GetMarkerLocation(MarkerNumber)
% x=GetMarkerLocation(fhandle, MarkerNumber)
%
% fhandle defaults to the current figure if not supplied or empty
%
% Returns x,  the x-axis position for the Marker in the figure
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/07
% Copyright � The Author & King's College London 2007
% Update: WK 2009/11/02
%         collect all Markers for given type 
%--------------------------------------------------------------------------

switch nargin
    case 1
        fhandle=gcf;
        MarkerType=varargin{1};
    case 2
        fhandle=varargin{1};
        MarkerType=varargin{2};
end

Markers=getappdata(fhandle,'VerticalMarkers');
if isempty(Markers)
    % No Markers in figure
    x=[];
    return
end

% WK browse Marker handle
 %Use try/catch as the selected Marker may not exist
 try
     counter=1;
     x=[];
     for i=1:length(Markers)
         if (isstruct(Markers{i}))
             if(strcmp(Markers{i}.Type,MarkerType))
                 if (ishandle(Markers{i}.Handles))
                     pos=get(Markers{i}.Handles(1),'XData');
                     x(counter)=pos(1);
                     counter=counter+1;
                 end
             end
         end
         
     end
 catch
     x=[];
 end
 
 %WK put x in order 
 x=sort(x);
return
 end
