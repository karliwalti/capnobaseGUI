%fixed parameters

% Model imputs:
t_sample         = 1; %0.1;  % sampling rate for all logging
t_sample_sensor     =1/300;
%-----------------------------------------
%Cardiac output:
%Qpdot    = 10/60;    % litres/sec
%Qpdot    =  5/60;    % litres/sec nominal
% Qpdot    =  6.48/60; % litres/sec (Davis & Mapleson 1981, 1993)
 Qpdot   = 6.48/60*0.83262; % to get V/Q approx 1
%----------------------------------
% Conditions:
T_alv    = 35;      % deg C airway & alveoli same temp for now
T_aw     = 35;      % deg C 
T_stp    = 0;       % deg C
P_baro   = 101;     % kPa
P_stp    = 101.325; % kPa
P_A_H2O  = 0.6105*exp(17.27*T_alv/(237.3+T_alv)); %(Barenbrug 3rd edition 1974)
P_aw_H2O = 0.6105*exp(17.27*T_aw/(237.3+T_aw)); %(Barenbrug 3rd edition 1974)
%------------------------------------------------
% Constants:
K_press  = 760/101.325;     % mm Hg / kPa
R        = 8314.3;  % universal gas constant J/(K-mole)
Kg_alv   = R*(T_alv+273.15)/(P_baro*1000);  % litres/mole of ideal gas in alveoli
Kg_aw    = R*(T_aw+273.15)/(P_baro*1000);  % litres/mole of ideal gas in airways
K_stp    = R*(T_stp+273.15)/(P_stp*1000);  % litres/mole of ideal gas in airways
%--------------------------------------------------------
% Simulation parameters:
n_delay_buffer = 1024*40;

CO2_delay=2;

%---------------------------------------------------------
% Inspired gases:
Fi_N2O_mean  = 0.0;    % mean inspired N2O
Fi_O2_mean   = 0.35;
Fi_N2_mean    = 1-(Fi_O2_mean + Fi_N2O_mean);    % mean inspired N2

if abs(Fi_N2O_mean+Fi_O2_mean+Fi_N2_mean-1)>1e-6;
   disp(' ');
   disp('Inspired gases dont add up to 1')
   return
   end
   
Fi_error = 1e-6; % For testing insp gas composition in anaesthetic machine



event_time_vector=[0; 18; 25;];
Tselector=2; %select which time value is used for deadspace calculation

% Resp Parameters;
FRC             = 2.2; % (litres) nominal, includes deadspace
% Ref: Snyder et al 1975 p 345

 t_resp          = [60/10; 60/10.5; 60/10;]; %[60/8; 60/8;] %[60/4; 60/40;]  % seconds Resp period Nominal
% Ref for 12 breaths/min: Snyder table 120 page 347

%t_resp          = 80/10;  % slower than Nominal to keep PCO2 up

%     %second frequency
%     t_resp2          = 40/10;  % slower than Nominal to keep PCO2 up
%     mid_experiment=30;
%     Insp_duty_cycle2= 30;

% WK max resp rate
%t_resp          =   60/40;

%t_resp           = 4;  % seconds Resp period hypervent
% t_resp           = 8;  % seconds Resp period hypovent

%% Minute volume set first
V_minute_total   = [5; 5; 5]; %[3 ;8 ];
V_tidal          = V_minute_total.*t_resp/60;



%V_tidal          = [0.750; 0.75;] % ref Snyder et al p 347
%V_minute_total   = V_tidal./t_resp*60;

m_tidal          = V_tidal/Kg_aw; % moles 

IEratio          = [1/2; 1/2; 1/2]; %[1/1; 1/4;] % use / for :
Insp_duty_cycle  = 100./(1./IEratio+1);     % percent

t_insp           = t_resp.*Insp_duty_cycle./100;
A_resp_timing    = 1;  
% A_resp_timing    = boolean(1);  % To make resp timing signal into a boolean variable
Vdot_insp_am     = V_tidal./t_insp;  % l/sec from anaesthetic machine


mdot_insp_am     = [event_time_vector m_tidal./t_insp;];  % moles/sec from anaesthetic machine %to model

%% WK varible respirator
mod_duty_cycle=[event_time_vector Insp_duty_cycle./100;]; %to model
mod_resp_rate =[event_time_vector 1./t_resp;]; %to model


%% Lung mechanical parameters:
PEEP        = 0.5; % nominal
% Elastance   = 1; % kPa/litre  nominal
Elastance   = [.75; .75; .75]; % kPa/litre  nominal %.75 %max 150
tElastance = [event_time_vector Elastance ];
conductance = 2; % (l/sec)/kPa nominal


%% factor for changing metabolic rate
metabolicscale=1; %3 %1.5; %1


%% WK added cardiac oscillation

mdot_cardiac_am = 0;% mdot_insp_am/2; % 0 : no CO
t_cardiac=1.1; % cadiac period (secs)
Cardiac_duty_cycle=40;
%cardiac_freq=1*2*pi;

%% WK sensor noise power

sensor_co2_noise_power=5 *10^-9;
sensor_flow_noise_power=5 *10^-9;


