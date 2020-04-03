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
        
        load([data_path variable '_' land_type '_month_daytime'])

       
    end
end

clear variable_all

variable_all = {'t_bot','q_bot','lwdn','swdn','ps'}; 

var_Num = length(variable_all);

    for ivar = 1:var_Num
   
        variable = variable_all{ivar};
        
        load([data_path variable '_month_daytime'])

       
    end

disp('load completed!')

%% prepare input variables 
% Define constants
rho_air = 1.225;     % the air density, kg/m^3
Cp = 1004.5;         % the specific heat of air at constant pressure, J/(kg.K)
sb = 5.6704*10^(-8); % stephan-boltzman constant (W/(m^2 K^4))
lv = 2.5008e6;       % latent heat of vaporization (J/kg)

% change their names  
Psurf_ref = ps_month_daytime;
Psurf_sel = ps_month_daytime;
swd_ref   = swdn_month_daytime;
swd_sel   = swdn_month_daytime;
lwd_ref   = lwdn_month_daytime;
lwd_sel   = lwdn_month_daytime;
Ta_ref    = t_bot_month_daytime;
Ta_sel    = t_bot_month_daytime;
qa_ref    = q_bot_month_daytime;
qa_sel    = q_bot_month_daytime;
alpha_ref = 1 - eval(strcat('fsw_',land_type_all{2},'_month_daytime'))./swdn_month_daytime;
alpha_sel = 1 - eval(strcat('fsw_',land_type_all{1},'_month_daytime'))./swdn_month_daytime;
emis_ref  = 1;
emis_sel  = 1;
Qh_ref    = eval(strcat('sens_',land_type_all{2},'_month_daytime'));
Qh_sel    = eval(strcat('sens_',land_type_all{1},'_month_daytime'));
Qle_ref   = lv*eval(strcat('evap_',land_type_all{2},'_month_daytime'));
Qle_sel   = lv*eval(strcat('evap_',land_type_all{1},'_month_daytime'));
Ts_ref    = eval(strcat('Tca_',land_type_all{2},'_month_daytime')); % canopy-air temperature
Ts_sel    = eval(strcat('Tca_',land_type_all{1},'_month_daytime')); % canopy-air temperature
qs_ref    = eval(strcat('qca_',land_type_all{2},'_month_daytime')); % canopy-air humidity
qs_sel    = eval(strcat('qca_',land_type_all{1},'_month_daytime')); % canopy-air humidity
T2_ref    = eval(strcat('t_ref_',land_type_all{2},'_month_daytime')); % 2m temperature
T2_sel    = eval(strcat('t_ref_',land_type_all{1},'_month_daytime')); % 2m temperature
q2_ref    = eval(strcat('q_ref_',land_type_all{2},'_month_daytime')); % 2m humidity
q2_sel    = eval(strcat('q_ref_',land_type_all{1},'_month_daytime')); % 2m humidity

% optimization inputs
limit = 10;
do_optimize = 1;
use_previously_optimized_m = 0;

