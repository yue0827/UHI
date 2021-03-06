% This is the driver layer of the TRM model, which includes 3 main components: 
% 1, the TRM attribution itself (see Rigden and Li, 2017, Liao et al. 2018, Li et al. 2019, Wang et al. 2019), 
% 2, the optimization of m described in Liao et al. (2018 JGR-biogeosciences), 
% 3, the final calculation with the optimized m.  
%
% Currently the code is set up to read in inputs as two-dimensional arrays 
% in space (row) and time (column). 
%
% At a given space (i.e., for a given row), the m_optimize routine currently 
% uses all data in the time domain and at the temporal resolution provided 
% by the inputs to optimize m. This could be changed.  


function [Diff_Ts,mask,m_TRM_sel_opt,...
          Rn_str_ref, Grnd_ref,ro_ref,ra_ref,rs_ref,f_TRM_ref,...
          Rn_str_sel, Grnd_sel,ro_sel,ra_sel,rs_sel,f_TRM_sel,...  
          dTs_dswd_TRM_ref,dTs_drld_TRM_ref,dTs_dTa_TRM_ref,dTs_dqa_TRM_ref,dTs_dalpha_TRM_ref,dTs_demis_TRM_ref,dTs_dra_TRM_ref,dTs_drs_TRM_ref,dTs_dGrnd_TRM_ref,...
          dTs_dswd_TRM_sel,dTs_drld_TRM_sel,dTs_dTa_TRM_sel,dTs_dqa_TRM_sel,dTs_dalpha_TRM_sel,dTs_demis_TRM_sel,dTs_dra_TRM_sel,dTs_drs_TRM_sel,dTs_dGrnd_TRM_sel,...          
          dTs_dswd_TRM,dTs_drld_TRM,dTs_dTa_TRM,dTs_dqa_TRM,dTs_dalpha_TRM,dTs_demis_TRM,dTs_dra_TRM,dTs_drs_TRM,dTs_dGrnd_TRM,...
          Ts_term_swd_TRM,Ts_term_rld_TRM,Ts_term_Ta_TRM,Ts_term_qa_TRM,Ts_term_alpha_TRM,Ts_term_emis_TRM,Ts_term_ra_TRM,Ts_term_rs_TRM,Ts_term_Grnd_TRM,...
          Ts_sum_TRM]=TRM_driver(...
              rho_air,... % air density (kg/m3)
              Cp,...      % heat capacity of dry air (J/kg/K)
              sb,...      % stephan-boltzman constant (W/(m^2 K^4))
              lv,...      % latent heat of vaporization (J/kg)
              limit,...   % the limit of sensible and latent heat fluxes for creating masks
              do_optimize,...  % do optimization for m or not
              use_previously_optimized_m,... % have you already done optimization for m or not
              data_path,...
              Psurf_ref,swd_ref,lwd_ref,Ta_ref,qa_ref,alpha_ref,emis_ref,Qh_ref,Qle_ref,Ts_ref,...  % inputs over the reference patch
              Psurf_sel,swd_sel,lwd_sel,Ta_sel,qa_sel,alpha_sel,emis_sel,Qh_sel,Qle_sel,Ts_sel)     % inputs over the perturbed patch


%% TRM calculations

          [Diff_Ts,...
          Rn_str_ref, Grnd_ref,ro_ref,ra_ref,rs_ref,f_TRM_ref,...
          Rn_str_sel, Grnd_sel,ro_sel,ra_sel,rs_sel,f_TRM_sel,...          
          dTs_dswd_TRM_ref,dTs_drld_TRM_ref,dTs_dTa_TRM_ref,dTs_dqa_TRM_ref,dTs_dalpha_TRM_ref,dTs_demis_TRM_ref,dTs_dra_TRM_ref,dTs_drs_TRM_ref,dTs_dGrnd_TRM_ref,...
          dTs_dswd_TRM_sel,dTs_drld_TRM_sel,dTs_dTa_TRM_sel,dTs_dqa_TRM_sel,dTs_dalpha_TRM_sel,dTs_demis_TRM_sel,dTs_dra_TRM_sel,dTs_drs_TRM_sel,dTs_dGrnd_TRM_sel]=...
          TRM(rho_air,Cp,sb,lv,...
              Psurf_ref,swd_ref,lwd_ref,Ta_ref,qa_ref,alpha_ref,emis_ref,Qh_ref,Qle_ref,Ts_ref,...
              Psurf_sel,swd_sel,lwd_sel,Ta_sel,qa_sel,alpha_sel,emis_sel,Qh_sel,Qle_sel,Ts_sel);

        
%% criteria of selecting data

mask = create_mask(ra_ref,ra_sel,rs_ref,rs_sel,Qh_ref,Qh_sel,Qle_ref,Qle_sel,limit);

