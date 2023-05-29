%importfile('../signalstemp.csv')
clear all

raterID='333';
counter=1;
study='SpecialSelect/';%study='CapnoBaseInVivo';%'CapnoBaseBenchmark';%%'iPlethLongData';%'default/';
folder=['/home/walterk/Documents/UBC/Matlab/productionRatingGUI/data/' study '/' ];

foldercontent=dir([folder ]); %'*_meta.mat'

for i=1:length(foldercontent)
    
    if(~foldercontent(i).isdir)
        [pathstr, name, ext, versn]= fileparts(foldercontent(i).name);
        if strcmp(ext,'.mat')
            handles.data.name{counter}=name;%foldercontent(i).
            counter=counter+1;
        end
    
     else %update 10/4/2010
        subfoldercontent=dir([folder '/' foldercontent(i).name '/*rating.mat']); %browse subfolder for rating
        for k=1:length(subfoldercontent)
            if(~subfoldercontent(k).isdir)
                [pathstr, name, ext, versn]= fileparts(subfoldercontent(k).name);
                
                if strcmp(ext,'.mat')
                   % mkdir(['csv/' study '/' foldercontent(i).name ])
                    handles.data.name{counter}=[foldercontent(i).name '/' name];%foldercontent(i).
                     handles.data.folder{counter}=foldercontent(i).name;
                    counter=counter+1;
                end
            end
        end
        
    end
    
end

%loads new data
realheader= {'rater', 'event_regularcapnogram', 'event_ventilationinadequate', 'event_cardiacoscillations', 'event_hyperventilation', 'event_hypoventilation', 'event_obstructive', 'event_losscardiacoutput', 'event_deadspace','event_circuitleak', 'event_rebreathing', 'event_curare',  'event_apnea', 'event_other','signal_quality','trend_etco2', 'trend_inspco2', 'trend_rr',  'ratingid','rater_comments'};

for k=1:length( handles.data.name)%179%
    current=load([folder '/' handles.data.name{k}]);
    
    
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
    task={'rating'};
    realvalue=cell(size(realheader));
    intvalue=zeros(size(realheader));
    %  C1={};
    for i=1:length(task)
        
        fieldNames=fieldnames(current.(task{i}));
        for m=1:length(fieldNames)
            
            
            if isstruct(current.(task{i}).(fieldNames{m}));
                fieldNames2=fieldnames(current.(task{i}).(fieldNames{m}));
                for n=1:length(fieldNames2)
                    if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}));
                        fieldNames3=fieldnames(current.(task{i}).(fieldNames{m}).(fieldNames2{n}));
                        %TODO
                        for l=1:length(fieldNames3)
                            if  isstruct(current.(task{i}).(fieldNames{m}).(fieldNames2{n}).(fieldNames3{l}));
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
    value{counter+1}=[handles.data.name{k} '.png'];
     header{counter+2}='realID';
    value{counter+2}=[handles.data.name{k}];
      header{counter+3}='subjectID';
    value{counter+3}=k;
%       header{counter+3}='ratingID';
%     value{counter+3}=2;
    
    for z=1:length(header)
        if strncmp(header(z), 'events', 6)
            A=regexp(header{z}, '_', 'split');
%  2     'Regular'       
% 3    'Inadequate Ventilation'
%  4   'Cardiac Oscillations'
%  5   'Hyperventilation'
%  6   'Hypoventilation'
%  7   'Obstructive Desease'
%  8   'Acute Loss of Cardiac Output'
%  9   'Increased Deadspace'
%  10   'Circuit Leak'
%  11   'Significant Rebreathing'
%  12   'Spontaneous Breathing / Curare'
%  13   'Absence of CO2 (Apnea, disconnection)'
%   14  'Other'
try
if(strncmp(A(5), 'present', 6))
          
                    realvalue{str2num(A{3})}=value{z};
                    intvalue(str2num(A{3}))=value{z};
end
catch
end
        end
        if strncmp(header(z), 'quality', 6)
             A=regexp(header{z}, '_', 'split');
             if(length(A)>2)
                  realvalue{15}=num2str(str2num(A{3})-1);
             end
        end
        if strncmp(header(z), 'trend', 5)
             A=regexp(header{z}, '_', 'split');
             switch A{2}
                 case 'etco2'
                  realvalue{16}=value{z};
                  case 'inspco2'
                      realvalue{17}=value{z};
                      case 'rr'
                          realvalue{18}=value{z};
             end
        end
        if strncmp(header(z), 'comment', 6)
             
                  realvalue{20}=reshape(value{z}',1,size(value{z},1)*size(value{z},2));
             
        end
    end
        realvalue{19}=[handles.data.folder{k}]; %case
        realvalue{1}='hidden'; % rater
    
    C1(1,:)=realheader;
    C1(k+1,:)=realvalue;
    C3(k,:)=intvalue;
end
C2=[ C1];
mkdir(['ratingcsv/ ' study])
%    cell2csv(['metacsv/' handles.data.name{k} '.csv'],C2,';');
cell2csv(['ratingcsv/ ' study '/allrating.csv'],C2,';');

%%
statEvents=sum(C3)