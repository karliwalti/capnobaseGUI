%WK 2010
% used for producing csv files for download in capnobase website
% mat2csv converter

%importfile('../signalstemp.csv')
clear all


counter=1;
% foldercontent=dir('data');
% raterID='333';
% counter=1;
% foldercontent=dir(['ratings/' raterID ]);

id=1;
studyids={'CBTBMEBenchmark'}
study=studyids{id};%'CBBenchmarkAllSignals'%'CB8minLongData';%%'SpecialSelect/';'CapnoBaseInVivo/';%'CapnoBaseBenchmark/';%'iPlethLongData/';%'SimulationMarkAnsermino08_04/';%'default/';
folder=['C:\Users\wkarlen\Documents\Dropbox\Capnobase\dataverse\' study  filesep 'data' filesep];


mkdir([folder filesep 'csv' filesep])
matfolder=[folder filesep 'mat' filesep];
foldercontent=dir(matfolder);

for i=3:length(foldercontent)
    
    if(~foldercontent(i).isdir)
        [pathstr, name, ext]= fileparts(foldercontent(i).name);
        if strcmp(ext,'.mat')
            handles.data.name{counter}=name;%foldercontent(i).
            counter=counter+1;
        end
    else %update 10/4/2010
        subfoldercontent=dir([matfolder filesep foldercontent(i).name]); %browse subfolder
        for k=3:length(subfoldercontent)
            if(~subfoldercontent(k).isdir)
                [pathstr, name, ext]= fileparts(subfoldercontent(k).name);
                
                if strcmp(ext,'.mat')
                    mkdir([folder filesep 'csv' filesep foldercontent(i).name ])
                    handles.data.name{counter}=[foldercontent(i).name filesep name];%foldercontent(i).
                    counter=counter+1;
                end
            end
        end
        
        
    end
    
end
%loads new data
signalcounter=0;
for k=1:length( handles.data.name)%179%
   
            clear header value
            signalcounter=signalcounter+1;
            current=load([matfolder (handles.data.name{k})],'meta'); %,'data','param'
            
            counter=1;
            
            task={'meta'}; %,'param'};
            %  C1={};
            for i=1:length(task)
                
                fieldNames=fieldnames(current.(task{i}));
                for m=1:length(fieldNames)
                    
                    
                    if isstruct(current.(task{i}).(fieldNames{m}))
                        fieldNames2=fieldnames(current.(task{i}).(fieldNames{m}));
                        for n=1:length(fieldNames2)
                            if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}))
                                fieldNames3=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}));
                                %TODO
                                for l=1:length(fieldNames3)
                                    if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}))
                                        fieldNames4=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}));
                                    else
                                        header{counter}=[fieldNames{m} '_' fieldNames2{n} '_' fieldNames3{l}];
                                        value{counter}=current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l});
                                        counter=counter+1;
                                    end
                                end
                            else
                                header{counter}=[fieldNames{m} '_' fieldNames2{n}];
                                value{counter}=current.(task{i}).(fieldNames{m}).(fieldNames2{n});
                                counter=counter+1;
                            end
                            if (iscell(value{counter-1}))
                                value{counter-1}=''; %clear dummmy cell
                            end
                        end
                    else
                        header{counter}=fieldNames{m};
                        value{counter}=current.(task{i}).(fieldNames{m});
                        counter=counter+1;
                    end
                    if (iscell(value{counter-1}))
                        value{counter-1}=''; %clear dummmy cell
                    end
                end
            end
            clear C1
            C1(1,:)=header;
            C1(2,:)=value;
            
            
            C2=[ C1];
            cell2csv([folder filesep 'csv' filesep  handles.data.name{k} '_' task{i} '.csv'],C2,',');
            
            
         clear header value
            signalcounter=signalcounter+1;
            current=load([matfolder (handles.data.name{k})],'SFresults'); %,'data','param'
            
            counter=1;
            
            task={'SFresults'}; %,'param'};
            %  C1={};
            for i=1:length(task)
                
                fieldNames=fieldnames(current.(task{i}));
                for m=1:length(fieldNames)
                    
                    
                    if isstruct(current.(task{i}).(fieldNames{m}))
                        fieldNames2=fieldnames(current.(task{i}).(fieldNames{m}));
                        for n=1:length(fieldNames2)
                            if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}))
                                fieldNames3=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}));
                                %TODO
                                for l=1:length(fieldNames3)
                                    if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}))
                                        fieldNames4=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}));
                                    else
                                        header{counter}=[fieldNames{m} '_' fieldNames2{n} '_' fieldNames3{l}];
                                        value{counter}=current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l});
                                        counter=counter+1;
                                    end
                                end
                            else
                            header{counter}=[fieldNames{m} '_' fieldNames2{n}];
                            try
                                value(:,counter)=num2cell(current.(task{i}).(fieldNames{m}).(fieldNames2{n}));
                            catch
                                value{1,counter}='';
                            end
                            counter=counter+1;
                            end
                                                        if (iscell(value{counter-1}))
                                                            value{counter-1}=''; %clear dummmy cell
                                                        end
                        end
                    else
                        header{counter}=fieldNames{m};
                        value{1,counter}=current.(task{i}).(fieldNames{m});
                        counter=counter+1;
                    end
                    %                     if (iscell(value{counter-1}))
                    %                         value{counter-1}=''; %clear dummmy cell
                    %                     end
                end
            end
            clear C1
            C1(1,:)=header;
            
            C1=[C1; value];
            
            
            C2=[ C1];
            cell2csv([folder filesep 'csv' filesep  handles.data.name{k} '_' task{i} '.csv'],C2,',');
            
              clear header value
            signalcounter=signalcounter+1;
            current=load([matfolder (handles.data.name{k})],'reference'); %,'data','param'
            
            counter=1;
            
            task={'reference'}; %,'param'};
            %  C1={};
            for i=1:length(task)
                
                fieldNames=fieldnames(current.(task{i}));
                for m=1:length(fieldNames)
                    
                    
                    if isstruct(current.(task{i}).(fieldNames{m}))
                        fieldNames2=fieldnames(current.(task{i}).(fieldNames{m}));
                        for n=1:length(fieldNames2)
                            if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}))
                                fieldNames3=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}));
                                %TODO
                                for l=1:length(fieldNames3)
                                    if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}))
                                        fieldNames4=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}));
                                    else
                                        header{counter}=[fieldNames{m} '_' fieldNames2{n} '_' fieldNames3{l}];
                                        value{counter}=current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l});
                                        counter=counter+1;
                                    end
                                end
                            else
                            header{counter}=[fieldNames{m} '_' fieldNames2{n}];
                            try
                                value(:,counter)=num2cell(current.(task{i}).(fieldNames{m}).(fieldNames2{n}));
                            catch
                                value{1,counter}='';
                            end
                            counter=counter+1;
                            end
                                                        if (iscell(value{counter-1}))
                                                            value{counter-1}=''; %clear dummmy cell
                                                        end
                        end
                    else
                        header{counter}=fieldNames{m};
                        value{1,counter}=current.(task{i}).(fieldNames{m});
                        counter=counter+1;
                    end
                    %                     if (iscell(value{counter-1}))
                    %                         value{counter-1}=''; %clear dummmy cell
                    %                     end
                end
            end
            clear C1
            C1(1,:)=header;
            
            C1=[C1; value];
            
            
            C2=[ C1];
            cell2csv([folder filesep 'csv' filesep  handles.data.name{k} '_' task{i} '.csv'],C2,',');
      
            clear header value
            signalcounter=signalcounter+1;
            current=load([matfolder (handles.data.name{k})],'signal'); %,'data','param'
            
            counter=1;
            
            task={'signal'}; %,'param'};
            %  C1={};
            for i=1:length(task)
                
                fieldNames=fieldnames(current.(task{i}));
                for m=1:length(fieldNames)
                    
                    
                    if isstruct(current.(task{i}).(fieldNames{m}))
                        fieldNames2=fieldnames(current.(task{i}).(fieldNames{m}));
                        for n=1:length(fieldNames2)
                            %                             if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}))
                            %                                 fieldNames3=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}));
                            %                                 %TODO
                            %                                 for l=1:length(fieldNames3)
                            %                                     if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}))
                            %                                         fieldNames4=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}));
                            %                                     else
                            %                                         header{counter}=[fieldNames{m} '_' fieldNames2{n} '_' fieldNames3{l}];
                            %                                         value{counter}=current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l});
                            %                                         counter=counter+1;
                            %                                     end
                            %                                 end
                            %                             else
                            header{counter}=[fieldNames{m} '_' fieldNames2{n}];
                            try
                                value(:,counter)=num2cell(current.(task{i}).(fieldNames{m}).(fieldNames2{n}));
                            catch
                                value{1,counter}='';
                            end
                            counter=counter+1;
                            %                            end
                            %                             if (iscell(value{counter-1}))
                            %                                 value{counter-1}=''; %clear dummmy cell
                            %                             end
                        end
                    else
                        if ~strcmp(fieldNames{m},'id')
                        header{counter}=fieldNames{m};
                        value{1,counter}=current.(task{i}).(fieldNames{m});
                        counter=counter+1;
                        end
                    end
                    %                     if (iscell(value{counter-1}))
                    %                         value{counter-1}=''; %clear dummmy cell
                    %                     end
                end
            end
            clear C1
            C1(1,:)=header;
            C1=[C1; value];
            
            
            C2=[ C1];
            cell2csv([folder filesep 'csv' filesep  handles.data.name{k} '_' task{i} '.csv'],C2,',');
            
            
    
            clear header value
            signalcounter=signalcounter+1;
            current=load([matfolder (handles.data.name{k})],'labels'); %,'data','param'
            
            counter=1;
            
            task={'labels'}; %,'param'};
            %  C1={};
            for i=1:length(task)
                
                fieldNames=fieldnames(current.(task{i}));
                for m=1:length(fieldNames)
                    
                    
                    if isstruct(current.(task{i}).(fieldNames{m}))
                        fieldNames2=fieldnames(current.(task{i}).(fieldNames{m}));
                        for n=1:length(fieldNames2)
                            if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}))
                                fieldNames3=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}));
                                %TODO
                                for l=1:length(fieldNames3)
                                    if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}))
                                        fieldNames4=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}));
                                    else
                                        header{counter}=[fieldNames{m} '_' fieldNames2{n} '_' fieldNames3{l}];
                                        value{counter}=current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l});
                                        counter=counter+1;
                                    end
                                end
                            else
                                header{counter}=[fieldNames{m} '_' fieldNames2{n}];
                                value{counter}=current.(task{i}).(fieldNames{m}).(fieldNames2{n});
                                counter=counter+1;
                            end
                            if (iscell(value{counter-1}))
                                value{counter-1}=''; %clear dummmy cell
                            end
                        end
                    else
                        header{counter}=fieldNames{m};
                        value{counter}=current.(task{i}).(fieldNames{m});
                        counter=counter+1;
                    end
                    if (iscell(value{counter-1}))
                        value{counter-1}=''; %clear dummmy cell
                    end
                end
            end
            clear C1
            C1(1,:)=header;
            C1(2,:)=value;
            
            
            C2=[ C1];
            cell2csv([folder filesep 'csv' filesep  handles.data.name{k} '_' task{i} '.csv'],C2,',');
            
  
            clear header value
            signalcounter=signalcounter+1;
            current=load([matfolder (handles.data.name{k})],'param'); %,'data','param'
            
            counter=1;
            
            task={'param'}; %,'param'};
            %  C1={};
            for i=1:length(task)
                
                fieldNames=fieldnames(current.(task{i}));
                for m=1:length(fieldNames)
                    
                    
                    if isstruct(current.(task{i}).(fieldNames{m}))
                        fieldNames2=fieldnames(current.(task{i}).(fieldNames{m}));
                        for n=1:length(fieldNames2)
                            if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}))
                                fieldNames3=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}));
                                %TODO
                                for l=1:length(fieldNames3)
                                    if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}))
                                        fieldNames4=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}));
                                    else
                                        header{counter}=[fieldNames{m} '_' fieldNames2{n} '_' fieldNames3{l}];
                                        value{counter}=current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l});
                                        counter=counter+1;
                                    end
                                end
                            else
                                header{counter}=[fieldNames{m} '_' fieldNames2{n}];
                                value{counter}=current.(task{i}).(fieldNames{m}).(fieldNames2{n});
                                counter=counter+1;
                            end
                            if (iscell(value{counter-1}))
                                value{counter-1}=''; %clear dummmy cell
                            end
                        end
                    else
                        header{counter}=fieldNames{m};
                        value{counter}=current.(task{i}).(fieldNames{m});
                        counter=counter+1;
                    end
                    if (iscell(value{counter-1}))
                        value{counter-1}=''; %clear dummmy cell
                    end
                end
            end
            clear C1
            C1(1,:)=header;
            C1(2,:)=value;
            
            
            C2=[ C1];
            cell2csv([folder filesep 'csv' filesep handles.data.name{k} '_' task{i} '.csv'],C2,',');
            
    end


%cell2csv(['metacsv/allSimMeta.csv'],C2,'#');