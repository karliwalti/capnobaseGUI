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

study='SpecialSelect/';%'CapnoBaseInVivo/';%'CapnoBaseBenchmark/';%'CB8minLongData/';%'iPlethLongData/';%'SimulationMarkAnsermino08_04/';%'default/';
folder=['/home/walterk/Documents/UBC/Matlab/productionRatingGUI/data/' study  ];

mkdir(['../csv/' study])

foldercontent=dir([folder]);

for i=3:length(foldercontent)
    
    if(~foldercontent(i).isdir)
        [pathstr, name, ext, versn]= fileparts(foldercontent(i).name);
        if strcmp(ext,'.mat')
            handles.data.name{counter}=name;%foldercontent(i).
            counter=counter+1;
        end
    else %update 10/4/2010
        subfoldercontent=dir([folder '/' foldercontent(i).name]); %browse subfolder
        for k=3:length(subfoldercontent)
            if(~subfoldercontent(k).isdir)
                [pathstr, name, ext, versn]= fileparts(subfoldercontent(k).name);
                
                if strcmp(ext,'.mat')
                    mkdir(['csv/' study '/' foldercontent(i).name ])
                    handles.data.name{counter}=[foldercontent(i).name '/' name];%foldercontent(i).
                    counter=counter+1;
                end
            end
        end
        
        
    end
    
end
%loads new data
signalcounter=0;
for k=1:length( handles.data.name)%179%
    type=handles.data.name{k}(end-3:end);
    switch type
        case 'meta'
            clear header value
            signalcounter=signalcounter+1;
            current=load([folder (handles.data.name{k})],'meta'); %,'data','param'
            
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
            cell2csv(['../csv/' study handles.data.name{k} '.csv'],C2,',');
            
            
        case 'tput'
            clear header value
            signalcounter=signalcounter+1;
            current=load([folder (handles.data.name{k})],'output'); %,'data','param'
            
            counter=1;
            
            task={'output'}; %,'param'};
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
                            %end
                            %                             if (iscell(value{counter-1}))
                            %                                 value{counter-1}=''; %clear dummmy cell
                            %                             end
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
            cell2csv(['../csv/' study handles.data.name{k} '.csv'],C2,',');
            
            
        case 'gnal'
            clear header value
            signalcounter=signalcounter+1;
            current=load([folder (handles.data.name{k})],'data'); %,'data','param'
            
            counter=1;
            
            task={'data'}; %,'param'};
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
            cell2csv(['../csv/' study handles.data.name{k} '.csv'],C2,',');
            
            
        case 'ting'
            clear header value
            signalcounter=signalcounter+1;
            current=load([folder (handles.data.name{k})],'rating'); %,'data','param'
            
            counter=1;
            
            task={'rating'}; %,'param'};
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
            cell2csv(['../csv/' study handles.data.name{k} '.csv'],C2,',');
            
        case 'aram'
            clear header value
            signalcounter=signalcounter+1;
            current=load([folder (handles.data.name{k})],'param'); %,'data','param'
            
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
            cell2csv(['../csv/' study handles.data.name{k} '.csv'],C2,',');
            
    end
end

%cell2csv(['metacsv/allSimMeta.csv'],C2,'#');