%% This script contains all TS qs WGT calculations
clear all
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

variable_all = {'flw','fsw','grnd_flux','evap','sens','Tca','qca'}; 

land_type_Num = length(land_type_all);
var_Num = length(variable_all);

for iland_type = 1:land_type_Num
    for ivar = 1:var_Num
   
        land_type = land_type_all{iland_type};
        variable = variable_all{ivar};
        
        load([data_path variable '_' land_type '_month_clear_daytime'])

       
    end
end

clear variable_all

variable_all = {'t_bot','q_bot','lwdn','swdn','ps'}; 

var_Num = length(variable_all);

    for ivar = 1:var_Num
   
        variable = variable_all{ivar};
        
        load([data_path variable '_month_clear_daytime'])

       
    end

disp('load completed!')

%% prepare input variables 
% Define constants
rho_air = 1.225;     % the air density, kg/m^3
Cp = 1004.5;         % the specific heat of air at constant pressure, J/(kg.K)
sb = 5.6704*10^(-8); % stephan-boltzman constant (W/(m^2 K^4))
lv = 2.5008e6;       % latent heat of vaporization (J/kg)

% change their names  
Psurf_ref = ps_month_clear_daytime;
Psurf_sel = ps_month_clear_daytime;
swd_ref   = swdn_month_clear_daytime;
swd_sel   = swdn_month_clear_daytime;
lwd_ref   = lwdn_month_clear_daytime;
lwd_sel   = lwdn_month_clear_daytime;
Ta_ref    = t_bot_month_clear_daytime;
Ta_sel    = t_bot_month_clear_daytime;
qa_ref    = q_bot_month_clear_daytime;
qa_sel    = q_bot_month_clear_daytime;
alpha_ref = 1 - eval(strcat('fsw_',land_type_all{2},'_month_clear_daytime'))./swdn_month_clear_daytime;
alpha_sel = 1 - eval(strcat('fsw_',land_type_all{1},'_month_clear_daytime'))./swdn_month_clear_daytime;
emis_ref  = 1;
emis_sel  = 1;
Qh_ref    = eval(strcat('sens_',land_type_all{2},'_month_clear_daytime'));
Qh_sel    = eval(strcat('sens_',land_type_all{1},'_month_clear_daytime'));
Qle_ref   = lv*eval(strcat('evap_',land_type_all{2},'_month_clear_daytime'));
Qle_sel   = lv*eval(strcat('evap_',land_type_all{1},'_month_clear_daytime'));
Ts_ref    = eval(strcat('Tca_',land_type_all{2},'_month_clear_daytime')); % canopy-air temperature
Ts_sel    = eval(strcat('Tca_',land_type_all{1},'_month_clear_daytime')); % canopy-air temperature
qs_ref    = eval(strcat('qca_',land_type_all{2},'_month_clear_daytime')); % canopy-air humidity
qs_sel    = eval(strcat('qca_',land_type_all{1},'_month_clear_daytime')); % canopy-air humidity

% optimization inputs
limit = 5;
do_optimize = 1;
use_previously_optimized_m = 0;

