% makes figures out of data collection
% requires some manual adjustment of the axes box. done in windows
clear all
folder='CapnobaseInVivo'; %'CapnoBaseBenchmark'; %'iPlethLongData'%
Directory.dir= dir(['data/' folder '/*_signal.mat']);
Directory.dir= Directory.dir(find([Directory.dir.isdir]~=1));
filenames=cell(1,1);
counter=1;
mkdir(['signal_images/' folder ]);
mkdir(['signal_images/' folder '/thumbs/']);
param.samplingrate.co2=300;
for i=1:length(Directory.dir)
     [pathstr, name, ext, versn]= fileparts(Directory.dir(i).name);
     if strcmp(ext,'.mat')
            Fname{i}=[name(1:6)];%foldercontent(i).
          
                load (['data/' folder '/' Directory.dir(i).name])
               
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
                print(h,'-dpng','-r96',['signal_images/' folder '/' Fname{i}])
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
                print(h,'-dpng','-r96',['signal_images/' folder '/thumbs/'  Fname{i}])
     end

end
