%importfile('../signalstemp.csv')
clear all


counter=1;
% foldercontent=dir('data');
% raterID='333';
% counter=1;
% foldercontent=dir(['ratings/' raterID ]);

study='default/';
foldercontent=dir(['data/' study  ]);

for i=1:length(foldercontent)
    
    if(~foldercontent(i).isdir)
        [pathstr, name, ext, versn]= fileparts(foldercontent(i).name);
        if strcmp(ext,'.mat')
            handles.data.name{counter}=name;%foldercontent(i).
            counter=counter+1;
        end
    end
    
end
%loads new data

for k=4:length( handles.data.name)%179%
    current=load(['data/' upper(handles.data.name{k})],'meta','data','param');
    
    
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
    task={'meta','param'};
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
    header{counter}='GlobalID';
    value{counter}=k;
    
    header{counter+1}='picture';
    value{counter+1}=[upper(handles.data.name{k}) '.png'];
     header{counter+2}='realID';
    value{counter+2}=[upper(handles.data.name{k})];
      header{counter+3}='subjectID';
    value{counter+3}=k;
      header{counter+3}='ratingID';
    value{counter+3}=[handles.data.name{k}];;
     header{counter+4}='ratingNumID';
    value{counter+4}=k+60;
     header{counter+5}='sensorID';
    value{counter+5}=53;
      header{counter+6}='treatmentID';
    value{counter+6}=52;
          header{counter+7}='subID';
    value{counter+7}=183;
    C1(1,:)=header;
    C1(k+1,:)=value;
    
end
C2=[ C1];
%    cell2csv(['metacsv/' handles.data.name{k} '.csv'],C2,';');
cell2csv(['metacsv/allSimMeta.csv'],C2,'#');