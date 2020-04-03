% This is the Two-Resistance Mechanism attribution method for Qs

function [Diff_Ts,...
          Rn_str_ref, Grnd_ref,ro_ref,ra_ref,rs_ref,f_TRM_ref,...
          Rn_str_sel, Grnd_sel,ro_sel,ra_sel,rs_sel,f_TRM_sel,...          
          dTs_dswd_TRM_ref,dTs_drld_TRM_ref,dTs_dTa_TRM_ref,dTs_dqa_TRM_ref,dTs_dalpha_TRM_ref,dTs_demis_TRM_ref,dTs_dra_TRM_ref,dTs_drs_TRM_ref,dTs_dGrnd_TRM_ref,...
          dTs_dswd_TRM_sel,dTs_drld_TRM_sel,dTs_dTa_TRM_sel,dTs_dqa_TRM_sel,dTs_dalpha_TRM_sel,dTs_demis_TRM_sel,dTs_dra_TRM_sel,dTs_drs_TRM_sel,dTs_dGrnd_TRM_sel,...
          Diff_qs, ...
          dqs_dswd_TRM_ref,dqs_drld_TRM_ref,dqs_dTa_TRM_ref,dqs_dqa_TRM_ref,dqs_dalpha_TRM_ref,dqs_demis_TRM_ref,dqs_dra_TRM_ref,dqs_drs_TRM_ref,dqs_dGrnd_TRM_ref,...
          dqs_dswd_TRM_sel,dqs_drld_TRM_sel,dqs_dTa_TRM_sel,dqs_dqa_TRM_sel,dqs_dalpha_TRM_sel,dqs_demis_TRM_sel,dqs_dra_TRM_sel,dqs_drs_TRM_sel,dqs_dGrnd_TRM_sel] ...
          =Q_TRM(rho_air,Cp,sb,lv,...
              Psurf_ref,swd_ref,lwd_ref,Ta_ref,qa_ref,alpha_ref,emis_ref,Qh_ref,Qle_ref,Ts_ref,qs_ref,...
              Psurf_sel,swd_sel,lwd_sel,Ta_sel,qa_sel,alpha_sel,emis_sel,Qh_sel,Qle_sel,Ts_sel,qs_sel)
%% calculate surface humidity difference

Diff_Ts = Ts_sel - Ts_ref;       

Diff_qs = qs_sel - qs_ref;       
                   
%% calculate sensitivities based on reference state


% calculate apparent radiation and ground heat flux (which is the residual of surface energy balance equation)

Rn_str_ref = swd_ref - alpha_ref.*swd_ref + emis_ref*lwd_ref - emis_ref*sb*Ta_ref.^4; % apparent net radiation
Grnd_ref   = swd_ref - alpha_ref.*swd_ref + emis_ref*lwd_ref - emis_ref*sb*Ts_ref.^4 - Qh_ref - Qle_ref; % residual

% radiative resistance

lambda_o_ref = 1./(4*emis_ref*sb*Ta_ref.^3);
ro_ref = rho_air.*Cp.*lambda_o_ref;

% aerodynamic resistance 

ra_ref = rho_air .* Cp .* (Ts_ref - Ta_ref) ./ Qh_ref; % aerodynamic resistance

% surface resistance 

qs_sat_ref = qsat(Psurf_ref, Ts_ref); % surface saturated specific humidity
rs_ref = lv.*rho_air .* (qs_sat_ref - qa_ref) ./ Qle_ref - ra_ref; % surface resistance

% redistribution factor

Ta_c_ref  = Ta_ref-273.15;
delTa_ref = (2508.3./((Ta_c_ref + 237.3).^2).*exp((17.3.*Ta_c_ref)./(Ta_c_ref+237.3)))*1000; % de*/dT in kPa/K -- > Pa/K
gamma_ref = (Cp.*Psurf_ref)./(0.622.*lv);
f_TRM_ref = (ro_ref./ra_ref).*(1 + (delTa_ref./gamma_ref).*(ra_ref./(ra_ref + rs_ref)));

% sensitivities to incoming shortwave radiation and longwave radiation

dTs_dswd_TRM_ref = lambda_o_ref.*(1-alpha_ref)./(1+f_TRM_ref);
dTs_drld_TRM_ref = lambda_o_ref.*emis_ref./(1+f_TRM_ref);

% sensitivities to air temperature and specific humidity

