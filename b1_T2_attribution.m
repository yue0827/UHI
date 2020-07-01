clear all
close all
clc

addpath('./MatlabFunctions')
addpath('./MatlabFunctions/TRM')
addpath('./MatlabFunctions/HW')

data_path = './Generate Data/esm2mb-urban-continue-sheffield-8xdaily-20years/';

land_type_all = {'urbn','rural'};


%% load variables

disp('load...')
load([data_path 'lon_lat'])
load([data_path 'time'])

variable_all = {'flw','fsw','grnd_flux','evap','sens','Tca','qca','t_ref','q_ref'}; 

land_type_Num = length(land_type_all);
var_Num = length(variable_all);

for iland_type = 1:land_type_Num
    for ivar = 1:var_Num
   
        land_type = land_type_all{iland_type};
        variable = variable_all{ivar};
        
        load([data_path variable '_' land_type '_month_clear_nighttime'])

       
    end
end

clear variable_all

variable_all = {'t_bot','q_bot','lwdn','swdn','ps'}; 

var_Num = length(variable_all);

    for ivar = 1:var_Num
   
        variable = variable_all{ivar};
        
        load([data_path variable '_month_clear_nighttime'])

       
    end

disp('load completed!')

%% Attribution of urban heat island intensity

% define constants 
rho_air = 1.225;     % the air density, kg/m^3
Cp = 1004.5;         % the specific heat of air at constant pressure, J/(kg.K)
sb = 5.6704*10^(-8); % stephan-boltzman constant (W/(m^2 K^4))
lv = 2.5008e6;       % latent heat of vaporization (J/kg)

% change their names to be the ones I like 
Psurf_ref = ps_month_clear_nighttime;
Psurf_sel = ps_month_clear_nighttime;
swd_ref   = swdn_month_clear_nighttime;
swd_sel   = swdn_month_clear_nighttime;
lwd_ref   = lwdn_month_clear_nighttime;
lwd_sel   = lwdn_month_clear_nighttime;
Ta_ref    = t_bot_month_clear_nighttime;
Ta_sel    = t_bot_month_clear_nighttime;
qa_ref    = q_bot_month_clear_nighttime;
qa_sel    = q_bot_month_clear_nighttime;
alpha_ref = 1 - eval(strcat('fsw_',land_type_all{2},'_month_clear_nighttime'))./swdn_month_clear_nighttime;
alpha_sel = 1 - eval(strcat('fsw_',land_type_all{1},'_month_clear_nighttime'))./swdn_month_clear_nighttime;
emis_ref  = 1;
emis_sel  = 1;
Qh_ref    = eval(strcat('sens_',land_type_all{2},'_month_clear_nighttime'));
Qh_sel    = eval(strcat('sens_',land_type_all{1},'_month_clear_nighttime'));
Qle_ref   = lv*eval(strcat('evap_',land_type_all{2},'_month_clear_nighttime'));
Qle_sel   = lv*eval(strcat('evap_',land_type_all{1},'_month_clear_nighttime'));
Ts_ref    = eval(strcat('Tca_',land_type_all{2},'_month_clear_nighttime')); % canopy-air temperature
Ts_sel    = eval(strcat('Tca_',land_type_all{1},'_month_clear_nighttime')); % canopy-air temperature
T2_ref    = eval(strcat('t_ref_',land_type_all{2},'_month_clear_nighttime')); % 2m temperature
T2_sel    = eval(strcat('t_ref_',land_type_all{1},'_month_clear_nighttime')); % 2m temperature

% optimization inputs
limit = 10;
do_optimize = 1;
use_previously_optimized_m = 0;

