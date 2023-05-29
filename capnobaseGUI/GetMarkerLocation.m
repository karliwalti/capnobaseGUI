function x=GetMarkerLocation(varargin)
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
%--------------------------------------------------------------------------

switch nargin
    case 1
        fhandle=gcf;
        MarkerNumber=varargin{1};
    case 2
        fhandle=varargin{1};
        MarkerNumber=varargin{2};
end

Markers=getappdata(fhandle,'VerticalMarkers');
if isempty(Markers)
    % No Markers in figure
    x=[];
    return
end

try
    %Use try/catch as the selected Marker may not exist
    pos=get(Markers{MarkerNumber}.Handles(1),'XData');
    x=pos(1);
catch
    x=[];
end

return
end
