clear all;

run initialize_parameters

open_system('Resp18e_updatedPulse.mdl')

sim('Resp18e_updatedPulse.mdl',60)
