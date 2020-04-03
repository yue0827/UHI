function [stat_hw_output,mask_hw_output,mask_non_hw_output]=HW_driver(t_var,t_var_max,t_var_min,...
    yrNum_Analysis,daysPerYr,yr_used_for_prctile_start,yr_used_for_prctile_end,method)

[nrow, ncol , N] = size(t_var);       % N is number of days in the whole time series
stationsDimLen     = nrow*ncol;

t_var_2D           = squeeze(reshape(t_var,nrow*ncol,1,N))';
t_var_max_2D       = squeeze(reshape(t_var_max,nrow*ncol,1,N))';
t_var_min_2D       = squeeze(reshape(t_var_min,nrow*ncol,1,N))';


if yrNum_Analysis*daysPerYr ~= N
    disp('not good')
end

T1         = nan(stationsDimLen,1);
T2         = nan(stationsDimLen,1);


if method == 1
    
        Threshold  = 90;
        t_var_selected = t_var_2D;
        
        for iStation = 1:stationsDimLen

        T1(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold);
        
        end
                
end


if method == 2
    
        Threshold  = 95;
        t_var_selected = t_var_2D;

        for iStation = 1:stationsDimLen

        T1(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold);
        
        end
                
end


if method == 3
    
        Threshold  = 98;
        t_var_selected = t_var_2D;

        for iStation = 1:stationsDimLen

        T1(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold);
        
        end
                
end

if method == 4
    
        Threshold  = 99;
        t_var_selected = t_var_2D;

        for iStation = 1:stationsDimLen

        T1(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold);
        
        end
                
end


if method == 5
    
        Threshold  = 95;
        t_var_selected = t_var_max_2D;

        for iStation = 1:stationsDimLen

        T1(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold);
        
        end
                
end


if method == 6
    
        Threshold  = 95;
        t_var_selected = t_var_min_2D;

        for iStation = 1:stationsDimLen

        T1(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold);
        
        end
                
end


if method == 7
    
        Threshold1  = 97.5;
        Threshold2  = 81;
        t_var_selected = t_var_max_2D;
        
        for iStation = 1:stationsDimLen
            
        T1(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold1);
        T2(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold2);
        
        end
                
end

if method == 8
    
        Threshold1  = 97.5;
        Threshold2  = 81;
        t_var_selected = t_var_min_2D;
        
        for iStation = 1:stationsDimLen
            
        T1(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold1);
        T2(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold2);
        
        end
                
end


if method == 9
    
        Threshold1  = 90;
        Threshold2  = 75;
        t_var_selected = t_var_max_2D;
        
        for iStation = 1:stationsDimLen
            
        T1(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold1);
        T2(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold2);
        
        end
                
end

if method == 10
    
        Threshold1  = 90;
        Threshold2  = 75;
        t_var_selected = t_var_min_2D;
        
        for iStation = 1:stationsDimLen
            
        T1(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold1);
        T2(iStation,1) = prctile(t_var_selected((daysPerYr*(yr_used_for_prctile_start-1)+1):(daysPerYr*yr_used_for_prctile_end),iStation), Threshold2);
        
        end
                
end


if method == 11
    
        Threshold  = 95;
        t_var_selected = t_var_max_2D;
        
        for iStation = 1:stationsDimLen
            
%             disp(iStation)
            ss = 0;
            
            for iYrInd = yr_used_for_prctile_start:yr_used_for_prctile_end % choose the threshold based on the data in first 30 years
                
                T_Selected(1:daysPerYr, iYrInd) = t_var_selected(ss+1:ss+daysPerYr, iStation);
                ss = ss + daysPerYr;
                
            end
            for iday = 1:daysPerYr
                
                if iday-7 < 1
                        T_used = T_Selected(1:iday+7, :);
                else if iday+7 > daysPerYr
                        T_used = T_Selected(iday-7:daysPerYr, :);
                    else
                        T_used = T_Selected(iday-7:iday+7, :);
                    end
                end
                
                [nrow_temp,ncol_temp]=size(T_used);
                T_used_temp = reshape(T_used,1,nrow_temp*ncol_temp);
                
                if nansum(~isnan(T_used_temp))>0 
            
                T1(iStation,iday) = prctile(T_used_temp, Threshold);
                 
                end
            end
        end
                         
end


if method == 12
    
        Threshold  = 95;
        t_var_selected = t_var_min_2D;
        
        for iStation = 1:stationsDimLen
            
%             disp(iStation)
            ss = 0;
            
            for iYrInd = yr_used_for_prctile_start:yr_used_for_prctile_end % choose the threshold based on the data in first 30 years
                
                T_Selected(1:daysPerYr, iYrInd) = t_var_selected(ss+1:ss+daysPerYr, iStation);
                ss = ss + daysPerYr;
                
            end
            for iday = 1:daysPerYr
                
                if iday-7 < 1
                        T_used = T_Selected(1:iday+7, :);
                else if iday+7 > daysPerYr
                        T_used = T_Selected(iday-7:daysPerYr, :);
                    else
                        T_used = T_Selected(iday-7:iday+7, :);
                    end
                end
                
                [nrow_temp,ncol_temp]=size(T_used);
                T_used_temp = reshape(T_used,1,nrow_temp*ncol_temp);
                
                if nansum(~isnan(T_used_temp))>0 
            
                T1(iStation,iday) = prctile(T_used_temp, Threshold);
                 
                end
            end
        end
                      
                        
end


        [stat_hw_output,mask_hw_output,mask_non_hw_output]=HW(t_var_selected,nrow,ncol,stationsDimLen, yrNum_Analysis, daysPerYr,T1,T2,method);

        
end

