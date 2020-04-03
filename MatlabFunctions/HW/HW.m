function [stat_hw_01_output,mask_hw_01_output,mask_non_hw_01_output]=HW(Tem_mean, nrow,ncol,stationsDimLen,yrNum_Analysis, daysPerYr,T1,T2,method)

N = yrNum_Analysis*daysPerYr;
stat_hw_01                 = nan(yrNum_Analysis, 10, stationsDimLen);
mask_hw_temp               = nan(N,stationsDimLen);
mask_non_hw_temp           = nan(N,stationsDimLen);

stat_hw_01_output          = nan(nrow, ncol, yrNum_Analysis, 10);
mask_hw_01_output          = nan(nrow, ncol, N);
mask_non_hw_01_output      = nan(nrow, ncol, N);

%1:Year; 2:Average Temperature;
%3:HWN: yearly number of events (Event); 4:HWF: yearly sum of participating HW days (Day)
%5:HWD: length of the longest yearly event (Day); 6:HWL: average length of all yearly events (Day)
%7:HWA: hottest day of hottest yearly event (C); 8:HWM: average magnitude of all yearly events (C)
%9:HWO: Onset date of the first event of the year (Day); 10:HWE: End date of the last event of the year (Day)

for iStation = 1:stationsDimLen
    
    ss = 0;
    
    for iYrInd = 1:yrNum_Analysis
        
        T_Selected = Tem_mean(ss+1:ss+daysPerYr, iStation);
        
        if method == 1 || method == 2 || method == 3 || method == 4 || method == 5 || method == 6
        
        [num_events, idx_events, severity, mask_hw, mask_non_hw] = HI01_06(T_Selected, T1(iStation,1));
            
        else if method == 7 || method == 8 || method == 9 || method == 10
                
        [num_events, idx_events, severity, mask_hw, mask_non_hw] = HI07_10(T_Selected, T1(iStation,1), T2(iStation,1));
                
            else if method == 11 || method == 12
            
        [num_events, idx_events, severity, mask_hw, mask_non_hw] = HI11_12(T_Selected, T1(iStation,:));
        
                end
            end
        end
        
        mask_hw_temp (ss+1:ss+daysPerYr,iStation)=mask_hw;
        mask_non_hw_temp (ss+1:ss+daysPerYr,iStation)=mask_non_hw;
        
        stat_hw_01(iYrInd, 1, iStation) = iYrInd;
        
        stat_hw_01(iYrInd, 2, iStation) = nanmean(T_Selected);
        
        % 3 HWN: yearly number of events
        stat_hw_01(iYrInd, 3, iStation) = num_events;
        
        if num_events == 0
            ss = ss + daysPerYr;
            continue;
        end
        
        % 4 HWF: yearly sum of participating HW days (Day)
        stat_hw_01(iYrInd, 4, iStation) = sum(idx_events(:, 2) - idx_events(:, 1) + 1);
        
        % 5 HWD: length of the longest yearly event (Day)
        stat_hw_01(iYrInd, 5, iStation) = max(idx_events(:, 2) - idx_events(:, 1) + 1);
        
        % 6 HWL: average length of all yearly events (Day)
        stat_hw_01(iYrInd, 6, iStation) = nanmean(idx_events(:, 2) - idx_events(:, 1) + 1);
        
        % 7 HWA: hottest day of hottest yearly event (??)
        tmax_max = [];
        for i=1:num_events
            tmax_max = cat(1,tmax_max, nanmax(T_Selected(idx_events(i,1):idx_events(i,2), 1)));
        end
        stat_hw_01(iYrInd, 7, iStation) = max(tmax_max);
        
        % 8 HWM: average magnitude of all yearly events (??)
        stat_hw_01(iYrInd, 8, iStation) = nanmean(severity);
        
        % 9 HWO: Onset date of the first event of the year (Day)
        stat_hw_01(iYrInd, 9, iStation) = max(idx_events(:, 2)) - min(idx_events(:, 1));
        
        % 10 HWE: End date of the last event of the year (Day)
        stat_hw_01(iYrInd, 10, iStation) = max(idx_events(:, 2));
        
        ss = ss + daysPerYr;
    end
end

for iYrInd = 1:1:yrNum_Analysis
    for kk = 1: 10
        stat_hw_01_output(:,:,iYrInd,kk) = reshape(stat_hw_01(iYrInd,kk,:),nrow,ncol);
    end
end

for kk=1:N
    mask_hw_01_output(:,:,kk)=reshape(mask_hw_temp(kk,:),nrow,ncol);
    mask_non_hw_01_output(:,:,kk)=reshape(mask_non_hw_temp(kk,:),nrow,ncol);
end