[Diff_T2,mask,m_TRM_sel_opt_T2,...
          Rn_str_ref, Grnd_ref,ro_ref,ra_ref,rs_ref,f_TRM_ref,...
          Rn_str_sel, Grnd_sel,ro_sel,ra_sel,rs_sel,f_TRM_sel,... 
          ra_prime_ref,f_2_TRM_ref,...
          ra_prime_sel,f_2_TRM_sel,...  
          dT2_dswd_TRM_ref,dT2_drld_TRM_ref,dT2_dTa_TRM_ref,dT2_dqa_TRM_ref,dT2_dalpha_TRM_ref,dT2_demis_TRM_ref,dT2_dra_TRM_ref,dT2_drs_TRM_ref,dT2_dGrnd_TRM_ref,dT2_dra_prime_TRM_ref,...
          dT2_dswd_TRM_sel,dT2_drld_TRM_sel,dT2_dTa_TRM_sel,dT2_dqa_TRM_sel,dT2_dalpha_TRM_sel,dT2_demis_TRM_sel,dT2_dra_TRM_sel,dT2_drs_TRM_sel,dT2_dGrnd_TRM_sel,dT2_dra_prime_TRM_sel,...          
          dT2_dswd_TRM,dT2_drld_TRM,dT2_dTa_TRM,dT2_dqa_TRM,dT2_dalpha_TRM,dT2_demis_TRM,dT2_dra_TRM,dT2_drs_TRM,dT2_dGrnd_TRM,dT2_dra_prime_TRM,...
          T2_term_swd_TRM,T2_term_rld_TRM,T2_term_Ta_TRM,T2_term_qa_TRM,T2_term_alpha_TRM,T2_term_emis_TRM,T2_term_ra_TRM,T2_term_rs_TRM,T2_term_Grnd_TRM,T2_term_ra_prime_TRM,...
          T2_sum_TRM]=REF_TRM_driver(...
              rho_air,... % air density (kg/m3)
              Cp,...      % heat capacity of dry air (J/kg/K)
              sb,...      % stephan-boltzman constant (W/(m^2 K^4))
              lv,...      % latent heat of vaporization (J/kg)
              limit,...   % the limit of sensible and latent heat fluxes for creating masks
              do_optimize,...  % do optimization for m or not
              use_previously_optimized_m,... % have you already done optimization for m or not
              data_path,...
              Psurf_ref,swd_ref,lwd_ref,Ta_ref,qa_ref,alpha_ref,emis_ref,Qh_ref,Qle_ref,Ts_ref,T2_ref,...  % inputs over the reference patch
              Psurf_sel,swd_sel,lwd_sel,Ta_sel,qa_sel,alpha_sel,emis_sel,Qh_sel,Qle_sel,Ts_sel,T2_sel);     % inputs over the perturbed patch


%%        
save ([data_path 'all_T2_',land_type_all{2},'_',land_type_all{1},'_clear_nighttime.mat'], 'Diff_T2','mask', ...
          'Rn_str_ref',  'Grnd_ref', 'ro_ref', 'ra_ref', 'rs_ref', 'f_TRM_ref', ...
          'Rn_str_sel',  'Grnd_sel', 'ro_sel', 'ra_sel', 'rs_sel', 'f_TRM_sel', ...  
          'ra_prime_ref','f_2_TRM_ref',...
          'ra_prime_sel','f_2_TRM_sel',...           
          'dT2_dswd_TRM_ref', 'dT2_drld_TRM_ref', 'dT2_dTa_TRM_ref', 'dT2_dqa_TRM_ref', 'dT2_dalpha_TRM_ref', 'dT2_demis_TRM_ref', 'dT2_dra_TRM_ref', 'dT2_drs_TRM_ref', 'dT2_dGrnd_TRM_ref', ...
          'dT2_dswd_TRM_sel', 'dT2_drld_TRM_sel', 'dT2_dTa_TRM_sel', 'dT2_dqa_TRM_sel', 'dT2_dalpha_TRM_sel', 'dT2_demis_TRM_sel', 'dT2_dra_TRM_sel', 'dT2_drs_TRM_sel', 'dT2_dGrnd_TRM_sel', ...          
          'dT2_dswd_TRM', 'dT2_drld_TRM', 'dT2_dTa_TRM', 'dT2_dqa_TRM', 'dT2_dalpha_TRM', 'dT2_demis_TRM', 'dT2_dra_TRM', 'dT2_drs_TRM', 'dT2_dGrnd_TRM', ...
          'T2_term_swd_TRM', 'T2_term_rld_TRM', 'T2_term_Ta_TRM', 'T2_term_qa_TRM', 'T2_term_alpha_TRM', 'T2_term_emis_TRM', 'T2_term_ra_TRM','T2_term_rs_TRM', 'T2_term_Grnd_TRM','T2_term_ra_prime_TRM',...
          'T2_sum_TRM')