[Diff_T2,Diff_q2,Diff_WGT,mask,m_TRM_sel_opt_T2,m_TRM_sel_opt_q2,m_TRM_sel_opt_WGT_2m,...
          Rn_str_ref, Grnd_ref,ro_ref,ra_ref,rs_ref,f_TRM_ref,...
          Rn_str_sel, Grnd_sel,ro_sel,ra_sel,rs_sel,f_TRM_sel,...
          ra_prime_ref,f_2_TRM_ref,...
          ra_prime_sel,f_2_TRM_sel,...            
          dT2_dswd_TRM_ref,dT2_drld_TRM_ref,dT2_dTa_TRM_ref,dT2_dqa_TRM_ref,dT2_dalpha_TRM_ref,dT2_demis_TRM_ref,dT2_dra_TRM_ref,dT2_drs_TRM_ref,dT2_dGrnd_TRM_ref,dT2_dra_prime_TRM_ref,...
          dT2_dswd_TRM_sel,dT2_drld_TRM_sel,dT2_dTa_TRM_sel,dT2_dqa_TRM_sel,dT2_dalpha_TRM_sel,dT2_demis_TRM_sel,dT2_dra_TRM_sel,dT2_drs_TRM_sel,dT2_dGrnd_TRM_sel,dT2_dra_prime_TRM_sel,...
          dq2_dswd_TRM_ref,dq2_drld_TRM_ref,dq2_dTa_TRM_ref,dq2_dqa_TRM_ref,dq2_dalpha_TRM_ref,dq2_demis_TRM_ref,dq2_dra_TRM_ref,dq2_drs_TRM_ref,dq2_dGrnd_TRM_ref,dq2_dra_prime_TRM_ref,...
          dq2_dswd_TRM_sel,dq2_drld_TRM_sel,dq2_dTa_TRM_sel,dq2_dqa_TRM_sel,dq2_dalpha_TRM_sel,dq2_demis_TRM_sel,dq2_dra_TRM_sel,dq2_drs_TRM_sel,dq2_dGrnd_TRM_sel,dq2_dra_prime_TRM_sel,...
          dWGT_dswd_TRM_ref,dWGT_drld_TRM_ref,dWGT_dTa_TRM_ref,dWGT_dqa_TRM_ref,dWGT_dalpha_TRM_ref,dWGT_demis_TRM_ref,dWGT_dra_TRM_ref,dWGT_drs_TRM_ref,dWGT_dGrnd_TRM_ref,dWGT_dra_prime_TRM_ref,...
          dWGT_dswd_TRM_sel,dWGT_drld_TRM_sel,dWGT_dTa_TRM_sel,dWGT_dqa_TRM_sel,dWGT_dalpha_TRM_sel,dWGT_demis_TRM_sel,dWGT_dra_TRM_sel,dWGT_drs_TRM_sel,dWGT_dGrnd_TRM_sel,dWGT_dra_prime_TRM_sel,...
          dT2_dswd_TRM,dT2_drld_TRM,dT2_dTa_TRM,dT2_dqa_TRM,dT2_dalpha_TRM,dT2_demis_TRM,dT2_dra_TRM,dT2_drs_TRM,dT2_dGrnd_TRM,dT2_dra_prime_TRM,...
          T2_term_swd_TRM,T2_term_rld_TRM,T2_term_Ta_TRM,T2_term_qa_TRM,T2_term_alpha_TRM,T2_term_emis_TRM,T2_term_ra_TRM,T2_term_rs_TRM,T2_term_Grnd_TRM,T2_term_ra_prime_TRM,...
          T2_sum_TRM,...
          dq2_dswd_TRM,dq2_drld_TRM,dq2_dTa_TRM,dq2_dqa_TRM,dq2_dalpha_TRM,dq2_demis_TRM,dq2_dra_TRM,dq2_drs_TRM,dq2_dGrnd_TRM,dq2_dra_prime_TRM,...
          q2_term_swd_TRM,q2_term_rld_TRM,q2_term_Ta_TRM,q2_term_qa_TRM,q2_term_alpha_TRM,q2_term_emis_TRM,q2_term_ra_TRM,q2_term_rs_TRM,q2_term_Grnd_TRM,q2_term_ra_prime_TRM,...
          q2_sum_TRM,...          
          dWGT_dswd_TRM,dWGT_drld_TRM,dWGT_dTa_TRM,dWGT_dqa_TRM,dWGT_dalpha_TRM,dWGT_demis_TRM,dWGT_dra_TRM,dWGT_drs_TRM,dWGT_dGrnd_TRM,dWGT_dra_prime_TRM,...
          WGT_term_swd_TRM,WGT_term_rld_TRM,WGT_term_Ta_TRM,WGT_term_qa_TRM,WGT_term_alpha_TRM,WGT_term_emis_TRM,WGT_term_ra_TRM,WGT_term_rs_TRM,WGT_term_Grnd_TRM,WGT_term_ra_prime_TRM,...
          WGT_sum_TRM] = REF_HI_TRM_driver(...
              rho_air,... % air density (kg/m3)
              Cp,...      % heat capacity of dry air (J/kg/K)
              sb,...      % stephan-boltzman constant (W/(m^2 K^4))
              lv,...      % latent heat of vaporization (J/kg)
              limit,...   % the limit of sensible and latent heat fluxes for creating masks
              do_optimize,...  % do optimization for m or not
              use_previously_optimized_m,... % have you already done optimization for m or not
              data_path,...
              Psurf_ref,swd_ref,lwd_ref,Ta_ref,qa_ref,alpha_ref,emis_ref,Qh_ref,Qle_ref,Ts_ref,T2_ref,q2_ref,...  % inputs over the reference patch
              Psurf_sel,swd_sel,lwd_sel,Ta_sel,qa_sel,alpha_sel,emis_sel,Qh_sel,Qle_sel,Ts_sel,T2_sel,q2_sel);     % inputs over the perturbed patch

