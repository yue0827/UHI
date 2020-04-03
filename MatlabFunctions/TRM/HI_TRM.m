% This is the Two-Resistance Mechanism attribution method for sWBGT

function [Diff_WGT,Diff_Ts,Diff_qs,...
          Rn_str_ref, Grnd_ref,ro_ref,ra_ref,rs_ref,f_TRM_ref,...
          Rn_str_sel, Grnd_sel,ro_sel,ra_sel,rs_sel,f_TRM_sel,...          
          dTs_dswd_TRM_ref,dTs_drld_TRM_ref,dTs_dTa_TRM_ref,dTs_dqa_TRM_ref,dTs_dalpha_TRM_ref,dTs_demis_TRM_ref,dTs_dra_TRM_ref,dTs_drs_TRM_ref,dTs_dGrnd_TRM_ref,...
          dTs_dswd_TRM_sel,dTs_drld_TRM_sel,dTs_dTa_TRM_sel,dTs_dqa_TRM_sel,dTs_dalpha_TRM_sel,dTs_demis_TRM_sel,dTs_dra_TRM_sel,dTs_drs_TRM_sel,dTs_dGrnd_TRM_sel,...
          dqs_dswd_TRM_ref,dqs_drld_TRM_ref,dqs_dTa_TRM_ref,dqs_dqa_TRM_ref,dqs_dalpha_TRM_ref,dqs_demis_TRM_ref,dqs_dra_TRM_ref,dqs_drs_TRM_ref,dqs_dGrnd_TRM_ref,...
          dqs_dswd_TRM_sel,dqs_drld_TRM_sel,dqs_dTa_TRM_sel,dqs_dqa_TRM_sel,dqs_dalpha_TRM_sel,dqs_demis_TRM_sel,dqs_dra_TRM_sel,dqs_drs_TRM_sel,dqs_dGrnd_TRM_sel,...
          dWGT_dswd_TRM_ref,dWGT_drld_TRM_ref,dWGT_dTa_TRM_ref,dWGT_dqa_TRM_ref,dWGT_dalpha_TRM_ref,dWGT_demis_TRM_ref,dWGT_dra_TRM_ref,dWGT_drs_TRM_ref,dWGT_dGrnd_TRM_ref,...
          dWGT_dswd_TRM_sel,dWGT_drld_TRM_sel,dWGT_dTa_TRM_sel,dWGT_dqa_TRM_sel,dWGT_dalpha_TRM_sel,dWGT_demis_TRM_sel,dWGT_dra_TRM_sel,dWGT_drs_TRM_sel,dWGT_dGrnd_TRM_sel]=...          
          HI_TRM(rho_air,Cp,sb,lv,...
              Psurf_ref,swd_ref,lwd_ref,Ta_ref,qa_ref,alpha_ref,emis_ref,Qh_ref,Qle_ref,Ts_ref,qs_ref,...
              Psurf_sel,swd_sel,lwd_sel,Ta_sel,qa_sel,alpha_sel,emis_sel,Qh_sel,Qle_sel,Ts_sel,qs_sel) 
%% calculate surface sWBGT difference
                  
[WGT_ref, WGT_sel,...
    dWGT_dTs_ref, dWGT_dqs_ref, dWGT_dps_ref, ...
    dWGT_dTs_sel, dWGT_dqs_sel, dWGT_dps_sel] ...
    = sWBGT(Psurf_ref,Ts_ref,qs_ref,Psurf_sel,Ts_sel,qs_sel);