%% Deadspace volumes calculated using Weibel's Model A
% volumes of generations 5 and over corrected according to equation 4
% from Schwardt (Scherer) et al 1991 (Ref #274) 

%Weibel generations:
z=0:23;
% Weibel equations 11.8 & 11.9 (in ml):
V_z = 1e-3.*(30.5.*exp(-1.003.*z).*(z<=3)...
      +3.3.*exp((0.0125.*z-0.0626).*z).*(z>3));

% Large airway deadspace is fixed and not dependent on FRC:
% See Scherer (Schwardt et al Annals of Biomed Eng 1991)
% Conducting airways which are constant vol are generations 0 - 4:
V_deadspace_large  = sum(V_z(1:5));

% Correction factor for inflation of Weibel's model to 4800 ml:
% Equation 4 in Schwardt et al Annals of Biomed Eng 1991

K_weibel=(FRC-V_deadspace_large+V_tidal(Tselector)/2)/(4.8-V_deadspace_large);

% medium airways Weibel generations 5 - 16 depend on FRC and tidal vol
V_deadspace_medium = K_weibel.*sum(V_z(6:17));

% small airways Weibel generations 17 - 18 depend on FRC and tidal vol
V_deadspace_small  = K_weibel.*sum(V_z(18:19));

%% deadspace instrument
V_deadspace_instrument =  .5;%0.9 %0.5    % litres 0.8 %0.050;   
V_deadspace_anatomical = V_deadspace_large...
   +V_deadspace_medium+V_deadspace_small;        % litres
V_deadspace_total      = V_deadspace_instrument + V_deadspace_anatomical; % litres

%% Fractional alveolar volumes 
% NB1: Fractional values must all be > 0 or div by zero error results
% NB2: all other lung params are related to these volumes
% Nominal values (yield steady state values in resp17_ic1.mat):
%F_v_alv_deadspace = 0.01;
%F_v_alv_hivq     = 0.01;
%F_v_alv_midvq    = 0.97;
%F_v_alv_lovq     = 0.01;

% Alternate values:
F_v_alv_deadspace = 0.001;   % Normal value
%F_v_alv_deadspace = 0.1;
F_v_alv_hivq     = (1-F_v_alv_deadspace)/3;
F_v_alv_midvq    = (1-F_v_alv_deadspace)/3;
F_v_alv_lovq     = (1-F_v_alv_deadspace)/3;

%Check that fractional alv vols add up to unity:
if abs(F_v_alv_deadspace+F_v_alv_hivq+F_v_alv_midvq+F_v_alv_lovq-1)>1e-3
   disp(' ');
   disp('Fractional ventilation values not equal to 1')
   return
   end
   
% Now set up all deadspace volumes (litres):
% Large airways per compartment (three identical compartments):
V_deadspace_large_1    = 1/3 * V_deadspace_large;

% Medium airways (four compartments not identical):
V_deadspace_med_hivq_1 = 0.5*(F_v_alv_deadspace+F_v_alv_hivq) * V_deadspace_medium;
V_deadspace_med_hivq_2 = 0.5*(F_v_alv_deadspace+F_v_alv_hivq) * V_deadspace_medium;
V_deadspace_med_lovq_1 = 0.5*(F_v_alv_midvq+F_v_alv_lovq)     * V_deadspace_medium;
V_deadspace_med_lovq_2 = 0.5*(F_v_alv_midvq+F_v_alv_lovq)     * V_deadspace_medium;

% Small airway deadspace is in proportion to alveolar volumes:
V_deadspace_small_alvdeadspace = F_v_alv_deadspace * V_deadspace_small;
V_deadspace_small_hivq         = F_v_alv_hivq      * V_deadspace_small;
V_deadspace_small_midvq        = F_v_alv_midvq     * V_deadspace_small;
V_deadspace_small_lovq         = F_v_alv_lovq      * V_deadspace_small;

%% Compartmental lung ventilation (constants that split flows between compartments)
% For alveolar ventilation to be in proportion to alveolar volume
% these constants must satisfy the following equations:
% F_insp_alv_alvds * F_insp_hivq = F_v_alv_deadspace
% F_insp_alv_hivq  * F_insp_hivq = F_v_alv_hivq
% F_insp_alv_midvq * F_insp_lovq = F_v_alv_midvq
% F_insp_alv_lovq  * F_insp_lovq = F_v_alv_lovq
% and:
% F_insp_hivq = F_v_alv_deadspace + F_v_alv_hivq 
% F_insp_lovq = F_v_alv_midvq     + F_v_alv_lovq;
% -----End of simultaneous equations

F_insp_hivq = F_v_alv_deadspace + F_v_alv_hivq;
F_insp_lovq = F_v_alv_midvq     + F_v_alv_lovq;

F_insp_alv_alvds  = F_v_alv_deadspace / F_insp_hivq;
F_insp_alv_hivq   = F_v_alv_hivq      / F_insp_hivq;
F_insp_alv_midvq  = F_v_alv_midvq     / F_insp_lovq;
F_insp_alv_lovq   = F_v_alv_lovq      / F_insp_lovq;

% Check flow fractionation constants:

if abs(F_insp_hivq + F_insp_lovq - 1) > 1e-8
   disp(' ')
   disp('Resp flow fraction error 1')
   return
end

if abs(F_insp_alv_alvds + F_insp_alv_hivq - 1) > 1e-8
   disp(' ')
   disp('Resp flow fraction error 2')
   return
end

if abs(F_insp_alv_midvq + F_insp_alv_lovq -1) > 1e-8
   disp(' ')
   disp('Resp flow fraction error 3')
   return
end

if abs(F_insp_alv_alvds  * F_insp_hivq + ....
        F_insp_alv_hivq  * F_insp_hivq + ...
        F_insp_alv_midvq * F_insp_lovq + ...
        F_insp_alv_lovq  * F_insp_lovq - 1)>1e-8;
   disp(' ')
   disp('Resp flow fraction error 4')
   return
end

%------------------------------------------------
%% Inspired gas modulation
% Only need to control pulsed inspired O2 & CO2

% NB if pulse_duty_cycle = 0 then no inspired CO2 modulation
% T_pulse_start     = t_resp*round(100/t_resp);
  T_pulse_start     = 1000; %3000; %1000 %9990;20%
%T_pulse           = 0;
T_pulse         = 10*t_resp(Tselector);
T_pulse_repeat    = 100*t_resp(Tselector); %1000*t_resp;
pulse_duty_cycle  = T_pulse/T_pulse_repeat*100;%0 %
 
% Set O2 & CO2 duty cyle to deliver CO2 only during early part of insp
% CO2 & O2 are injected into gas that all gets past the dead space
% & into the alveolar compartment
%CO2_duty_cycle   = (V_tidal-V_deadspace_total)/V_tidal*Insp_duty_cycle;%0.9*
 CO2_duty_cycle    = mod_duty_cycle;%Insp_duty_cycle(Tselector)
t_insp_CO2        = Insp_duty_cycle.*t_resp/100;

% Parameters for pulsed O2 & CO2:
Fi_O2_param_est  = 0.01; %0.35;
Fi_CO2_param_est = 0.01; %0.35;%0.1;%0.6%

% Pole cancellation:  (see notebook 31/5/00)
Vdot_A_second = (V_tidal(Tselector)-V_deadspace_total)./t_resp(Tselector);
lambda_CO2 = 4; % approx incremental CO2 solubility litres/litre/atm
F_correction = .3;   % This value used for draeger docs
%F_correction = 0.8;
Tau_lung = (FRC-V_deadspace_total)./Vdot_A_second;
Tau_lung_d=F_correction.*Tau_lung./(1+lambda_CO2.*Qpdot./Vdot_A_second);

z_CO2 = 1;%1/Tau_lung_d;  % make zero cancel ventilation pole
 p_CO2 = 1;%2.2*z_CO2;
%p_CO2 = z_CO2;
 
z_O2 = 1; 
p_O2 = z_O2;
%------------------------------------------------
%% Cardiac o/p distribution: 

Fq_error = 1e-8; % per unit tolerance on cardiac output distribution

% Pulmonary blood flows:
% Intrapulmonary & anatomical shunt:
Fq_lungs_pulmshunt       = 0.09; %0.01;    % per unit 0.1 %
Fq_lungs_anatomicalshunt = 0.01; %0.4 % 

% Perfused lung compartments get the rest of the pulmonary flow
% in proportion to their volumes:
Fq_lungs_hivq  = (1-Fq_lungs_pulmshunt-Fq_lungs_anatomicalshunt)...
   *F_v_alv_hivq/(F_v_alv_hivq+F_v_alv_midvq+F_v_alv_lovq);
Fq_lungs_midvq = (1-Fq_lungs_pulmshunt-Fq_lungs_anatomicalshunt)...
   *F_v_alv_midvq/(F_v_alv_hivq+F_v_alv_midvq+F_v_alv_lovq);
Fq_lungs_lovq  = (1-Fq_lungs_pulmshunt-Fq_lungs_anatomicalshunt)...
   *F_v_alv_lovq/(F_v_alv_hivq+F_v_alv_midvq+F_v_alv_lovq);

if abs(Fq_lungs_pulmshunt+Fq_lungs_anatomicalshunt+Fq_lungs_hivq...
+Fq_lungs_midvq+Fq_lungs_lovq-1) > Fq_error;
   disp(' ')
   disp('Error in Pulm blood flow distribution ')
   return
end

% Peripheral flows:

Fq_kidneys  = 0.215;
Fq_hepatic  = 0.069;
Fq_portal   = 0.171;
Fq_heart    = 0.041;
Fq_brain    = 0.114;
Fq_pershunt = 0.101;
Fq_muscle   = 0.096;
Fq_lean     = 0.090;
Fq_fat      = 0.103;

if abs(Fq_kidneys+Fq_hepatic+Fq_portal+Fq_heart+Fq_brain...
      +Fq_pershunt+Fq_muscle+Fq_lean+Fq_fat-1)>Fq_error;
   disp(' ')
   disp('Error in Cardiac Output distribution ')
   return
end
%--------------------------------------------------------
%% Circulatory Volumes:

Vb_tot   = 5.189;  % Mapleson 1981/93
Vb_error = 1e-3;

% Central volume:
Vb_central  = 1.296;   % ml see Mapleson spreadsheet
Vb_pulmcap     = 0.100;    % litres

%NB: Pulm cap volumes must all be >0 to prevent numerical errors
% Anatomical shunt pathway is assumed to have negligible volume

Vb_pulmcap_pulmshunt = Fq_lungs_pulmshunt*Vb_pulmcap;
Vb_pulmcap_hivq  = (Vb_pulmcap-Vb_pulmcap_pulmshunt)* F_v_alv_hivq...
   /(F_v_alv_hivq+F_v_alv_midvq+F_v_alv_lovq);
Vb_pulmcap_midvq = (Vb_pulmcap-Vb_pulmcap_pulmshunt)* F_v_alv_midvq...
   /(F_v_alv_hivq+F_v_alv_midvq+F_v_alv_lovq);
Vb_pulmcap_lovq  = (Vb_pulmcap-Vb_pulmcap_pulmshunt)* F_v_alv_lovq...
   /(F_v_alv_hivq+F_v_alv_midvq+F_v_alv_lovq);

Vb_pulm_vein   = 0.23;    % litres
Vb_pulm_art    = 0.20;    % litres
% Ref: Snyder et al (Report of the task group on reference man p 120)
% quotes pulm cap volume as 100 ml, with pulm veins=230 ml and pulm 
% arteries = 200 ml.
Vb_LV    = 0.083/0.6 + 0.05; % litres
Vb_RV    = 0.083/0.6 + 0.05; % litres
% nominal stroke vol at 5 l/min and 60 bpm is 83 ml; 
% ejection fract = 60%; 
% extra 50 ml includes some aortic volume
% Mixing in heart & lungs: see Lange et al JAP 21(4):2181 1966

Vb_common = Vb_central - (Vb_pulmcap + Vb_LV + Vb_RV);
% V_central calculated as 1296 (Davis Mapleson 1981 Table III) 

% Peripheral blood volumes:
Vb_kidneys  = 58/1e3;
Vb_hepatic  = 92/1e3;
Vb_portal   = 1014/1e3;
Vb_heart    = 40/1e3; 
Vb_brain    = 105/1e3;
Vb_pershunt = 131/1e3;
Vb_muscle   = 968/1e3;
Vb_lean     = 923/1e3;
Vb_fat      = 562/1e3;

Vb_sum = Vb_pulmcap+Vb_LV +Vb_RV...
   +Vb_common+Vb_kidneys+Vb_hepatic+Vb_portal+Vb_heart...
   +Vb_brain+Vb_pershunt+Vb_muscle+Vb_lean+Vb_fat;

if abs(Vb_sum-Vb_tot) > Vb_error;
   disp(' ')
   disp('Error in Vol distribution ')
   disp(['Vb_sum = ' num2str(Vb_sum) '   Vb_tot = ' num2str(Vb_tot)]);
   return
end
%--------------------------------------------------------
%% Tissue compartment volumes (water only, except fat compartment):
Vt_kidneys  = 304.3/1e3;   % litres
Vt_liver    = 1239.8/1e3;   % litres
Vt_portal   = 1092.1/1e3;   % litres

Vt_heart    = 230.0/1e3;   % litres
Vt_brain    = 1061.8/1e3;   % litres
Vt_muscle   = 21430.6/1e3;   % litres
Vt_lean     = 5215.3/1e3;   % litres
Vt_fat      = 15158/1e3;   % litres 

Vt_H2O_total= Vt_kidneys+Vt_liver+Vt_portal+Vt_heart+...
   Vt_brain+Vt_muscle+Vt_lean;

%--------------------------------------------
%% Metabolic data for body tissue compartments (see spreadsheet):
mdot_O2_kidneys  = metabolicscale*23.9/1e3/60/K_stp;  % moles/sec
mdot_O2_liver    = metabolicscale*64.9/1e3/60/K_stp;  % moles/sec
mdot_O2_portal   = metabolicscale*22.2/1e3/60/K_stp;  % moles/sec
mdot_O2_heart    = metabolicscale*30.6/1e3/60/K_stp;  % moles/sec
mdot_O2_brain    = metabolicscale*44.4/1e3/60/K_stp;  % moles/sec
mdot_O2_muscle   = metabolicscale*54.5/1e3/60/K_stp;  % moles/sec
mdot_O2_lean     = metabolicscale*19.2/1e3/60/K_stp;  % moles/sec
mdot_O2_fat      = metabolicscale*0;

mdot_CO2_kidneys  = metabolicscale*19.15/1e3/60/K_stp;  % moles/sec
mdot_CO2_liver    = metabolicscale*51.93/1e3/60/K_stp;  % moles/sec
mdot_CO2_portal   = metabolicscale*17.78/1e3/60/K_stp;  % moles/sec
mdot_CO2_heart    = metabolicscale*24.20/1e3/60/K_stp;  % moles/sec
mdot_CO2_brain    = metabolicscale*43.02/1e3/60/K_stp;  % moles/sec
mdot_CO2_muscle   = metabolicscale*43.62/1e3/60/K_stp;  % moles/sec
mdot_CO2_lean     = metabolicscale*15.34/1e3/60/K_stp;  % moles/sec
mdot_CO2_fat      = metabolicscale*0;

% Note: Greers & Gros et al (Physiol reviews 80(2) 2000) quote mdot_CO2_muscle = 10umole/min/100g
% which equals 35.7 umole/sec in 21.43 kg muscle

% Ganong (18th ed p 576) quotes RQ for brain as 0.95 - 0.99
%--------------------------------------------
%% Pulmonary system:

% Pulm capillary parameters & initial conditions:
% Diffusion coefficients:
K_diff_CO2 = 0.0045;    % from Hill et al (ref #169) see notebook 3 7/4/00
K_diff_O2  = 0.00022;  % ditto

% Divide diffusion coefficients in proportion 
% to alveolar compartment volumes:
% Note that a large alveolar deadspace will decrease 
% the total effective diffusion coefficient
K_diff_CO2_hivq  = K_diff_CO2*F_v_alv_hivq;
K_diff_CO2_midvq = K_diff_CO2*F_v_alv_midvq;
K_diff_CO2_lovq  = K_diff_CO2*F_v_alv_lovq;

K_diff_O2_hivq  = K_diff_O2*F_v_alv_hivq;
K_diff_O2_midvq = K_diff_O2*F_v_alv_midvq;
K_diff_O2_lovq  = K_diff_O2*F_v_alv_lovq;

%----------------------------------------------------

%% Expiratory flow time constants:
K_exp_alv_alvds = 1/1;
K_exp_alv_hivq  = 1/1;
K_exp_alv_midvq = 1/1;
K_exp_alv_lovq  = 1/1;

%% expiratory flow limits:
mdot_exp_max = [ 100 ; 100; 100]; %100;   % litres/sec
mdot_exp_min  = [ 0; 0; 0];    % don't allow negative expitatory flow
tmdot_exp_max = [event_time_vector mdot_exp_max]; %100;   % litres/sec
tmdot_exp_min  = [event_time_vector mdot_exp_min];    % don't allow negative expitatory flow
% -----------------------------------------------------
%% Dissociation curves for all body tissue compartments (water portion):
% CO2 (ref Farhi & Rahn Anaesthesiol 1960, 
% Cherniack NS & Longobardo GS Physiol Rev 1970 (page 214):
% NB original units ml/kg/mm Hg. Assume that sg is unity: 1 kg = 1 litre
alpha_CO2_heart   = 2.4/1e3*760/P_stp/K_stp;
alpha_CO2_brain   = 2.9/1e3*760/P_stp/K_stp;
alpha_CO2_muscle  = 4.2/1e3*760/P_stp/K_stp;
alpha_CO2_lean    = 4.2/1e3*760/P_stp/K_stp;  
% lean solubility same as muscle because lean comp has high protein content 
% (higher than muscle) ref: Maplesons papers
alpha_CO2_other   = 3.0/1e3*760/P_stp/K_stp;  % used for kidney, hepatic, portal
alpha_CO2_fat     = 0.9/K_stp/P_stp;           % (mole/litre)/kPa 
% Ref: Farhi & Rahn Anesthesiol 6(21):604-614 1960:

K_Co_CO2 = 0.6;    % Multiplying factor to get correct total body C_CO2
                   % of approx 15 - 16 litres STP

Co_CO2_heart  = 487*K_Co_CO2/1e3/K_stp;   % moles/kg = moles/litre water 
Co_CO2_brain  = 401*K_Co_CO2/1e3/K_stp;   
Co_CO2_muscle = 342*K_Co_CO2/1e3/K_stp;
Co_CO2_lean   = 342*K_Co_CO2/1e3/K_stp;  % same as muscle
Co_CO2_other  = 355*K_Co_CO2/1e3/K_stp;
% Ref: Farhi & Rahn Anesthesiol 6(21):604-614 1960. 

% e.g. Diss curves for heart: C_CO2 = alpha_CO2_heart*PCO2 + Bo_CO2;
%                             P_CO2 = (C_CO2 - Bo_CO2)/alpha_CO2_heart

% O2:
alpha_O2_tissue  = 0.024/K_stp/P_stp;  % (moles/litre)/kPa
alpha_O2_fat     = 5*0.024/K_stp/P_stp;  % (mole/litre)/kPa

% Ref for 5 x water solubility: 
% http://divermag.com/archives/dec96/divedoctor_Dec96.html
%Other refs that might help for O2 solubility in fat:

%Arch Biochem Biophys 1997 May 1;341(1):34-9
%Am J Physiol 1997 Mar;272(3 Pt 2):H1106-12
%Am J Physiol 1996 Jul;271(1 Pt 2):R42-7
%especially J Theor Biol 1995 Oct 21;176(4):433-45
%also Adv Exp Med Biol 1994;361:17-29
%and Adv Exp Med Biol 1991;302:703-19
%-------------------------------------------------
%% Initial conditions - tissue + delays

% arterial conditions:
C_a_CO2_i  = 20.8e-3;         % mole/l
C_a_O2_i   = 8.95e-3;          % mole/l
P_a_CO2_i  = 5.04;     % kPa  40/760*P_stp; % kPa
P_a_O2_i   = 12.95;    % kPa  100/760*P_stp;  % kPa

% venous conditions (nominal):
C_v_CO2_i  = 22.2e-3;         % mole/l
C_v_O2_i   = 7.11e-3;        % mole/l
P_v_O2_i   = 42.9/760*P_stp;  % kPa
P_v_CO2_i  = 41.7/760*P_stp;  % kPa

%Blood CO2 pulmonary circulation:
m_CO2_pulmcap_b_hivq_i      = C_a_CO2_i*Vb_pulmcap_hivq;
m_CO2_pulmcap_b_midvq_i     = C_a_CO2_i*Vb_pulmcap_midvq;
m_CO2_pulmcap_b_lovq_i      = C_a_CO2_i*Vb_pulmcap_lovq;
m_CO2_pulmcap_b_pulmshunt_i = C_a_CO2_i*Vb_pulmcap_pulmshunt;

%Blood CO2 systemic circulation:
m_CO2_LV_b_i       = C_a_CO2_i*Vb_LV;
m_CO2_RV_b_i       = C_v_CO2_i*Vb_RV;
%m_CO2_pulmcap_b_i  = C_a_CO2_i*Vb_pulmcap;
m_CO2_common_b_i   = C_a_CO2_i*Vb_common;
m_CO2_kidneys_b_i  = C_a_CO2_i*Vb_kidneys;
m_CO2_hepatic_b_i  = C_a_CO2_i*Vb_hepatic;
m_CO2_portal_b_i   = C_a_CO2_i*Vb_portal;
m_CO2_heart_b_i    = C_a_CO2_i*Vb_heart;
m_CO2_brain_b_i    = C_a_CO2_i*Vb_brain;
m_CO2_pershunt_b_i = C_a_CO2_i*Vb_pershunt;
m_CO2_muscle_b_i   = C_a_CO2_i*Vb_muscle;
m_CO2_lean_b_i     = C_a_CO2_i*Vb_lean;
m_CO2_fat_b_i      = C_a_CO2_i*Vb_fat;

%Blood O2 pulmonary circulation::

m_O2_pulmcap_b_hivq_i      = C_a_O2_i*Vb_pulmcap_hivq;
m_O2_pulmcap_b_midvq_i     = C_a_O2_i*Vb_pulmcap_midvq;
m_O2_pulmcap_b_lovq_i      = C_a_O2_i*Vb_pulmcap_lovq;
m_O2_pulmcap_b_pulmshunt_i = C_a_O2_i*Vb_pulmcap_pulmshunt;

%Blood O2 systemic circulation:
m_O2_LV_b_i       = C_a_O2_i*Vb_LV;
m_O2_RV_b_i       = C_v_O2_i*Vb_RV;
m_O2_pulmcap_b_i  = C_a_O2_i*Vb_pulmcap; 
m_O2_common_b_i   = C_a_O2_i*Vb_common;
m_O2_kidneys_b_i  = C_a_O2_i*Vb_kidneys;
m_O2_hepatic_b_i  = C_a_O2_i*Vb_hepatic;
m_O2_portal_b_i   = C_a_O2_i*Vb_portal;
m_O2_heart_b_i    = C_a_O2_i*Vb_heart; 
m_O2_brain_b_i    = C_a_O2_i*Vb_brain;
m_O2_pershunt_b_i = C_a_O2_i*Vb_pershunt;
m_O2_muscle_b_i   = C_a_O2_i*Vb_muscle;
m_O2_lean_b_i     = C_a_O2_i*Vb_lean;
m_O2_fat_b_i      = C_a_O2_i*Vb_fat;

% Tissue CO2:
m_CO2_heart_t_i    = (Co_CO2_heart  + alpha_CO2_heart *P_v_CO2_i)* Vt_heart;
m_CO2_kidneys_t_i  = (Co_CO2_other  + alpha_CO2_other *P_v_CO2_i)* Vt_kidneys;
m_CO2_liver_t_i    = (Co_CO2_other  + alpha_CO2_other *P_v_CO2_i)* Vt_liver;
m_CO2_portal_t_i   = (Co_CO2_other  + alpha_CO2_other *P_v_CO2_i)* Vt_portal;
m_CO2_brain_t_i    = (Co_CO2_brain  + alpha_CO2_brain *P_v_CO2_i)* Vt_brain;
m_CO2_muscle_t_i   = (Co_CO2_muscle + alpha_CO2_muscle*P_v_CO2_i)* Vt_muscle;
m_CO2_lean_t_i     = (Co_CO2_lean   + alpha_CO2_lean  *P_v_CO2_i)* Vt_lean;
m_CO2_fat_t_i      = P_a_CO2_i*alpha_CO2_fat*Vt_fat;

% Tissue O2:
m_O2_heart_t_i   = P_v_O2_i*alpha_O2_tissue * Vt_heart;  % moles
m_O2_kidneys_t_i = P_v_O2_i*alpha_O2_tissue * Vt_kidneys;
m_O2_liver_t_i   = P_v_O2_i*alpha_O2_tissue * Vt_liver;
m_O2_portal_t_i  = P_v_O2_i*alpha_O2_tissue * Vt_portal;
m_O2_brain_t_i   = P_v_O2_i*alpha_O2_tissue * Vt_brain;
m_O2_muscle_t_i  = P_v_O2_i*alpha_O2_tissue * Vt_muscle;
m_O2_lean_t_i    = P_v_O2_i*alpha_O2_tissue * Vt_lean;
m_O2_fat_t_i     = P_a_O2_i*alpha_O2_fat    * Vt_fat;

%--------------------------------------------------------
% Blood gas equation parameters: Olszowka
% All units are mm Hg and litres STP
% Set up olszowka blood gas parameters

% Parameters for Olszowka's dissociation curves (Olsz_diss.mdl)

% Constants:
 pH_guess  = 7.4; %Matlab 5.3
% pH_guess  = 7;

pH_guess_inv = 6.9;  % mm Hg
P_O2_guess_inv = 20;  % mm Hg

HB_GMS = 15;    % Hb in g/100 lm of whole blood
 BASE_EX = 0;    % base excess - normal = 0
% BASE_EX = -5;    % meq/litre metabolic acidosis
T_BLOOD = 37;   % blood temperature

T_STND = 37;    % standard temperature
LN10 = 2.30258509299405;  %natural log of 10 
                          %(excel has no base 10 log function)
                          
P50  = 26;                % from Olszowka's Vis basic macro
%P50  = 26.8;   % mmHg (Ref: Dexter + Hindman. Anaesthesiol 83:405 1995 Ref # 261

%------------------------------------------------------
% Sub GASCOEF()
%'THIS ROUTINE COMPUTES COEFFICIENTS NEEDED BY
%'THE various BLOOD GAS ROUTINES

%'Debug.Print
  
DHCO3BDHB1 = -2.60316;
DHCO3BDHB2 = -1.06627;
DHCO3BDHB3 = 0.450001;
DHCO3BDHB4 = -0.0338195;
BUFF_PL1 = -3.85944;
BUFF_PL2 = 0.539808;
BUFF_PL3 = -0.0244183;
BUFF_HB1 = -2.17443;
BUFF_HB2 = 1.13819;
BUFF_HB3 = -0.0742405;

CAP_O2 = HB_GMS * 1.34; %'CONVERT FROM UNITS OF GMS % TO VOLS%
HB_MEQ = CAP_O2 / 2.24; %'HB_MEQ IS IN UNITS OF MEQ/L
CAP_O2 = 0.01 * CAP_O2; %'CONVERT TO L/L

%'DH2ODS IS THE INCREASE IN CELLULAR WATER WHEN HBO2 IS COMPLETELY
%   ' DESATURATED.THE EXPRESSION BELOW IS SIMPLY AN INTERPOLATION
%    'OF VALUES FOUND BY DILL AT SEA LEVEL HB=9 MEQ/L
%    'AND AT ALTITUDE ,HB=13MEQ/L)

DH2ODS = 0.005 * HB_MEQ * (HB_MEQ - 13.5) / ((9 - 13.5) * 9);
DH2ODS = DH2ODS + 0.007 * HB_MEQ * (HB_MEQ - 9) / (13.5 * (13.5 - 9));
VC_74 = 0.05 * HB_MEQ;

%   'H2OVC IS THE AMOUNT OF CELL WATER <KGMS> IN A LITER OF BLOOD.
%   'H2OB IS THE TOTAL H2O CONTENT ,KG/L)OFBLOOD
%   '0.938 IS THE WATER CONTENT PER LITER OF PLASMA

H2OVC = 0.72 * VC_74;
H2OB = H2OVC + 0.938 * (1 - VC_74);

%   'AH2OVC,2) IS THE SLOPE OF THE RELATIONSHIP BETWEEN
%   ' VC-HCT/100- OF OXYGENATED BLOOD AND PH -HENDERSON DILL
%    'EDWARDS AND MORGAN  J.BIOL CHEM-1931:90)697

X = H2OVC / H2OB;
AH2OVC(2) = 0.14 * X * (X - 1);
AH2OVC(1) = H2OVC - 7.4 * AH2OVC(2);

%'THE CALCULATIONS BELOW ARE ESSENTIALLY THOSE DESCRIBED IN THE ABOVE
%'PAPER AND THE PAPER OF DILL ET ALS IN J.BIOL CHEM,1937)

%    'ARRAY DHCO3BDS CONTAINS THE COEFICIENTS DEFINING
%      'THE CDH EFFECT AS A FUN OF PH
DHCO3BDS(1) = HB_MEQ * DHCO3BDHB1;
DHCO3BDS(2) = HB_MEQ * DHCO3BDHB2;
DHCO3BDS(3) = HB_MEQ * DHCO3BDHB3;
DHCO3BDS(4) = HB_MEQ * DHCO3BDHB4;

%'PLASMA_PR IS THE PLASMA PROTEIN CONC. PER LITER OF BLOOD
%   'IN COMPUTING IT PLASMA PROTEIN CONC. IS ASSUMED TO
%   'BE 72.2 GRAMS PER LITER OF PLASMA

PLASMA_PR = 72.2 * (1 - VC_74);

%'DILLS PLASMA AND HB BUFFER DATA IS USED TO COMPUTE THE CURVE
% ' RELATING "BOUND CO2" OF OXYGENATED BLOOD TO PLASMA PH

AAHCO3B(2) = -HB_MEQ * BUFF_HB1 - PLASMA_PR * BUFF_PL1;
AAHCO3B(3) = -HB_MEQ * BUFF_HB2 - PLASMA_PR * BUFF_PL2;
AAHCO3B(4) = -HB_MEQ * BUFF_HB3 - PLASMA_PR * BUFF_PL3;

% 'NOW DO THE BASE EXCESS AND O2 DISSOCIATION CURVE STUFF: 
%    GASCOEF_0

%-------------------------------------
%GASCOEF_0()

%'THE POSITION OF THE ABOVE CURVE IS ADJUSTED BY COMPUTING THE "BOUND" CO2
% 'AT STANDARD CONDITIONS ,I.E BE=0) AND THEN ADDING THE THE BASE EXCESS.
% ' AT A BASE EXCESS OF 0 PH=7.4 WHEN PCO2=40. COOLING BLOOD FROM 38 TO 37
%  'SHIFTS THESE TO 7.4146 AND 38.239 RESPECTIVELY

pH = 7.4146;
PK = -5.77601 + pH * (4.77908 + pH * (-0.634518 + pH * 0.0277776));

% 'PK IS THE PK OF H2CO3 IN PLASMA..0327 IS THE SOLUBILITY
%  'OF CO2 IN PLASMA WATER

RATIO_PC_HC = exp(LN10 * (PK - pH)) / 0.0327;
H2OVC = AH2OVC(1) + AH2OVC(2) * pH;

% 'RHCO3 IS THE DONNAN R OF OXYGENATED BLOOD

RHCO3 = 3.658 - 0.3891 * pH;

% 'H2OVP IS THE AMOUNT OF PLASMA WATER -KGS/LITER BLOOD

H2OVP = H2OB - H2OVC;

% 'PCO2/RATIO_PC_HC       GIVES HCO3P-THE PLASMA HCO3.
% 'HCO3P*H2OVP + HCO3P*RHCO3*H2OVC YIELDS HCO3B-THE TOTAL HCO3
% 'IN A LITER OF BLOOD I.E. BOUND CO2.

HCO3B = (38.2392 / RATIO_PC_HC) * (H2OVP + RHCO3 * H2OVC);

% 'NOW ADJUST THE CURVE..

AHCO3B(1)=BASE_EX+HCO3B-pH*(AAHCO3B(2)+pH*(AAHCO3B(3)+pH*AAHCO3B(4)));

% 'THE FUDGE FACTOR BELOW BRINGS THE CURVE OF LOG PCO2 VS.PH
% ' OF SATURATED BLOOD INTO CLOSE AGREEMENT WITH THOSE OBTAINED
%  'USING THE SIGAARD-ANDERSON NOMOGRAM-AFTER CORRECTING
%  'THE LATTER FOR TEMPERATURE

FUDGE = 1.00522 + HB_GMS * (0.0017761 + HB_GMS * 0.0000191);
FUDGE = 1 + (FUDGE - 1) * BASE_EX / 15;

% 'MULTIPLY COEF OF BUFFER CURVE  POLY BY ABOVE FUDGE FACTOR
AHCO3B(1) = AHCO3B(1) * FUDGE;
  for I = 2:4;
    AHCO3B(I) = AAHCO3B(I) * FUDGE;
 end
 %------------------------------------------------------------    
%GASCOEF_T()

O2_SHIFT = -0.0013 * BASE_EX;

%'TEMP TERMS CALCULATED.SEE THOMAS--JAP VOL 33 PG 154-160,1972)

T_BLOOD_M_37 = T_BLOOD - 37;

%   'NOTE THAT THE BORH FACTOR --.48-- IS DPG DEPENDENT

BOHRF = 0.48;
BOHRF1 = BOHRF * (1 - T_BLOOD_M_37 * 0.0065);
BOHRF0 = O2_SHIFT - T_BLOOD_M_37 * (0.024 + BOHRF * 0.0147) - BOHRF1 * 7.4;

%   'ABOVE SUMMERIZES THE EFFECTS OF BE)PH)AND TEMP ON THE HBO2 CURVE.
 %  ' THE TERM BELOW GIVES THE TEMP EFFECT ON THE CO2 CURVE

T_FACT = exp(LN10 * (T_BLOOD_M_37 * 0.019));

%   'O2 SOLUBILITY COMPUTED.SEE THOMAS ALSO
    
SO2_B = 0.02114 + VC_74 * 0.00516;
SO2_B = SO2_B/(1+(log(T_BLOOD/37)/LN10)+0.00012*T_BLOOD_M_37*T_BLOOD_M_37);
SO2_B = 0.01*SO2_B/7.6;      %'CONVERT TO LITER/LITER PER TORR
%-----------------------------------------------------


%--------------------------------------------------------
%% Lung tissue parameters
% Model based Gronlund (1983) (ref #64)

V_lungtiss        = 0.44;   % litres (ref Snyder et al. Report of the task group on ref man p173)
% V_lungblood       = 0.53;   % litres (ref Snyder et al. Report of the task group on ref man)

Tau_CO2_lungtiss_fast = 1;     % sec - guess

alpha_CO2_lungtiss_fast = [1.3e-4 1.1e-4 1e-4];         %mole/(litre-torr)
% ref for alpha's: Gronlund (64)
alpha_CO2_lungtiss_fast = alpha_CO2_lungtiss_fast./0.1333; %mole/(litre-kPa)

PCO2_alpha           = [20     40     60];   % mm Hg
PCO2_alpha           = PCO2_alpha.*0.1333;   % convert to kPa
alpha_CO2_lungtiss_fast_1 = 1.1e-4/0.1333 ;     % mol/(litre-kPa) (representative value)
k_CO2_lungtiss_fast = (V_lungtiss*alpha_CO2_lungtiss_fast_1)/(Tau_CO2_lungtiss_fast); % mol/(sec-kPa)

alpha_CO2_lungtiss_slow = 2.86e-5./0.1333;      %mol/(litre-kPa)
k_CO2_lungtiss_slow     = 6.6e-7/0.1333;        % mol/(sec-kPa)
Tau_CO2_lungtiss_slow   = (V_lungtiss*alpha_CO2_lungtiss_slow)/(k_CO2_lungtiss_slow); % sec

% Note that CO2 solubilities are identical for all alveolar compartments

% Divide lung tissue diffusion coefficients in proportion 
% to alveolar compartment volumes:
% Lung tissue diffusion coefficients:
k_CO2_lungtiss_fast_alvds = k_CO2_lungtiss_fast*F_v_alv_deadspace;
k_CO2_lungtiss_fast_hivq  = k_CO2_lungtiss_fast*F_v_alv_hivq;
k_CO2_lungtiss_fast_midvq = k_CO2_lungtiss_fast*F_v_alv_midvq;
k_CO2_lungtiss_fast_lovq  = k_CO2_lungtiss_fast*F_v_alv_lovq;

k_CO2_lungtiss_slow_alvds = k_CO2_lungtiss_slow*F_v_alv_deadspace;
k_CO2_lungtiss_slow_hivq  = k_CO2_lungtiss_slow*F_v_alv_hivq;
k_CO2_lungtiss_slow_midvq = k_CO2_lungtiss_slow*F_v_alv_midvq;
k_CO2_lungtiss_slow_lovq  = k_CO2_lungtiss_slow*F_v_alv_lovq;

% Lung tissue volumes:
V_lungtiss_alvds = V_lungtiss*F_v_alv_deadspace;
V_lungtiss_hivq  = V_lungtiss*F_v_alv_hivq;
V_lungtiss_midvq = V_lungtiss*F_v_alv_midvq;
V_lungtiss_lovq  = V_lungtiss*F_v_alv_lovq;

%----------------------------------------------------
%% Initial conditions: General:

% start up with everything at 5% CO2:
F_CO2_i = 0.05;          % Default initial CO2 fraction in all compartments

%-----------------------------------------------
% Initial conditions Lung tissue
% assume a nominal initial mass of CO2 in lung tissue:
m_CO2_lungtiss_fast_i = F_CO2_i*(P_baro-P_A_H2O)*V_lungtiss*alpha_CO2_lungtiss_fast(2);
m_CO2_lungtiss_slow_i = F_CO2_i*(P_baro-P_A_H2O)*V_lungtiss*alpha_CO2_lungtiss_slow;  %

m_CO2_lungtiss_fast_alvds_i = F_CO2_i*(P_baro-P_A_H2O)*V_lungtiss_alvds *alpha_CO2_lungtiss_fast(2);
m_CO2_lungtiss_fast_hivq_i  = F_CO2_i*(P_baro-P_A_H2O)*V_lungtiss_hivq  *alpha_CO2_lungtiss_fast(2);
m_CO2_lungtiss_fast_midvq_i = F_CO2_i*(P_baro-P_A_H2O)*V_lungtiss_midvq *alpha_CO2_lungtiss_fast(2);
m_CO2_lungtiss_fast_lovq_i  = F_CO2_i*(P_baro-P_A_H2O)*V_lungtiss_lovq  *alpha_CO2_lungtiss_fast(2);

m_CO2_lungtiss_slow_alvds_i = F_CO2_i*(P_baro-P_A_H2O)*V_lungtiss_alvds*alpha_CO2_lungtiss_slow;
m_CO2_lungtiss_slow_hivq_i  = F_CO2_i*(P_baro-P_A_H2O)*V_lungtiss_hivq *alpha_CO2_lungtiss_slow;
m_CO2_lungtiss_slow_midvq_i = F_CO2_i*(P_baro-P_A_H2O)*V_lungtiss_midvq*alpha_CO2_lungtiss_slow;
m_CO2_lungtiss_slow_lovq_i  = F_CO2_i*(P_baro-P_A_H2O)*V_lungtiss_lovq *alpha_CO2_lungtiss_slow;

%-----------------------------------------------
%% Initial conditions lung dead space
% Lung compartments total molar quantities:

% Large airways (V_deadspace_large is deadspace per compartment):
m_deadspace_large_1 = V_deadspace_large_1/Kg_aw;

% Medium airways (four compartments not identical):
m_deadspace_med_hivq_1 = V_deadspace_med_hivq_1/Kg_aw;
m_deadspace_med_hivq_2 = V_deadspace_med_hivq_2/Kg_aw;
m_deadspace_med_lovq_1 = V_deadspace_med_lovq_1/Kg_aw;
m_deadspace_med_lovq_2 = V_deadspace_med_lovq_2/Kg_aw;

% Small airway deadspace is in proportion to alveolar volumes:
m_deadspace_small_alvdeadspace = V_deadspace_small_alvdeadspace/Kg_aw;
m_deadspace_small_hivq         = V_deadspace_small_hivq/Kg_aw;
m_deadspace_small_midvq        = V_deadspace_small_midvq/Kg_aw;
m_deadspace_small_lovq         = V_deadspace_small_lovq/Kg_aw;

%-------------------------------------------------------
% CO2 in large airway compartments:

m_CO2_ds_large_i     = F_CO2_i * m_deadspace_large_1;

% CO2 in medium airway compartments:
m_CO2_ds_med_hivq1_i = F_CO2_i * m_deadspace_med_hivq_1;
m_CO2_ds_med_hivq2_i = F_CO2_i * m_deadspace_med_hivq_2;
m_CO2_ds_med_lovq1_i = F_CO2_i * m_deadspace_med_lovq_1;
m_CO2_ds_med_lovq2_i = F_CO2_i * m_deadspace_med_lovq_2;

% CO2 in small airway compartments:
m_CO2_ds_small_alvds_i = F_CO2_i * m_deadspace_small_alvdeadspace;
m_CO2_ds_small_hivq_i  = F_CO2_i * m_deadspace_small_hivq;
m_CO2_ds_small_midvq_i = F_CO2_i * m_deadspace_small_midvq;
m_CO2_ds_small_lovq_i  = F_CO2_i * m_deadspace_small_lovq;

% N2O in large airway:
m_N2O_ds_large_i = Fi_N2O_mean *(m_deadspace_large_1 - m_CO2_ds_large_i);

% N2O in medium airway compartments:
m_N2O_ds_med_hivq1_i = Fi_N2O_mean * (m_deadspace_med_hivq_1 - m_CO2_ds_med_hivq1_i);
m_N2O_ds_med_hivq2_i = Fi_N2O_mean * (m_deadspace_med_hivq_2 - m_CO2_ds_med_hivq2_i);
m_N2O_ds_med_lovq1_i = Fi_N2O_mean * (m_deadspace_med_lovq_1 - m_CO2_ds_med_lovq1_i);
m_N2O_ds_med_lovq2_i = Fi_N2O_mean * (m_deadspace_med_lovq_2 - m_CO2_ds_med_lovq2_i);

% N2O in small airway compartments:
m_N2O_ds_small_alvds_i = Fi_N2O_mean * (m_deadspace_small_alvdeadspace - m_CO2_ds_small_alvds_i);
m_N2O_ds_small_hivq_i  = Fi_N2O_mean * (m_deadspace_small_hivq         - m_CO2_ds_small_hivq_i);
m_N2O_ds_small_midvq_i = Fi_N2O_mean * (m_deadspace_small_midvq        - m_CO2_ds_small_midvq_i);
m_N2O_ds_small_lovq_i  = Fi_N2O_mean * (m_deadspace_small_lovq         - m_CO2_ds_small_lovq_i);

% O2 in large airway:
m_O2_ds_large_i = Fi_O2_mean *(m_deadspace_large_1 - m_CO2_ds_large_i);

% O2 in medium airway compartments:
m_O2_ds_med_hivq1_i = Fi_O2_mean * (m_deadspace_med_hivq_1 - m_CO2_ds_med_hivq1_i);
m_O2_ds_med_hivq2_i = Fi_O2_mean * (m_deadspace_med_hivq_2 - m_CO2_ds_med_hivq2_i);
m_O2_ds_med_lovq1_i = Fi_O2_mean * (m_deadspace_med_lovq_1 - m_CO2_ds_med_lovq1_i);
m_O2_ds_med_lovq2_i = Fi_O2_mean * (m_deadspace_med_lovq_2 - m_CO2_ds_med_lovq2_i);

% O2 in small airway compartments:
m_O2_ds_small_alvds_i = Fi_O2_mean * (m_deadspace_small_alvdeadspace - m_CO2_ds_small_alvds_i);
m_O2_ds_small_hivq_i  = Fi_O2_mean * (m_deadspace_small_hivq         - m_CO2_ds_small_hivq_i);
m_O2_ds_small_midvq_i = Fi_O2_mean * (m_deadspace_small_midvq        - m_CO2_ds_small_midvq_i);
m_O2_ds_small_lovq_i  = Fi_O2_mean * (m_deadspace_small_lovq         - m_CO2_ds_small_lovq_i);

% N2 in large airway:
m_N2_ds_large_i = Fi_N2_mean *(m_deadspace_large_1 - m_CO2_ds_large_i);

% N2 in medium airway compartments:
m_N2_ds_med_hivq1_i = Fi_N2_mean * (m_deadspace_med_hivq_1 - m_CO2_ds_med_hivq1_i);
m_N2_ds_med_hivq2_i = Fi_N2_mean * (m_deadspace_med_hivq_2 - m_CO2_ds_med_hivq2_i);
m_N2_ds_med_lovq1_i = Fi_N2_mean * (m_deadspace_med_lovq_1 - m_CO2_ds_med_lovq1_i);
m_N2_ds_med_lovq2_i = Fi_N2_mean * (m_deadspace_med_lovq_2 - m_CO2_ds_med_lovq2_i);

% N2 in small airway compartments:
m_N2_ds_small_alvds_i = Fi_N2_mean * (m_deadspace_small_alvdeadspace - m_CO2_ds_small_alvds_i);
m_N2_ds_small_hivq_i  = Fi_N2_mean * (m_deadspace_small_hivq         - m_CO2_ds_small_hivq_i);
m_N2_ds_small_midvq_i = Fi_N2_mean * (m_deadspace_small_midvq        - m_CO2_ds_small_midvq_i);
m_N2_ds_small_lovq_i  = Fi_N2_mean * (m_deadspace_small_lovq         - m_CO2_ds_small_lovq_i);
%--------------------------------------------------------
%% Instrument deadspace:
m_ds0_i       = V_deadspace_instrument/Kg_aw;   % Instrument dead space (moles)
m_CO2_ds0_i   = F_CO2_i*m_ds0_i;           % Instrument dead space
m_N2O_ds0_i   = (m_ds0_i-m_CO2_ds0_i)*Fi_N2O_mean;
m_O2_ds0_i    = (m_ds0_i-m_CO2_ds0_i)*Fi_O2_mean;
m_N2_ds0_i    = (m_ds0_i-m_CO2_ds0_i)*Fi_N2_mean;

%----------------------------------------------
%% Alveolar initial conditions:
% V_alv_total      =  FRC-V_deadspace_total;

%*********************************************
V_alv_total      =  FRC-V_deadspace_anatomical;  % NB changed on 17/11/00
% during model parameter estimation
%***********************************************

m_alv_alvds_i    = (FRC-V_deadspace_total)/Kg_alv * F_v_alv_deadspace;
m_alv_hivq_i     = (FRC-V_deadspace_total)/Kg_alv * F_v_alv_hivq;
m_alv_midvq_i    = (FRC-V_deadspace_total)/Kg_alv * F_v_alv_midvq;
m_alv_lovq_i     = (FRC-V_deadspace_total)/Kg_alv * F_v_alv_lovq;

% CO2:
m_CO2_alv_alvds_i = F_CO2_i * m_alv_alvds_i;
m_CO2_alv_hivq_i  = F_CO2_i * m_alv_hivq_i;
m_CO2_alv_midvq_i = F_CO2_i * m_alv_midvq_i;
m_CO2_alv_lovq_i  = F_CO2_i * m_alv_lovq_i;

%O2:
m_O2_alv_alvds_i = Fi_O2_mean * (m_alv_alvds_i  - m_CO2_alv_alvds_i);
m_O2_alv_hivq_i  = Fi_O2_mean * (m_alv_hivq_i   - m_CO2_alv_hivq_i);
m_O2_alv_midvq_i = Fi_O2_mean * (m_alv_midvq_i  - m_CO2_alv_midvq_i);
m_O2_alv_lovq_i  = Fi_O2_mean * (m_alv_lovq_i   - m_CO2_alv_lovq_i);

%N2:
m_N2_alv_alvds_i = Fi_N2_mean * (m_alv_alvds_i - m_CO2_alv_alvds_i);
m_N2_alv_hivq_i  = Fi_N2_mean * (m_alv_hivq_i  - m_CO2_alv_hivq_i);
m_N2_alv_midvq_i = Fi_N2_mean * (m_alv_midvq_i - m_CO2_alv_midvq_i);
m_N2_alv_lovq_i  = Fi_N2_mean * (m_alv_lovq_i  - m_CO2_alv_lovq_i);

%N2O:
m_N2O_alv_alvds_i = Fi_N2O_mean * (m_alv_alvds_i - m_CO2_alv_alvds_i);
m_N2O_alv_hivq_i  = Fi_N2O_mean * (m_alv_hivq_i  - m_CO2_alv_hivq_i);
m_N2O_alv_midvq_i = Fi_N2O_mean * (m_alv_midvq_i - m_CO2_alv_midvq_i);
m_N2O_alv_lovq_i  = Fi_N2O_mean * (m_alv_lovq_i  - m_CO2_alv_lovq_i);
% ----------------------------------------------------------







 


%% -----------------------------------------------------


% load additional init parameters
load('resp18e_ic_norm.mat')

% extend initial  vector for volume integrator
% [info1, x01, stateNames1] = Resp18e_updatedPulse
%x_initial(58:end+1)=x_initial(57:end);
%x_initial(57)=0;

% delete the states for the removed O2/CO2 pole cancel bocks
%x_initial(85:86)=[];

%add initial value for integrator in mod respirator
%x_initial(18:end+1)=x_initial(17:end);
%x_initial(17)=0;

%add initial value for integrator in mod CO2 respirator/injector
%x_initial(86:end+1)=x_initial(85:end);
%x_initial(85)=0;





%% -----------------------------------------------------


% load additional init parameters
load('resp18e_ic_norm.mat')

% extend initial  vector for volume integrator
% [info1, x01, stateNames1] = Resp18e_updatedPulse
x_initial(58:end+1)=x_initial(57:end);
x_initial(57)=0;

% delete the states for the removed O2/CO2 pole cancel bocks
x_initial(85:86)=[];

%add initial value for integrator in mod respirator
x_initial(18:end+1)=x_initial(17:end);
x_initial(17)=0;

%add initial value for integrator in mod CO2 respirator/injector
x_initial(86:end+1)=x_initial(85:end);
x_initial(85)=0;