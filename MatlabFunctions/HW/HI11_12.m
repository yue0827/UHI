function [num_events, idx_events, severity, mask_hw, mask_non_hw] = HI11_12(T, T_percentile)
% Identify heatwave events from a time series of Tmax
%
%Input:
%	T:  time series of Tempreature (153-by-1), e.g., mean daily temperature,
%	maximum daily temperature, and minimum daily temperature.
%	T_percentile:  the **th percentile (1-by-153)
%Output:
%  	num_events: number of heat wave events
%  	idx_events: time index of heat event, in the format of [onset day, ending day].
%  	severity: average temperature throughout the heat wave event


N = length(T); % number of days in the whole time series
num_events =0; % number of heat waves
idx_events = []; % indicate the first and the last day of each heatwave
severity = [];
mask_hw  = nan(N,1);
mask_non_hw  = ones(N,1);

condition_1 = false;
day1 = 1;
while (day1 <= N)
    
    % T is higher than T_percentile through out the event (at least 3 days)
    if T(day1)>T_percentile(day1)
        for day2 = day1+1:N-1
            if T(day2)<=T_percentile(day2)
                day2  = day2 - 1;
                break;
            end
        end
        if (day2 - day1 + 1) >= 3
            condition_1 = true;
        end
    end
%     if ~condition_1
%         day1 = day1 + 1;
%         continue;
%     end
    
    
    if condition_1
        num_events = num_events + 1;
        idx_events = cat(1, idx_events, [day1 day2]);
        severity = cat(1, severity, [nanmean(T(day1:day2))]);
        mask_hw(day1:1:day2,1) = 1;
        mask_non_hw(day1:1:day2) = nan;         
        % to look for the next one after the end day of this heat wave
        day1 = day2 + 1;
        condition_1 = false;

    else
        day1 = day1 + 1; % to look for the next one after this day
    end
    
end