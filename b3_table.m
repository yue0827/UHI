%%
a1 = cell2mat(Diff_Ts_all_mean);
a2 = cell2mat(Ts_sum_TRM_all_mean);
a3 = cell2mat(Ts_term_alpha_TRM_all_mean);
a4 = cell2mat(Ts_term_ra_TRM_all_mean);
a5 = cell2mat(Ts_term_rs_TRM_all_mean);
a6 = cell2mat(Ts_term_Grnd_TRM_all_mean);

tbl2 = [a1(2,:)',a2(2,:)',a3(2,:)',a4(2,:)',a5(2,:)',a6(2,:)'] ;
open('tbl2')