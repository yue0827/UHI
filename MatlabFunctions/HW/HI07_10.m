function [num_events, idx_events, severity, mask_hw, mask_non_hw] = HI07_10(T, T1, T2)
% Identify heatwave events from a time series of Tmax
%
%Input:
%	Tmax:  time series of Tmax (N-by-1)
%	T1:  the high percentile
%	T2:  the low percentile
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
condition_2 = false;
condition_3 = false;

day1 = 1;
while (day1 <= N)    
    %% 1. Tmax is higher than T2 through out the event (at least 3 days)
    if T(day1)>T2
        for day2 = day1+1:N-1
            if T(day2)<=T2
                break;
            end
        end
        if (day2 - day1 + 1) >= 3
            condition_1 = true;
        end
    end
    if ~condition_1
        day1 = day1 + 1;
        continue;
    end
    
    %% 2. Averaged Tmax over the entire the event must exceed T1
    max_duration = max(3, day2-day1);
    duration = 0;
    days = [];
    for i = 3:max_duration
        for day = day1:day2-i+1
            
            tempTmax = T(day:day+i-1)';
            
            if  mean(tempTmax) > T1 & i > duration
                days = [day day+i-1];
                condition_2 = true;
                duration = i;
            end
        end
    end
    if ~condition_2 | isempty(days)
        day1 = day1 + 1;
        continue;
    else
        day1 = days(1);
        day2 = days(2);
    end
    
    %% 3. Tmax must exceed T1 for at least consective THREE days
    for day = day1:day2-2
        if length(find(T(day:day+2) > T1)) >= 3
            condition_3 = true;
            break;
        end
    end
    
    if condition_1 & condition_2 & condition_3
        num_events = num_events + 1;
        idx_events = cat(1, idx_events, [day1 day2]);
        severity = cat(1, severity, [nanmean(T(day1:day2))]);
        mask_hw(day1:1:day2,1) = 1;
        mask_non_hw(day1:1:day2) = nan;        
        % to look for the next one after the end day of this heat wave
        day1 = day2 + 1;
        condition_1 = false;
        condition_2 = false;
        condition_3 = false;
    else
        day1 = day1 + 1; % to look for the next one after this day
    end
end