%% optimize m

if (use_previously_optimized_m == 1)
  
    if isfile('m_TRM_sel_opt.mat')
        load([data_path 'm_TRM_sel_opt.mat'])
    else
        disp(['no m_TRM_sel_opt.mat exits, please change use_previously_optimized_m to 0'])
    end
 
else
    
    if (do_optimize == 1)
        
        m_TRM_sel_opt=m_optimize(Diff_Ts,mask,...
            dTs_dswd_TRM_ref,dTs_drld_TRM_ref,dTs_dTa_TRM_ref,dTs_dqa_TRM_ref,dTs_dalpha_TRM_ref,dTs_demis_TRM_ref,dTs_dra_TRM_ref,dTs_drs_TRM_ref,dTs_dGrnd_TRM_ref,...
            dTs_dswd_TRM_sel,dTs_drld_TRM_sel,dTs_dTa_TRM_sel,dTs_dqa_TRM_sel,dTs_dalpha_TRM_sel,dTs_demis_TRM_sel,dTs_dra_TRM_sel,dTs_drs_TRM_sel,dTs_dGrnd_TRM_sel,...
            swd_ref,lwd_ref,Ta_ref,qa_ref,alpha_ref,emis_ref,ra_ref,rs_ref,Grnd_ref,...
            swd_sel,lwd_sel,Ta_sel,qa_sel,alpha_sel,emis_sel,ra_sel,rs_sel,Grnd_sel);
        
        % m_TRM_sel_opt_test=m_optimize_test(Diff_Ts,mask,...
        %                      dTs_dswd_TRM_ref,dTs_drld_TRM_ref,dTs_dTa_TRM_ref,dTs_dqa_TRM_ref,dTs_dalpha_TRM_ref,dTs_demis_TRM_ref,dTs_dra_TRM_ref,dTs_drs_TRM_ref,dTs_dGrnd_TRM_ref,...
        %                      dTs_dswd_TRM_sel,dTs_drld_TRM_sel,dTs_dTa_TRM_sel,dTs_dqa_TRM_sel,dTs_dalpha_TRM_sel,dTs_demis_TRM_sel,dTs_dra_TRM_sel,dTs_drs_TRM_sel,dTs_dGrnd_TRM_sel,...
        %                      swd_ref,lwd_ref,Ta_ref,qa_ref,alpha_ref,emis_ref,ra_ref,rs_ref,Grnd_ref,...
        %                      swd_sel,lwd_sel,Ta_sel,qa_sel,alpha_sel,emis_sel,ra_sel,rs_sel,Grnd_sel);
        
        save ([data_path 'm_TRM_sel_opt'], 'm_TRM_sel_opt')
        
    else if (do_optimize == 0)
            
            m_TRM_sel_opt= zeros(length(Diff_Ts(:,1)),1) + 1;
            
            save ([data_path 'm_TRM_sel_opt'], 'm_TRM_sel_opt')
            
        end
        
    end

end


%% calculate the weighted average of partial derivatives

[dTs_dswd_TRM,dTs_drld_TRM,dTs_dTa_TRM,dTs_dqa_TRM,dTs_dalpha_TRM,dTs_demis_TRM,dTs_dra_TRM,dTs_drs_TRM,dTs_dGrnd_TRM,...
 Ts_term_swd_TRM,Ts_term_rld_TRM,Ts_term_Ta_TRM,Ts_term_qa_TRM,Ts_term_alpha_TRM,Ts_term_emis_TRM,Ts_term_ra_TRM,Ts_term_rs_TRM,Ts_term_Grnd_TRM,...
 Ts_sum_TRM] = final_calculation(m_TRM_sel_opt,mask,...
                     dTs_dswd_TRM_ref,dTs_drld_TRM_ref,dTs_dTa_TRM_ref,dTs_dqa_TRM_ref,dTs_dalpha_TRM_ref,dTs_demis_TRM_ref,dTs_dra_TRM_ref,dTs_drs_TRM_ref,dTs_dGrnd_TRM_ref,...
                     dTs_dswd_TRM_sel,dTs_drld_TRM_sel,dTs_dTa_TRM_sel,dTs_dqa_TRM_sel,dTs_dalpha_TRM_sel,dTs_demis_TRM_sel,dTs_dra_TRM_sel,dTs_drs_TRM_sel,dTs_dGrnd_TRM_sel,...
                     swd_ref,lwd_ref,Ta_ref,qa_ref,alpha_ref,emis_ref,ra_ref,rs_ref,Grnd_ref,...
                     swd_sel,lwd_sel,Ta_sel,qa_sel,alpha_sel,emis_sel,ra_sel,rs_sel,Grnd_sel);

                