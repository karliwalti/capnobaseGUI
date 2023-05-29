function err=saveRating(handles)
%this does not return updated handles because not used anymore
err=[];

handles.current.rating.comment=get(handles.editRaterComment,'String');
handles.current.rating.rater=get(handles.editID,'String');

%clear all presence
try
    if isstruct(handles.current.rating.events)
        eventFields=fieldnames(handles.current.rating.events);
        for i=1:length(eventFields)
            if isfield(handles.current.rating.events.(eventFields{i}),'present')
                handles.current.rating.events.(eventFields{i}).present=0;
            end
        end
    end
    
    
    % refill events with cursor values
    for i=1:7
        value= get(handles.(['popupmenuEventSelect_' num2str(i)]),'Value') ;
        if  value > 1
            
            field=['event_' num2str(value) '_'];
            
            maxCursor=str2double(get(handles.(['editEvent_' num2str(i) '_Max']),'String'));
            minCursor=str2double(get(handles.(['editEvent_' num2str(i) '_Min']),'String'));
            %
            if (isnan(maxCursor)|isnan(minCursor))
                err=1; %cursor not set error
                return
            end
            if (isempty(GetCursorLocation(maxCursor))|isempty(GetCursorLocation(minCursor)))
                err=2; %cursor not set error
                return
            end
            if isfield(handles.current.rating.events,field)
                if    handles.current.rating.events.(field).present<1
                    handles.current.rating.events.(field).present=1;
                    handles.current.rating.events.(field).range=[GetCursorLocation(minCursor) GetCursorLocation(maxCursor)];
                    %TODO set multiple ranges for same event, will overwrite the previous sets here
                else % already a cursor pair set
                    handles.current.rating.events.(field).present=1+ handles.current.rating.events.(field).present;
                    handles.current.rating.events.(field).range=[handles.current.rating.events.(field).range; GetCursorLocation(minCursor) GetCursorLocation(maxCursor)];
                end
            else
                handles.current.rating.events.(field).present=1;
                handles.current.rating.events.(field).range=[GetCursorLocation(minCursor) GetCursorLocation(maxCursor)];
            end
        end
    end
catch
    %    disp('Warning: Could not retrieve event cursors for saving.')
end
try
    % clear presence of quality
    if isfield(handles.current.rating,'quality')
        if isstruct(handles.current.rating.quality)
            qualityFields=fieldnames(handles.current.rating.quality);
            for i=1:length(qualityFields)
                if isfield(handles.current.rating.quality.(qualityFields{i}),'present')
                    handles.current.rating.quality.(qualityFields{i}).present=0;
                end
            end
        end
    else
        handles.current.rating.quality=[];
    end
    
    % set quality values
    for i=1:3
        value= get(handles.(['popupmenuQualitySelect_' num2str(i)]),'Value') ;
        if  value > 1
            
            field=['quality_' num2str(value) '_'];
            
            maxCursor=str2double(get(handles.(['editQuality_' num2str(i) '_Max']),'String'));
            minCursor=str2double(get(handles.(['editQuality_' num2str(i) '_Min']),'String'));
            %
            if (isnan(maxCursor)|isnan(minCursor))
                err=1;
                return
            end
            
            minPos=GetCursorLocation(minCursor);
            maxPos=GetCursorLocation(maxCursor);
            if (isempty(maxCursor)|isempty(minCursor))
                err=2;
                return
            end
            if isfield(handles.current.rating.quality,field)
                if    handles.current.rating.quality.(field).present<1
                    handles.current.rating.quality.(field).present=1;
                    handles.current.rating.quality.(field).range=[minPos maxPos];
                else
                    handles.current.rating.quality.(field).present=1+handles.current.rating.quality.(field).present;
                    handles.current.rating.quality.(field).range=[handles.current.rating.quality.(field).range;minPos maxPos];
                    
                end
            else
                handles.current.rating.quality.(field).present=1;
                handles.current.rating.quality.(field).range=[minPos maxPos];
                
            end
        end
    end
catch
    disp('Warning: Could not retrieve quality cursors for saving.')
end

rating=handles.current.rating;
%rating.startinsp.x=round(GetAllCursorLocations('Insp').*handles.current.param.samplingrate);
%rating.startexp.x=round(GetAllCursorLocations('Exp').*handles.current.param.samplingrate);
try
    save([handles.parameters.ratingFolder  handles.data.name{handles.data.current} '_rating'],'rating');
    disp('Success: Rating saved');
    err=0;
    
catch
    disp('Error: A problem during the saving process occured.')
    err=3;
end
