%% script to move files into subfolders for capnobase

clear all

handles.parameters.dataset='CapnoBaseInVivo';%'CapnoBaseBenchmark';%'CB8minLongData'; %'SimulationMarkAnsermino08_04';
counter=1;
sourcefolder='july29_10ratings';%

foldercontent=dir(['data/' handles.parameters.dataset]);
for i=3:length(foldercontent)
    
    if(foldercontent(i).isdir)
               try
       movefile(['data/' sourcefolder '/' foldercontent(i).name '/*'],['data/' handles.parameters.dataset '/' foldercontent(i).name '/'],'f');
               catch
                   disp([foldercontent(i).name ' not present or problem'])
               end
    end
    
end