dRn_str_dTa_TRM_ref = - 4*emis_ref*sb*Ta_ref.^3;
dlambda_o_dTa_TRM_ref = -3./(4*emis_ref*sb*Ta_ref.^4);
dqa_sat_dTa_TRM_ref = 0.622./Psurf_ref.*delTa_ref;
ddelta_dTa_TRM_ref = (15.3*2508.3*237.3-2*2508.3*Ta_c_ref)./(Ta_c_ref+237.3).^4.*exp((17.3*Ta_c_ref)./(Ta_c_ref+237.3))*1000;
df_TRM_dTa_ref = rho_air.*Cp./ra_ref.*(1 + (delTa_ref./gamma_ref).*(ra_ref./(ra_ref + rs_ref))).*dlambda_o_dTa_TRM_ref+ro_ref./gamma_ref./(ra_ref + rs_ref).*ddelta_dTa_TRM_ref;
qa_sat_ref = qsat(Psurf_ref, Ta_ref);
AA_ref = rho_air.*lv.*(qa_sat_ref-qa_ref)./(ra_ref+rs_ref).^2;

dTs_dTa_TRM_ref = lambda_o_ref./(1+f_TRM_ref).*dRn_str_dTa_TRM_ref...
                +(Rn_str_ref-Grnd_ref-AA_ref.*(ra_ref+rs_ref))./(1+f_TRM_ref).*dlambda_o_dTa_TRM_ref...
                -lambda_o_ref.*rho_air.*lv./(ra_ref+rs_ref)./(1+f_TRM_ref).*dqa_sat_dTa_TRM_ref...
                -lambda_o_ref.*(Rn_str_ref-Grnd_ref-AA_ref.*(ra_ref+rs_ref))./(1+f_TRM_ref).^2.*df_TRM_dTa_ref+1;
dTs_dqa_TRM_ref = lambda_o_ref./(1+f_TRM_ref).*rho_air.*lv./(ra_ref+rs_ref);

% sensitivities to albedo and emissivity 

dTs_dalpha_TRM_ref = -lambda_o_ref.*swd_ref./(1+f_TRM_ref);
% dTs_demis_TRM_ref  = lambda_o_ref.*(lwd_ref - sb*Ta_ref.^4)./(1+f_TRM_ref);
dTs_demis_TRM_ref  = lambda_o_ref.*(lwd_ref - sb*Ta_ref.^4 - (Rn_str_ref - Grnd_ref - AA_ref.*(ra_ref+rs_ref))./emis_ref)./(1+f_TRM_ref);


% sensitivities to aerodynamic and surface resistances 

df_TRM_dra_ref = -(ro_ref./(ra_ref.^2)).*(1+((delTa_ref./gamma_ref).*(ra_ref./(ra_ref+rs_ref)).^2));
df_TRM_drs_ref = -(delTa_ref./gamma_ref).*(ro_ref./(ra_ref+rs_ref).^2);

dTs_dra_TRM_ref = lambda_o_ref.*AA_ref./(1+f_TRM_ref) - df_TRM_dra_ref.*lambda_o_ref.*(Rn_str_ref-Grnd_ref-AA_ref.*(ra_ref+rs_ref))./(1+f_TRM_ref).^2;
dTs_drs_TRM_ref = lambda_o_ref.*AA_ref./(1+f_TRM_ref) - df_TRM_drs_ref.*lambda_o_ref.*(Rn_str_ref-Grnd_ref-AA_ref.*(ra_ref+rs_ref))./(1+f_TRM_ref).^2;

% sensitivity to ground heat flux

% dTs_dRn_TRM_ref = lambda_o_ref./(1+f_TRM_ref);
dTs_dGrnd_TRM_ref = -lambda_o_ref./(1+f_TRM_ref);


% sensitivity of surface saturated specific humidity to surface temperature
dqa_sat_dTa_ref = 0.622./Psurf_ref.*(2508.3./((Ta_c_ref + 237.3).^2).*exp((17.3.*Ta_c_ref)./(Ta_c_ref+237.3)))*1000;
Ts_modeled_ref = ((Rn_str_ref-Grnd_ref)-rho_air.*lv./(ra_ref+rs_ref).*(qa_sat_ref-qa_ref))./((1./lambda_o_ref)+rho_air.*Cp./ra_ref+rho_air.*lv./(ra_ref+rs_ref).*dqa_sat_dTa_ref)+Ta_ref;
qs_sat_modeled_ref = qsat(Psurf_ref, Ts_modeled_ref); % modeled surface saturated specific humidity
qs_modeled_ref = ra_ref./(ra_ref+rs_ref).*(qs_sat_modeled_ref-qa_ref)+qa_ref; % modeled surface specific humidity

Ts_c_ref  = Ts_modeled_ref-273.15;
dqs_sat_dTs_ref = 0.622./Psurf_ref.*(2508.3./((Ts_c_ref + 237.3).^2).*exp((17.3.*Ts_c_ref)./(Ts_c_ref+237.3)))*1000; % de*/dT in kPa/K -- > Pa/K

% sensitivity of surface specific humidity to albedo
BB = ra_ref./(ra_ref+rs_ref).*dqs_sat_dTs_ref;
dqs_dalpha_TRM_ref = BB.*dTs_dalpha_TRM_ref;

