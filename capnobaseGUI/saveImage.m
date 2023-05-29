% makes figures out of data collection
% requires some manual adjustment of the axes box. done in windows
clear all

run configure.m

Directory.dir= dir([conf.data.rootfolder filesep conf.image.source filesep '*_signal.mat']);
Directory.dir= Directory.dir(find([Directory.dir.isdir]~=1));
filenames=cell(1,1);
counter=1;
mkdir([param.image.target filesep folder ]);
mkdir([param.image.target filesep folder '/thumbs/']);
param.samplingrate.co2=300; %TODO load from param file

for i=1:length(Directory.dir)
    [pathstr, name, ext, versn]= fileparts(Directory.dir(i).name);
    if strcmp(ext,'.mat')
        Fname{i}=[name(1:6)];%foldercontent(i).
        
        load ([conf.data.rootfolder filesep folder filesep Directory.dir(i).name])
        
        x=(1:length(data.co2.y))/param.samplingrate.co2;
        %% control plot
        
        h=figure(100);
        
        plot(x,data.co2.y,'LineWidth',1)
        axis tight
        ylim([0 10])
        ylabel('pCO2 [kPa]')
        grid on
        title(['case ' Fname{i}(1:4) '\_' Fname{i}(6)])
        
        xlabel('time [seconds]')
        set(h,'Position',[10 10 1200 500])
        set(h,'PaperPositionMode','auto')
        %set(h,'PaperType','tabloid')
        print(h,'-dpng','-r96',[conf.image.rootfolder filesep conf.image.target filesep Fname{i}])
        %user_entry = input('prompt')
        h=figure(101);
        
        plot(x,data.co2.y,'LineWidth',1)
        axis tight
        ylim([0 10])
        ylabel('pCO2 [kPa]')
        %  grid on
        % title(['CO2 from ' Fname{i}])
        
        xlabel('time [seconds]')
        % set(h,'PaperType','tabloid')
        set(h,'Position',[10 10 850 250])
        set(h,'PaperPositionMode','auto')
        print(h,'-dpng','-r96',[conf.image.rootfolder filesep conf.image.target filesep 'thumbs' filesep  Fname{i}])
    end
    
end
