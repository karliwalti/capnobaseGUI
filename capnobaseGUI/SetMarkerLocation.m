function SetMarkerLocation(varargin)
% SetMarkerPos returns the position of a Marker in x-axis units
%
% Example:
% x=SetMarkerLocation(MarkerNumber, Position)
% x=SetMarkerLocation(fhandle, MarkerNumber, Position)
%
% fhandle defaults to the current figure if not supplied or empty
%
% Sets the x-axis position for the Marker in the figure
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/07
% Copyright � The Author & King's College London 2007
%--------------------------------------------------------------------------

switch nargin
    case 3
        fhandle=gcf;
        MarkerNumber=varargin{1};
        PosX=varargin{2};
        PosY=varargin{3};
    case 4
        fhandle=varargin{1};
        MarkerNumber=varargin{2};
        PosX=varargin{3};
        PosY=varargin{4};
    otherwise
        return
end

Markers=getappdata(fhandle,'VerticalMarkers');
if isempty(Markers)
    % No Markers in figure
    x=[];
    return
end

try
    %Use try/catch as the selected Marker may not exist
    idx=strcmpi(get(Markers{MarkerNumber}.Handles,'type'),'line');
    set(Markers{MarkerNumber}.Handles(idx), 'XData', [PosX], 'YData', [PosY]);
    idx=strcmpi(get(Markers{MarkerNumber}.Handles,'type'),'text');
    for i=1:length(idx)
        if idx(i)==1
            p=get(Markers{MarkerNumber}.Handles(i),'Position');
            p(1)=PosX;
           % p(2)=PosY;
            set(Markers{MarkerNumber}.Handles(i), 'Position', p);
        end
    end
catch
    return
end


return
end