% sensitivity of surface specific humidity to aerodynamic resistance
dqs_dra_TRM_ref = rs_ref./(ra_ref+rs_ref).^2.*(qs_sat_modeled_ref-qa_ref)+BB.*dTs_dra_TRM_ref;

% sensitivity of surface specific humidity to surface resistance
dqs_drs_TRM_ref = -ra_ref./(ra_ref+rs_ref).^2.*(qs_sat_modeled_ref-qa_ref)+BB.*dTs_drs_TRM_ref;

% sensitivity of surface specific humidity to ground heat flux
dqs_dGrnd_TRM_ref = BB.*dTs_dGrnd_TRM_ref;

% to add
dqs_dswd_TRM_ref = zeros(size(dqs_dGrnd_TRM_ref));
dqs_drld_TRM_ref = zeros(size(dqs_dGrnd_TRM_ref));
dqs_dTa_TRM_ref  = zeros(size(dqs_dGrnd_TRM_ref));
dqs_dqa_TRM_ref  = zeros(size(dqs_dGrnd_TRM_ref));
dqs_demis_TRM_ref = zeros(size(dqs_dGrnd_TRM_ref));

%% calculate based on perturbation state

% calculate apparent radiation and ground heat flux (which is the residual of surface energy balance equation)

Rn_str_sel = swd_sel - alpha_sel.*swd_sel + emis_sel*lwd_sel - emis_sel*sb*Ta_sel.^4; % apparent net radiation
Grnd_sel   = swd_sel - alpha_sel.*swd_sel + emis_sel*lwd_sel - emis_sel*sb*Ts_sel.^4 - Qh_sel - Qle_sel; % residual

% radiative resistance 

lambda_o_sel = 1./(4*emis_sel*sb*Ta_sel.^3);
ro_sel = rho_air.*Cp.*lambda_o_sel;

% aerodynamic resistance 
ra_sel = rho_air .* Cp .* (Ts_sel - Ta_sel) ./ Qh_sel; % aerodynamic resistance

% surface resistance 
qs_sat_sel = qsat(Psurf_sel, Ts_sel); % surface saturated specific humidity
rs_sel = lv.*rho_air .* (qs_sat_sel - qa_sel) ./ Qle_sel - ra_sel; % surface resistance

% redistribution factor
Ta_c_sel = Ta_sel-273.15;
delTa_sel = (2508.3./((Ta_c_sel + 237.3).^2).*exp((17.3.*Ta_c_sel)./(Ta_c_sel+237.3)))*1000; % de*/dT in kPa/K -- > Pa/K
gamma_sel = (Cp.*Psurf_sel)./(0.622.*lv);
f_TRM_sel = (ro_sel./ra_sel).*(1 + (delTa_sel./gamma_sel).*(ra_sel./(ra_sel + rs_sel)));

% sensitivities to incoming shortwave radiation and longwave radiation

dTs_dswd_TRM_sel = lambda_o_sel.*(1-alpha_sel)./(1+f_TRM_sel);
dTs_drld_TRM_sel = lambda_o_sel.*emis_sel./(1+f_TRM_sel);

% sensitivities to air temperature and specific humidity
 
dRn_str_dTa_TRM_sel = - 4*emis_sel*sb*Ta_sel.^3;
dlambda_o_dTa_TRM_sel = -3./(4*emis_sel*sb*Ta_sel.^4);
dqa_sat_dTa_TRM_sel = 0.622./Psurf_sel.*delTa_sel;
ddelta_dTa_TRM_sel = (15.3*2508.3*237.3-2*2508.3*Ta_c_sel)./(Ta_c_sel+237.3).^4.*exp((17.3*Ta_c_sel)./(Ta_c_sel+237.3))*1000;
df_TRM_dTa_sel = rho_air.*Cp./ra_sel.*(1 + (delTa_sel./gamma_sel).*(ra_sel./(ra_sel + rs_sel))).*dlambda_o_dTa_TRM_sel+ro_sel./gamma_sel./(ra_sel + rs_sel).*ddelta_dTa_TRM_sel;
qa_sat_sel = qsat(Psurf_sel, Ta_sel);
AA_sel = rho_air.*lv.*(qa_sat_sel-qa_sel)./(ra_sel+rs_sel).^2;

dTs_dTa_TRM_sel = lambda_o_sel./(1+f_TRM_sel).*dRn_str_dTa_TRM_sel...
                +(Rn_str_sel-Grnd_sel-AA_sel.*(ra_sel+rs_sel))./(1+f_TRM_sel).*dlambda_o_dTa_TRM_sel...
                -lambda_o_sel.*rho_air.*lv./(ra_sel+rs_sel)./(1+f_TRM_sel).*dqa_sat_dTa_TRM_sel...
                -lambda_o_sel.*(Rn_str_sel-Grnd_sel-AA_sel.*(ra_sel+rs_sel))./(1+f_TRM_sel).^2.*df_TRM_dTa_sel+1;
