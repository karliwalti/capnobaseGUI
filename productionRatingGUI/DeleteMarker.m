function DeleteMarker(varargin)
% DeleteMarker deletes a Marker created by CreateMarker
%
% Examples:
% scDeleteMarker(MarkerNumber)
% scDeleteMarker(fhandle, MarkerNumber)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/07
% Copyright � The Author & King's College London 2007
% Update: WK 2009/11/2
%           added check if Marker exist before deleting
% -------------------------------------------------------------------------

if nargin==1
    fhandle=gcf;
    MarkerNumber=varargin{1};
else
    fhandle=varargin{1};
    MarkerNumber=varargin{2};
end
    
%WK check for numeric MarkerNumber
if (isnumeric(MarkerNumber))
    % Retrieve Marker info
    Markers=getappdata(fhandle, 'VerticalMarkers');

    %WK check for existing Marker 
    if (MarkerNumber<= length(Markers))
        % Delete associated lines and text
        %wk added validity check
        if (isstruct(Markers{MarkerNumber}))
            if (ishandle(Markers{MarkerNumber}.Handles))
                delete(Markers{MarkerNumber}.Handles);
            end
        end
        % Empty the cell array element - can be re-used
        Markers{MarkerNumber}={};
        % Trim if last cell is empty
        if isempty(Markers{end})
            Markers(end)=[];
        end
        % Update in application data area
        setappdata(fhandle, 'VerticalMarkers', Markers);
    end
end