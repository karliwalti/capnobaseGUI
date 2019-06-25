%convert data
% migration from 0.x to 1.x

%copy first the files in the output and rater folser into the top folder
%(no raterid subfolder)

cd ('../../mark/')
%%
 counter=1;
    foldercontent=dir('data');
    for i=1:length(foldercontent)
        
        if(~foldercontent(i).isdir)
           [pathstr, name, ext, versn]= fileparts(foldercontent(i).name);
           if strcmp(ext,'.mat') 
           
               load(['data/' name])

               save(['data/' name '_meta'],'meta')
                save(['data/' name '_param'],'param')
                 save(['data/' name '_signal'],'data')
                 delete(['data/' name '.mat'])
            counter=counter+1;
           end
        end
        
    end
    counter=1;
    foldercontent=dir('output');
    for i=1:length(foldercontent)
        
        if(~foldercontent(i).isdir)
           [pathstr, name, ext, versn]= fileparts(foldercontent(i).name);
           if strcmp(ext,'.mat') 
           
               load(['output/' name])

               save(['data/' name '_output'],'output')
               
                % delete(['data/' name])
            counter=counter+1;
           end
        end
        
    end
    
        counter=1;
    foldercontent=dir('ratings');
    for i=1:length(foldercontent)
        
        if(~foldercontent(i).isdir)
           [pathstr, name, ext, versn]= fileparts(foldercontent(i).name);
           if strcmp(ext,'.mat') 
           
               load(['ratings/' name])

               save(['data/' name '_rating'],'rating')
               
                % delete(['data/' name])
            counter=counter+1;
           end
        end
        
    end
%            counter=1;
%     foldercontent=dir('shape');
%     for i=1:length(foldercontent)
%         
%         if(~foldercontent(i).isdir)
%            [pathstr, name, ext, versn]= fileparts(foldercontent(i).name);
%            if strcmp(ext,'.mat') 
%            
%                load(['shape/' name])
% 
%                save(['data/' name '_shape'],'shape')
%                
%                 % delete(['data/' name])
%             counter=counter+1;
%            end
%         end
%         
%     end