dTs_dqa_TRM_sel = lambda_o_sel./(1+f_TRM_sel).*rho_air.*lv./(ra_sel+rs_sel);

% sensitivities to albedo and emissivity            
 
dTs_dalpha_TRM_sel = -lambda_o_sel.*swd_sel./(1+f_TRM_sel);
% dTs_demis_TRM_sel = lambda_o_sel.*(lwd_sel - sb*Ta_sel.^4)./(1+f_TRM_sel);
dTs_demis_TRM_sel = lambda_o_sel.*(lwd_sel - sb*Ta_sel.^4 - (Rn_str_sel-Grnd_sel-AA_sel.*(ra_sel+rs_sel))./emis_sel)./(1+f_TRM_sel); %% updated

% sensitivities to aerodynamic and surface resistances 

df_TRM_dra_sel = -(ro_sel./(ra_sel.^2)).*(1+((delTa_sel./gamma_sel).*(ra_sel./(ra_sel+rs_sel)).^2));
df_TRM_drs_sel = -(delTa_sel./gamma_sel).*(ro_sel./(ra_sel+rs_sel).^2);

dTs_dra_TRM_sel = lambda_o_sel.*AA_sel./(1+f_TRM_sel) - df_TRM_dra_sel.*lambda_o_sel.*(Rn_str_sel-Grnd_sel-AA_sel.*(ra_sel+rs_sel))./(1+f_TRM_sel).^2;
dTs_drs_TRM_sel = lambda_o_sel.*AA_sel./(1+f_TRM_sel) - df_TRM_drs_sel.*lambda_o_sel.*(Rn_str_sel-Grnd_sel-AA_sel.*(ra_sel+rs_sel))./(1+f_TRM_sel).^2;

% sensitivity to ground heat flux

% dTs_dRn_TRM_sel = lambda_o_sel./(1+f_TRM_sel);
dTs_dGrnd_TRM_sel = -lambda_o_sel./(1+f_TRM_sel);


% sensitivity of surface saturated specific humidity to surface temperature
dqa_sat_dTa_sel = 0.622./Psurf_sel.*(2508.3./((Ta_c_sel + 237.3).^2).*exp((17.3.*Ta_c_sel)./(Ta_c_sel+237.3)))*1000;
Ts_modeled_sel = ((Rn_str_sel-Grnd_sel)-rho_air.*lv./(ra_sel+rs_sel).*(qa_sat_sel-qa_sel))./((1./lambda_o_sel)+rho_air.*Cp./ra_sel+rho_air.*lv./(ra_sel+rs_sel).*dqa_sat_dTa_sel)+Ta_sel;
qs_sat_modeled_sel = qsat(Psurf_sel, Ts_modeled_sel); % modeled surface saturated specific humidity
qs_modeled_sel = ra_sel./(ra_sel+rs_sel).*(qs_sat_modeled_sel-qa_sel)+qa_sel; % modeled surface specific humidity

Ts_c_sel  = Ts_modeled_sel-273.15;
dqs_sat_dTs_sel = 0.622./Psurf_sel.*(2508.3./((Ts_c_sel + 237.3).^2).*exp((17.3.*Ts_c_sel)./(Ts_c_sel+237.3)))*1000; % de*/dT in kPa/K -- > Pa/K

% sensitivity of surface specific humidity to albedo
BB = ra_sel./(ra_sel+rs_sel).*dqs_sat_dTs_sel;
dqs_dalpha_TRM_sel = BB.*dTs_dalpha_TRM_sel;

% sensitivity of surface specific humidity to aerodynamic resistance
dqs_dra_TRM_sel = rs_sel./(ra_sel+rs_sel).^2.*(qs_sat_modeled_sel-qa_sel)+BB.*dTs_dra_TRM_sel;

% sensitivity of surface specific humidity to surface resistance
dqs_drs_TRM_sel = -ra_sel./(ra_sel+rs_sel).^2.*(qs_sat_modeled_sel-qa_sel)+BB.*dTs_drs_TRM_sel;

% sensitivity of surface specific humidity to ground heat flux
dqs_dGrnd_TRM_sel = BB.*dTs_dGrnd_TRM_sel;

% to add
dqs_dswd_TRM_sel = zeros(size(dqs_dGrnd_TRM_sel));
dqs_drld_TRM_sel = zeros(size(dqs_dGrnd_TRM_sel));
dqs_dTa_TRM_sel  = zeros(size(dqs_dGrnd_TRM_sel));
dqs_dqa_TRM_sel  = zeros(size(dqs_dGrnd_TRM_sel));
dqs_demis_TRM_sel = zeros(size(dqs_dGrnd_TRM_sel));
