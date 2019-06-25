% correct error in meta
clear all
folder=['.' ];


foldercontent=dir([folder]);
counter=0;
for i=3:length(foldercontent)
    
    if(~foldercontent(i).isdir)
       
    else %update 10/4/2010
        subfoldercontent=dir([folder '/' foldercontent(i).name '/*meta.mat']); %browse subfolder
        for k=1:length(subfoldercontent)
           
                load([folder '/' foldercontent(i).name '/' subfoldercontent(k).name],'meta')
                try       
                    if(isfield(meta.sensor.pressure,'units'))
                        meta.sensor.pressure.units='cmH2O';
                        save([folder '/' foldercontent(i).name '/' subfoldercontent(k).name],'meta')
                    end
                catch
                    disp('failed replacement')
                end
                
        end
        
        
    end
    
end