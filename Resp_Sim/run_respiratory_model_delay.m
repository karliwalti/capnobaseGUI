


clear all;

delays=[0.04:0.2:10];
study='co2delay'

for i=1:length(delays)

run initialize_parameters

CO2_delay=delays(i)
open_system('Resp18e_updatedPulse.mdl')

sim('Resp18e_updatedPulse.mdl',60)
param.samplingrate.co2=t_sample_sensor ;
param.samplingrate.flow=t_sample_sensor ;
param.offset=CO2_delay;
data.co2.y=sensor_capno1;
data.flow.y=sensor_flow1;
save(['data/' study '/delay' num2str(CO2_delay) '_signal.mat'],'param','data') 

end