[Diff_Ts,Diff_qs,Diff_WGT,mask,m_TRM_sel_opt_Ts,m_TRM_sel_opt_qs,m_TRM_sel_opt_WGT,...
          Rn_str_ref, Grnd_ref,ro_ref,ra_ref,rs_ref,f_TRM_ref,...
          Rn_str_sel, Grnd_sel,ro_sel,ra_sel,rs_sel,f_TRM_sel,...          
          dTs_dswd_TRM_ref,dTs_drld_TRM_ref,dTs_dTa_TRM_ref,dTs_dqa_TRM_ref,dTs_dalpha_TRM_ref,dTs_demis_TRM_ref,dTs_dra_TRM_ref,dTs_drs_TRM_ref,dTs_dGrnd_TRM_ref,...
          dTs_dswd_TRM_sel,dTs_drld_TRM_sel,dTs_dTa_TRM_sel,dTs_dqa_TRM_sel,dTs_dalpha_TRM_sel,dTs_demis_TRM_sel,dTs_dra_TRM_sel,dTs_drs_TRM_sel,dTs_dGrnd_TRM_sel,...
          dqs_dswd_TRM_ref,dqs_drld_TRM_ref,dqs_dTa_TRM_ref,dqs_dqa_TRM_ref,dqs_dalpha_TRM_ref,dqs_demis_TRM_ref,dqs_dra_TRM_ref,dqs_drs_TRM_ref,dqs_dGrnd_TRM_ref,...
          dqs_dswd_TRM_sel,dqs_drld_TRM_sel,dqs_dTa_TRM_sel,dqs_dqa_TRM_sel,dqs_dalpha_TRM_sel,dqs_demis_TRM_sel,dqs_dra_TRM_sel,dqs_drs_TRM_sel,dqs_dGrnd_TRM_sel,...
          dWGT_dswd_TRM_ref,dWGT_drld_TRM_ref,dWGT_dTa_TRM_ref,dWGT_dqa_TRM_ref,dWGT_dalpha_TRM_ref,dWGT_demis_TRM_ref,dWGT_dra_TRM_ref,dWGT_drs_TRM_ref,dWGT_dGrnd_TRM_ref,...
          dWGT_dswd_TRM_sel,dWGT_drld_TRM_sel,dWGT_dTa_TRM_sel,dWGT_dqa_TRM_sel,dWGT_dalpha_TRM_sel,dWGT_demis_TRM_sel,dWGT_dra_TRM_sel,dWGT_drs_TRM_sel,dWGT_dGrnd_TRM_sel,...          
          dTs_dswd_TRM,dTs_drld_TRM,dTs_dTa_TRM,dTs_dqa_TRM,dTs_dalpha_TRM,dTs_demis_TRM,dTs_dra_TRM,dTs_drs_TRM,dTs_dGrnd_TRM,...
          Ts_term_swd_TRM,Ts_term_rld_TRM,Ts_term_Ta_TRM,Ts_term_qa_TRM,Ts_term_alpha_TRM,Ts_term_emis_TRM,Ts_term_ra_TRM,Ts_term_rs_TRM,Ts_term_Grnd_TRM,...
          Ts_sum_TRM,...
          dqs_dswd_TRM,dqs_drld_TRM,dqs_dTa_TRM,dqs_dqa_TRM,dqs_dalpha_TRM,dqs_demis_TRM,dqs_dra_TRM,dqs_drs_TRM,dqs_dGrnd_TRM,...
          qs_term_swd_TRM,qs_term_rld_TRM,qs_term_Ta_TRM,qs_term_qa_TRM,qs_term_alpha_TRM,qs_term_emis_TRM,qs_term_ra_TRM,qs_term_rs_TRM,qs_term_Grnd_TRM,...
          qs_sum_TRM,...          
          dWGT_dswd_TRM,dWGT_drld_TRM,dWGT_dTa_TRM,dWGT_dqa_TRM,dWGT_dalpha_TRM,dWGT_demis_TRM,dWGT_dra_TRM,dWGT_drs_TRM,dWGT_dGrnd_TRM,...
          WGT_term_swd_TRM,WGT_term_rld_TRM,WGT_term_Ta_TRM,WGT_term_qa_TRM,WGT_term_alpha_TRM,WGT_term_emis_TRM,WGT_term_ra_TRM,WGT_term_rs_TRM,WGT_term_Grnd_TRM,...
          WGT_sum_TRM] = HI_TRM_driver(...
              rho_air,... % air density (kg/m3)
              Cp,...      % heat capacity of dry air (J/kg/K)
              sb,...      % stephan-boltzman constant (W/(m^2 K^4))
              lv,...      % latent heat of vaporization (J/kg)
              limit,...   % the limit of sensible and latent heat fluxes for creating masks
              do_optimize,...  % do optimization for m or not
              use_previously_optimized_m,... % have you already done optimization for m or not
              data_path,...
              Psurf_ref,swd_ref,lwd_ref,Ta_ref,qa_ref,alpha_ref,emis_ref,Qh_ref,Qle_ref,Ts_ref,qs_ref,...  % inputs over the reference patch
              Psurf_sel,swd_sel,lwd_sel,Ta_sel,qa_sel,alpha_sel,emis_sel,Qh_sel,Qle_sel,Ts_sel,qs_sel);     % inputs over the perturbed patch