Diff_WGT = WGT_sel - WGT_ref;

          
[Diff_Ts,...
          Rn_str_ref, Grnd_ref,ro_ref,ra_ref,rs_ref,f_TRM_ref,...
          Rn_str_sel, Grnd_sel,ro_sel,ra_sel,rs_sel,f_TRM_sel,...          
          dTs_dswd_TRM_ref,dTs_drld_TRM_ref,dTs_dTa_TRM_ref,dTs_dqa_TRM_ref,dTs_dalpha_TRM_ref,dTs_demis_TRM_ref,dTs_dra_TRM_ref,dTs_drs_TRM_ref,dTs_dGrnd_TRM_ref,...
          dTs_dswd_TRM_sel,dTs_drld_TRM_sel,dTs_dTa_TRM_sel,dTs_dqa_TRM_sel,dTs_dalpha_TRM_sel,dTs_demis_TRM_sel,dTs_dra_TRM_sel,dTs_drs_TRM_sel,dTs_dGrnd_TRM_sel,...
Diff_qs, ...
          dqs_dswd_TRM_ref,dqs_drld_TRM_ref,dqs_dTa_TRM_ref,dqs_dqa_TRM_ref,dqs_dalpha_TRM_ref,dqs_demis_TRM_ref,dqs_dra_TRM_ref,dqs_drs_TRM_ref,dqs_dGrnd_TRM_ref,...
          dqs_dswd_TRM_sel,dqs_drld_TRM_sel,dqs_dTa_TRM_sel,dqs_dqa_TRM_sel,dqs_dalpha_TRM_sel,dqs_demis_TRM_sel,dqs_dra_TRM_sel,dqs_drs_TRM_sel,dqs_dGrnd_TRM_sel] ...
          =Q_TRM(rho_air,Cp,sb,lv,...
              Psurf_ref,swd_ref,lwd_ref,Ta_ref,qa_ref,alpha_ref,emis_ref,Qh_ref,Qle_ref,Ts_ref,qs_ref,...
              Psurf_sel,swd_sel,lwd_sel,Ta_sel,qa_sel,alpha_sel,emis_sel,Qh_sel,Qle_sel,Ts_sel,qs_sel);



dWGT_dalpha_TRM_ref = dWGT_dTs_ref.*dTs_dalpha_TRM_ref+dWGT_dqs_ref.*dqs_dalpha_TRM_ref;
dWGT_dra_TRM_ref    = dWGT_dTs_ref.*dTs_dra_TRM_ref+dWGT_dqs_ref.*dqs_dra_TRM_ref;
dWGT_drs_TRM_ref    = dWGT_dTs_ref.*dTs_drs_TRM_ref+dWGT_dqs_ref.*dqs_drs_TRM_ref;
dWGT_dGrnd_TRM_ref  = dWGT_dTs_ref.*dTs_dGrnd_TRM_ref+dWGT_dqs_ref.*dqs_dGrnd_TRM_ref;
dWGT_dswd_TRM_ref   = dWGT_dTs_ref.*dTs_dswd_TRM_ref + dWGT_dqs_ref.*dqs_dswd_TRM_ref;
dWGT_drld_TRM_ref   = dWGT_dTs_ref.*dTs_drld_TRM_ref + dWGT_dqs_ref.*dqs_drld_TRM_ref;
dWGT_dTa_TRM_ref    = dWGT_dTs_ref.*dTs_dTa_TRM_ref + dWGT_dqs_ref.*dqs_dTa_TRM_ref;
dWGT_dqa_TRM_ref    = dWGT_dTs_ref.*dTs_dqa_TRM_ref + dWGT_dqs_ref.*dqs_dqa_TRM_ref;
dWGT_demis_TRM_ref  = dWGT_dTs_ref.*dTs_demis_TRM_ref + dWGT_dqs_ref.*dqs_demis_TRM_ref;


dWGT_dalpha_TRM_sel = dWGT_dTs_sel.*dTs_dalpha_TRM_sel+dWGT_dqs_sel.*dqs_dalpha_TRM_sel;
dWGT_dra_TRM_sel    = dWGT_dTs_sel.*dTs_dra_TRM_sel+dWGT_dqs_sel.*dqs_dra_TRM_sel;
dWGT_drs_TRM_sel    = dWGT_dTs_sel.*dTs_drs_TRM_sel+dWGT_dqs_sel.*dqs_drs_TRM_sel;
dWGT_dGrnd_TRM_sel  = dWGT_dTs_sel.*dTs_dGrnd_TRM_sel+dWGT_dqs_sel.*dqs_dGrnd_TRM_sel;
dWGT_dswd_TRM_sel   = dWGT_dTs_sel.*dTs_dswd_TRM_sel + dWGT_dqs_sel.*dqs_dswd_TRM_sel;
dWGT_drld_TRM_sel   = dWGT_dTs_sel.*dTs_drld_TRM_sel + dWGT_dqs_sel.*dqs_drld_TRM_sel;
dWGT_dTa_TRM_sel    = dWGT_dTs_sel.*dTs_dTa_TRM_sel + dWGT_dqs_sel.*dqs_dTa_TRM_sel;
dWGT_dqa_TRM_sel    = dWGT_dTs_sel.*dTs_dqa_TRM_sel + dWGT_dqs_sel.*dqs_dqa_TRM_sel;
dWGT_demis_TRM_sel  = dWGT_dTs_sel.*dTs_demis_TRM_sel + dWGT_dqs_sel.*dqs_demis_TRM_sel;
