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
id=4;
persids={'https://doi.org/10.5683/SP2/MR0PTF','https://doi.org/10.5683/SP2/B1DDKP','https://doi.org/10.5683/SP2/YP7VU5','https://doi.org/10.5683/SP2/7JTWDZ','https://doi.org/10.5683/SP2/NLB8IT'};
studyids={'CB8minLongData','CBBenchmarkAllSignals','CBSimulation','CBInVivoAllSignals','CBTBMEBenchmark'}
study=studyids{id};%'CBBenchmarkAllSignals'%'CB8minLongData';%%'SpecialSelect/';'CapnoBaseInVivo/';%'CapnoBaseBenchmark/';%'iPlethLongData/';%'SimulationMarkAnsermino08_04/';%'default/';
folder=['C:\Users\wkarlen\Documents\Dropbox\Capnobase\dataverse\' study  filesep 'data' filesep];

matfolder=[folder filesep 'mat' filesep];
if (id==5)
    foldercontent=dir([matfolder filesep '**' filesep '*.mat']);
else
    foldercontent=dir([matfolder filesep '**' filesep '*meta.mat']);
end

for i=1:length(foldercontent)
    clear meta
    if(~foldercontent(i).isdir)
        [pathstr, name, ext]= fileparts(foldercontent(i).name);
       
         load([foldercontent(i).folder filesep foldercontent(i).name],'meta'); %,'data','param'
        %meta=meta.meta;
        meta.persistentID=persids{id};
         save([foldercontent(i).folder filesep foldercontent(i).name],'meta','-append')%  
    end
    
end
