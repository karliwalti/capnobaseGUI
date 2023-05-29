% makes figures out of data collection
% requires some manual adjustment of the axes box. done in windows
clear all
folder='SpecialSelect/';%'CapnobaseInVivo'; %'CapnoBaseBenchmark'; %'iPlethLongData'%
fullfolder=['/home/walterk/Documents/UBC/Matlab/productionRatingGUI/data/' folder ]
Directory.dir= dir([fullfolder '/*_signal.mat']);
Directory.dir= Directory.dir(find([Directory.dir.isdir]~=1));
filenames=cell(1,1);
counter=1;
mkdir(['../signal_images/' folder ]);
mkdir(['../signal_images/' folder '/thumbs/']);
param.samplingrate.co2=300;
x_old=0;
for i=1:length(Directory.dir)
     [pathstr, name, ext, versn]= fileparts(Directory.dir(i).name);
     if strcmp(ext,'.mat')
            Fname{i}=[name(1:end-7)];%foldercontent(i).
          
                load ([fullfolder '/' Directory.dir(i).name])
               if strcmp(Fname{i}(end),'A')
                   x_old=0;%reset
               end
                x=(1:length(data.co2.y))/param.samplingrate.co2 +x_old;
                x_old=x(end);
                %% control plot

                h=figure(100);
             
                plot(x,data.co2.y,'LineWidth',1)
                axis tight
                ylim([0 10])
                ylabel('pCO2 [kPa]')
                 grid on
                title(['case ' Fname{i}(1:end-2) '\_' Fname{i}(end)])
               
              xlabel('time [seconds]')
                   set(h,'Position',[10 10 1200 500])
                   set(h,'PaperPositionMode','auto')
                %set(h,'PaperType','tabloid')
                print(h,'-dpng','-r96',['../signal_images/' folder '/' Fname{i}])
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
                print(h,'-dpng','-r96',['../signal_images/' folder '/thumbs/'  Fname{i}])
     end

end
