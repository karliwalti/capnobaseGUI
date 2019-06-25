%WK 2010
% used for gererating a single meta file to be imported in the capnobase
% mysql database

%importfile('../signalstemp.csv')
clear all


counter=1;
% foldercontent=dir('data');
% raterID='333';
% counter=1;
% foldercontent=dir(['ratings/' raterID ]);

study='SpecialSelect/';%'CapnoBaseInVivo';%'CapnoBaseBenchmark';%%'iPlethLongData';%'default/';
folder=['/home/walterk/Documents/UBC/Matlab/productionRatingGUI/data/' study  '/'];

%csvfolder=['data/' study '/'  ];
foldercontent=dir([folder ]); %'*_meta.mat'

for i=1:length(foldercontent)
    
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
                   % mkdir(['csv/' study '/' foldercontent(i).name ])
                    handles.data.name{counter}=[foldercontent(i).name '/' name];%foldercontent(i).
                    counter=counter+1;
                end
            end
        end
        
    end
    
end

subjects=load('../metacsv/subjectsCB');
treatment=load('../metacsv/treatmentCB');

%loads new data
signalcounter=0;
for k=1:length( handles.data.name)%179%
    type=handles.data.name{k}(end-3:end);
    switch type
        case 'meta'
            signalcounter=signalcounter+1;
            current=load([folder (handles.data.name{k})],'meta'); %,'data','param'
            %upper
            
            %     fieldNames=fieldnames(current.data)
            %     for i=1:3%length(fieldNames)
            %         x(i,1)={fieldNames{i}};%size(data.(fieldNames{i}))
            %
            %         x(i,2:length(current.data.(fieldNames{i}).y)+1)=mat2cell(current.data.(fieldNames{i}).y',[1],ones(size(current.data.(fieldNames{i}).y)));%size(data.(fieldNames{i}))
            %     end
            
            %%
            %   cell2csv(['csv/' handles.data.name{k} '.csv'],x);
            %%
            %metacell=struct2cell(meta);
            counter=1;
                   header{counter}='GlobalID';
            value{signalcounter,counter}=k;
            
            header{counter+1}='picture';
            value{signalcounter,counter+1}=[(handles.data.name{k}(1:6)) '.png'];%upper
            header{counter+2}='realID';
            value{signalcounter,counter+2}=[(handles.data.name{k}(1:6)) ''];%upper
            header{counter+3}='subjectID';
            value{signalcounter,counter+3}=handles.data.name{k}(1:4);
            header{counter+4}='ratingNumID';
            value{signalcounter,counter+4}=k+100;
            header{counter+5}='sensorID';
            value{signalcounter,counter+5}=str2num(handles.data.name{k}(1:4))+1000;
            header{counter+6}='treatmentID';
             id=str2num(handles.data.name{k}(1:4))+2000;
             idx=find(treatment.data(:,2)==id,1,'first');
            value{signalcounter,counter+6}=treatment.data(idx,1);
            header{counter+7}='subID';
            id=str2num(handles.data.name{k}(1:4));
            idx=find(subjects.data(:,2)==id,1,'first');
             value{signalcounter,counter+7}=subjects.data(idx,1);
             header{counter+8}='ratingID';
            value{signalcounter,counter+8}=signalcounter+200;%[handles.data.name{k}(1:6) ''];
                header{counter+9}='co2SenseID';
            value{signalcounter,counter+9}=[54];
                header{counter+10}='flowSenseID';
            value{signalcounter,counter+10}=[55];
                header{counter+11}='pressSenseID';
            value{signalcounter,counter+11}=[56];
                header{counter+12}='folderID';
            value{signalcounter,counter+12}=signalcounter+404; %for Benchmark
            %counter=9;
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
                                        
                                        [header value]=setHeaderValue(header,value,[fieldNames{m} '_' fieldNames2{n} '_' fieldNames3{l}],current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}),signalcounter);
                               
                                    end
                                end
                            else
                         
                                     [header value]=setHeaderValue(header,value,[fieldNames{m} '_' fieldNames2{n}],current.(task{i}).(fieldNames{m}).(fieldNames2{n}),signalcounter);
                              
                            end
                         
                        end
                    else
                     
                         [header value]=setHeaderValue(header,value,[fieldNames{m}],current.(task{i}).(fieldNames{m}),signalcounter);
                                  
                    
                    end
                   
                end
            end
     
%             C1(1,:)=header;
%             C1(signalcounter+1,:)=value;
%             
%             
%             C2=[ C1];
            %    cell2csv(['metacsv/' handles.data.name{k} '.csv'],C2,';');
           
            
        case 'aram'
    task={'param'};
            %  C1={};
            
            current=load([folder (handles.data.name{k})],'param'); %,'data','param'
         
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
                                        
                                        [header value]=setHeaderValue(header,value,[fieldNames{m} '_' fieldNames2{n} '_' fieldNames3{l}],current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}),signalcounter);
                               
                                    end
                                end
                            else
                         
                                     [header value]=setHeaderValue(header,value,[fieldNames{m} '_' fieldNames2{n}],current.(task{i}).(fieldNames{m}).(fieldNames2{n}),signalcounter);
                              
                            end
                         
                        end
                    else
                     
                         [header value]=setHeaderValue(header,value,[fieldNames{m}],current.(task{i}).(fieldNames{m}),signalcounter);
                                  
                    
                    end
                   
                end
            end
                    
                  
     
    end
end

            C1(1,:)=header;
            C1=[C1; value];
            
            
            C2=[ C1];
cell2csv(['../metacsv/' study 'Meta.csv'],C2,';');