%% add alpha Qh Qle on 6/25 
save ([data_path 'all_Ts_',land_type_all{2},'_',land_type_all{1},'_clear_daytime.mat'], 'Diff_Ts', 'mask',...
          'Rn_str_ref',  'Grnd_ref', 'ro_ref', 'ra_ref', 'rs_ref', 'f_TRM_ref', ...
          'alpha_ref' , 'Qh_ref','Qle_ref',...
          'Rn_str_sel',  'Grnd_sel', 'ro_sel', 'ra_sel', 'rs_sel', 'f_TRM_sel', ...  
          'alpha_sel' , 'Qh_sel','Qle_sel',...
          'dTs_dswd_TRM_ref', 'dTs_drld_TRM_ref', 'dTs_dTa_TRM_ref', 'dTs_dqa_TRM_ref', 'dTs_dalpha_TRM_ref', 'dTs_demis_TRM_ref', 'dTs_dra_TRM_ref', 'dTs_drs_TRM_ref', 'dTs_dGrnd_TRM_ref', ...
          'dTs_dswd_TRM_sel', 'dTs_drld_TRM_sel', 'dTs_dTa_TRM_sel', 'dTs_dqa_TRM_sel', 'dTs_dalpha_TRM_sel', 'dTs_demis_TRM_sel', 'dTs_dra_TRM_sel', 'dTs_drs_TRM_sel', 'dTs_dGrnd_TRM_sel', ...          
          'dTs_dswd_TRM', 'dTs_drld_TRM', 'dTs_dTa_TRM', 'dTs_dqa_TRM', 'dTs_dalpha_TRM', 'dTs_demis_TRM', 'dTs_dra_TRM', 'dTs_drs_TRM', 'dTs_dGrnd_TRM', ...
          'Ts_term_swd_TRM', 'Ts_term_rld_TRM', 'Ts_term_Ta_TRM', 'Ts_term_qa_TRM', 'Ts_term_alpha_TRM', 'Ts_term_emis_TRM', 'Ts_term_ra_TRM','Ts_term_rs_TRM', 'Ts_term_Grnd_TRM',...
          'Ts_sum_TRM')
      
save ([data_path 'all_qs_',land_type_all{2},'_',land_type_all{1},'_clear_daytime.mat'], 'Diff_qs','mask',...
          'dqs_dswd_TRM_ref', 'dqs_drld_TRM_ref', 'dqs_dTa_TRM_ref', 'dqs_dqa_TRM_ref', 'dqs_dalpha_TRM_ref', 'dqs_demis_TRM_ref', 'dqs_dra_TRM_ref', 'dqs_drs_TRM_ref', 'dqs_dGrnd_TRM_ref', ...
          'dqs_dswd_TRM_sel', 'dqs_drld_TRM_sel', 'dqs_dTa_TRM_sel', 'dqs_dqa_TRM_sel', 'dqs_dalpha_TRM_sel', 'dqs_demis_TRM_sel', 'dqs_dra_TRM_sel', 'dqs_drs_TRM_sel', 'dqs_dGrnd_TRM_sel', ...          
          'dqs_dswd_TRM', 'dqs_drld_TRM', 'dqs_dTa_TRM', 'dqs_dqa_TRM', 'dqs_dalpha_TRM', 'dqs_demis_TRM', 'dqs_dra_TRM', 'dqs_drs_TRM', 'dqs_dGrnd_TRM', ...
          'qs_term_swd_TRM', 'qs_term_rld_TRM', 'qs_term_Ta_TRM', 'qs_term_qa_TRM', 'qs_term_alpha_TRM', 'qs_term_emis_TRM', 'qs_term_ra_TRM','qs_term_rs_TRM', 'qs_term_Grnd_TRM',...
          'qs_sum_TRM')
      
save ([data_path 'all_WGT_',land_type_all{2},'_',land_type_all{1},'_clear_daytime.mat'],'Diff_WGT','mask',...
          'dWGT_dswd_TRM_ref', 'dWGT_drld_TRM_ref', 'dWGT_dTa_TRM_ref', 'dWGT_dqa_TRM_ref', 'dWGT_dalpha_TRM_ref', 'dWGT_demis_TRM_ref', 'dWGT_dra_TRM_ref', 'dWGT_drs_TRM_ref', 'dWGT_dGrnd_TRM_ref', ...
          'dWGT_dswd_TRM_sel', 'dWGT_drld_TRM_sel', 'dWGT_dTa_TRM_sel', 'dWGT_dqa_TRM_sel', 'dWGT_dalpha_TRM_sel', 'dWGT_demis_TRM_sel', 'dWGT_dra_TRM_sel', 'dWGT_drs_TRM_sel', 'dWGT_dGrnd_TRM_sel', ...          
          'dWGT_dswd_TRM', 'dWGT_drld_TRM', 'dWGT_dTa_TRM', 'dWGT_dqa_TRM', 'dWGT_dalpha_TRM', 'dWGT_demis_TRM', 'dWGT_dra_TRM', 'dWGT_drs_TRM', 'dWGT_dGrnd_TRM', ...
          'WGT_term_swd_TRM', 'WGT_term_rld_TRM', 'WGT_term_Ta_TRM', 'WGT_term_qa_TRM', 'WGT_term_alpha_TRM', 'WGT_term_emis_TRM', 'WGT_term_ra_TRM','WGT_term_rs_TRM', 'WGT_term_Grnd_TRM',...
          'WGT_sum_TRM')          
