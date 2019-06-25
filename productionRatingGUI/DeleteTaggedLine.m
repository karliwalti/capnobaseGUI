function DeleteTaggedLine(varargin)
% DeleteCursor deletes a cursor created by CreateCursor
%
% Examples:
% scDeleteCursor(CursorNumber)
% scDeleteCursor(fhandle, CursorNumber)
%
% -------------------------------------------------------------------------
% Update: WK 2010/03/31
%           added check if cursor exist before deleting
% -------------------------------------------------------------------------

if nargin==1
    fhandle=gcf;
    LineTag=varargin{1};
else
    fhandle=varargin{1};
    LineTag=varargin{2};
end

%WK check for numeric CursorNumber
%if (isnumeric(CursorNumber))
% Retrieve cursor info
Lines=get(fhandle,'Children');
for i=1:length(Lines)
    line= get(Lines(i));
    
    if(strcmp(line.Type,'line'))
        if(strcmp(line.Tag,LineTag))
            delete(Lines(i));
        end
    end
end



% try
%     counter=1;
%     x=[];
%     for i=1:length(Lines)
%         if (isstruct(Lines{i}))
%             if(strcmp(Lines{i}.Type,LineTag))
%                 if (ishandle(Lines{i}.Handles))
%                     % pos=get(Lines{i}.Handles(1),'XData');
%                     x(counter)=i;%pos(1);
%                     counter=counter+1;
%                 end
%             end
%         end
%
%     end
% catch
%     x=[];
% end
%
% %WK check for existing cursor
% %if (CursorNumber<= length(Lines))
% for i=1:length(x)
%     % Delete associated lines and text
%     LineNumber=x(i);
%     %wk added validity check
%     if (isstruct(Lines{LineNumber}))
%         if (ishandle(Lines{LineNumber}.Handles))
%             delete(Lines{LineNumber}.Handles);
%         end
%     end
%     % Empty the cell array element - can be re-used
%     Lines{LineNumber}={};
%     % Trim if last cell is empty
%     if isempty(Lines{end})
%         Lines(end)=[];
%     end
%     % Update in application data area
%     setappdata(fhandle, 'VerticalLines', Lines);
% end
% end
% %end