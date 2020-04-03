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

variable_all = {'flw','fsw','grnd_flux','evap','sens','Tca','qca'}; 

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

%% Attribution of urban heat island intensity

% define constants 
rho_air = 1.225;     % the air density, kg/m^3
Cp = 1004.5;         % the specific heat of air at constant pressure, J/(kg.K)
sb = 5.6704*10^(-8); % stephan-boltzman constant (W/(m^2 K^4))
lv = 2.5008e6;       % latent heat of vaporization (J/kg)

% change their names to be the ones I like 
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


% optimization inputs
limit = 10;
do_optimize = 1;
use_previously_optimized_m = 0;

[Diff_Ts,mask,m_TRM_sel_opt,...
          Rn_str_ref, Grnd_ref,ro_ref,ra_ref,rs_ref,f_TRM_ref,...
          Rn_str_sel, Grnd_sel,ro_sel,ra_sel,rs_sel,f_TRM_sel,...  
          dTs_dswd_TRM_ref,dTs_drld_TRM_ref,dTs_dTa_TRM_ref,dTs_dqa_TRM_ref,dTs_dalpha_TRM_ref,dTs_demis_TRM_ref,dTs_dra_TRM_ref,dTs_drs_TRM_ref,dTs_dGrnd_TRM_ref,...
          dTs_dswd_TRM_sel,dTs_drld_TRM_sel,dTs_dTa_TRM_sel,dTs_dqa_TRM_sel,dTs_dalpha_TRM_sel,dTs_demis_TRM_sel,dTs_dra_TRM_sel,dTs_drs_TRM_sel,dTs_dGrnd_TRM_sel,...          
          dTs_dswd_TRM,dTs_drld_TRM,dTs_dTa_TRM,dTs_dqa_TRM,dTs_dalpha_TRM,dTs_demis_TRM,dTs_dra_TRM,dTs_drs_TRM,dTs_dGrnd_TRM,...
          Ts_term_swd_TRM,Ts_term_rld_TRM,Ts_term_Ta_TRM,Ts_term_qa_TRM,Ts_term_alpha_TRM,Ts_term_emis_TRM,Ts_term_ra_TRM,Ts_term_rs_TRM,Ts_term_Grnd_TRM,...
          Ts_sum_TRM]=TRM_driver(rho_air,Cp,sb,lv,limit,do_optimize,use_previously_optimized_m,data_path,...
              Psurf_ref,swd_ref,lwd_ref,Ta_ref,qa_ref,alpha_ref,emis_ref,Qh_ref,Qle_ref,Ts_ref,...
              Psurf_sel,swd_sel,lwd_sel,Ta_sel,qa_sel,alpha_sel,emis_sel,Qh_sel,Qle_sel,Ts_sel);

%% 
save ([data_path 'all_Ts_',land_type_all{2},'_',land_type_all{1},'_daytime.mat'], 'Diff_Ts','mask', ...
          'Rn_str_ref',  'Grnd_ref', 'ro_ref', 'ra_ref', 'rs_ref', 'f_TRM_ref', ...
          'Rn_str_sel',  'Grnd_sel', 'ro_sel', 'ra_sel', 'rs_sel', 'f_TRM_sel', ...  
          'dTs_dswd_TRM_ref', 'dTs_drld_TRM_ref', 'dTs_dTa_TRM_ref', 'dTs_dqa_TRM_ref', 'dTs_dalpha_TRM_ref', 'dTs_demis_TRM_ref', 'dTs_dra_TRM_ref', 'dTs_drs_TRM_ref', 'dTs_dGrnd_TRM_ref', ...
          'dTs_dswd_TRM_sel', 'dTs_drld_TRM_sel', 'dTs_dTa_TRM_sel', 'dTs_dqa_TRM_sel', 'dTs_dalpha_TRM_sel', 'dTs_demis_TRM_sel', 'dTs_dra_TRM_sel', 'dTs_drs_TRM_sel', 'dTs_dGrnd_TRM_sel', ...          
          'dTs_dswd_TRM', 'dTs_drld_TRM', 'dTs_dTa_TRM', 'dTs_dqa_TRM', 'dTs_dalpha_TRM', 'dTs_demis_TRM', 'dTs_dra_TRM', 'dTs_drs_TRM', 'dTs_dGrnd_TRM', ...
          'Ts_term_swd_TRM', 'Ts_term_rld_TRM', 'Ts_term_Ta_TRM', 'Ts_term_qa_TRM', 'Ts_term_alpha_TRM', 'Ts_term_emis_TRM', 'Ts_term_ra_TRM','Ts_term_rs_TRM', 'Ts_term_Grnd_TRM',...
          'Ts_sum_TRM')