save ([data_path 'all_T2_',land_type_all{2},'_',land_type_all{1},'_daytime_test.mat'], 'Diff_T2','mask', ...
          'Rn_str_ref',  'Grnd_ref', 'ro_ref', 'ra_ref', 'rs_ref', 'f_TRM_ref', ...
          'Rn_str_sel',  'Grnd_sel', 'ro_sel', 'ra_sel', 'rs_sel', 'f_TRM_sel', ...  
          'ra_prime_ref','f_2_TRM_ref',...
          'ra_prime_sel','f_2_TRM_sel',...           
          'dT2_dswd_TRM_ref', 'dT2_drld_TRM_ref', 'dT2_dTa_TRM_ref', 'dT2_dqa_TRM_ref', 'dT2_dalpha_TRM_ref', 'dT2_demis_TRM_ref', 'dT2_dra_TRM_ref', 'dT2_drs_TRM_ref', 'dT2_dGrnd_TRM_ref', 'dT2_dra_prime_TRM_ref',...
          'dT2_dswd_TRM_sel', 'dT2_drld_TRM_sel', 'dT2_dTa_TRM_sel', 'dT2_dqa_TRM_sel', 'dT2_dalpha_TRM_sel', 'dT2_demis_TRM_sel', 'dT2_dra_TRM_sel', 'dT2_drs_TRM_sel', 'dT2_dGrnd_TRM_sel', 'dT2_dra_prime_TRM_sel',...          
          'dT2_dswd_TRM', 'dT2_drld_TRM', 'dT2_dTa_TRM', 'dT2_dqa_TRM', 'dT2_dalpha_TRM', 'dT2_demis_TRM', 'dT2_dra_TRM', 'dT2_drs_TRM', 'dT2_dGrnd_TRM', 'dT2_dra_prime_TRM',...
          'T2_term_swd_TRM', 'T2_term_rld_TRM', 'T2_term_Ta_TRM', 'T2_term_qa_TRM', 'T2_term_alpha_TRM', 'T2_term_emis_TRM', 'T2_term_ra_TRM','T2_term_rs_TRM', 'T2_term_Grnd_TRM','T2_term_ra_prime_TRM',...
          'T2_sum_TRM')
      
save ([data_path 'all_q2_',land_type_all{2},'_',land_type_all{1},'_daytime.mat'], 'Diff_q2','mask',...
          'dq2_dswd_TRM_ref', 'dq2_drld_TRM_ref', 'dq2_dTa_TRM_ref', 'dq2_dqa_TRM_ref', 'dq2_dalpha_TRM_ref', 'dq2_demis_TRM_ref', 'dq2_dra_TRM_ref', 'dq2_drs_TRM_ref', 'dq2_dGrnd_TRM_ref', 'dq2_dra_prime_TRM_ref',...
          'dq2_dswd_TRM_sel', 'dq2_drld_TRM_sel', 'dq2_dTa_TRM_sel', 'dq2_dqa_TRM_sel', 'dq2_dalpha_TRM_sel', 'dq2_demis_TRM_sel', 'dq2_dra_TRM_sel', 'dq2_drs_TRM_sel', 'dq2_dGrnd_TRM_sel', 'dq2_dra_prime_TRM_sel',...     
          'dq2_dswd_TRM', 'dq2_drld_TRM', 'dq2_dTa_TRM', 'dq2_dqa_TRM', 'dq2_dalpha_TRM', 'dq2_demis_TRM', 'dq2_dra_TRM', 'dq2_drs_TRM', 'dq2_dGrnd_TRM', 'dq2_dra_prime_TRM',...
          'q2_term_swd_TRM', 'q2_term_rld_TRM', 'q2_term_Ta_TRM', 'q2_term_qa_TRM', 'q2_term_alpha_TRM', 'q2_term_emis_TRM', 'q2_term_ra_TRM','q2_term_rs_TRM', 'q2_term_Grnd_TRM','q2_term_ra_prime_TRM',...
          'q2_sum_TRM')
      
save ([data_path 'all_WGT_2m_',land_type_all{2},'_',land_type_all{1},'_daytime.mat'],'Diff_WGT','mask',...
          'dWGT_dswd_TRM_ref', 'dWGT_drld_TRM_ref', 'dWGT_dTa_TRM_ref', 'dWGT_dqa_TRM_ref', 'dWGT_dalpha_TRM_ref', 'dWGT_demis_TRM_ref', 'dWGT_dra_TRM_ref', 'dWGT_drs_TRM_ref', 'dWGT_dGrnd_TRM_ref', 'dWGT_dra_prime_TRM_ref',...
          'dWGT_dswd_TRM_sel', 'dWGT_drld_TRM_sel', 'dWGT_dTa_TRM_sel', 'dWGT_dqa_TRM_sel', 'dWGT_dalpha_TRM_sel', 'dWGT_demis_TRM_sel', 'dWGT_dra_TRM_sel', 'dWGT_drs_TRM_sel', 'dWGT_dGrnd_TRM_sel', 'dWGT_dra_prime_TRM_sel',...     
          'dWGT_dswd_TRM', 'dWGT_drld_TRM', 'dWGT_dTa_TRM', 'dWGT_dqa_TRM', 'dWGT_dalpha_TRM', 'dWGT_demis_TRM', 'dWGT_dra_TRM', 'dWGT_drs_TRM', 'dWGT_dGrnd_TRM', 'dWGT_dra_prime_TRM',...
          'WGT_term_swd_TRM', 'WGT_term_rld_TRM', 'WGT_term_Ta_TRM', 'WGT_term_qa_TRM', 'WGT_term_alpha_TRM', 'WGT_term_emis_TRM', 'WGT_term_ra_TRM','WGT_term_rs_TRM', 'WGT_term_Grnd_TRM','WGT_term_ra_prime_TRM',...
          'WGT_sum_TRM')          
