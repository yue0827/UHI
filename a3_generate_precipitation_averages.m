clear all
clc

data_path = './Generate Data/esm2mb-urban-continue-sheffield-8xdaily-20years/';

load([data_path 'time'])
load([data_path 'fprec'])
load([data_path 'lprec'])

pre_value = (lprec + fprec);

[prec_month] = prec_sum(pre_value, yr_Start, yr_End);    
save([data_path 'prec_month.mat'], 'prec_month');



function [data_monthly_sum] = prec_sum(pre_value, yr_Start, yr_End)

[nrow,ncols,N]=size(pre_value);

for iday = 1:N/8
    
    data_calculate_selected = pre_value(:, :, (iday-1)*8+1:iday*8)*3*3600;
    data_daily_sum(:, :, iday) = sum(data_calculate_selected,3);

end

data_daily = data_daily_sum;


Index_day = 0;
Index_month = 0;

for iYr = yr_Start:1:yr_End

    iYrInd = iYr - yr_Start + 1;

    leapyear = rem(iYr,4);    
    if leapyear > 0       		 
        leap = 0;              
    else
        if rem(iYr,100)==0 && rem(iYr,400)~=0
            leap = 0;         
        else
            leap = 1;     
        end
    end

    if leap == 1
        daysPerYr = 366;
        feb = 29;
    else
        daysPerYr = 365;
        feb = 28;
    end

    daysPerMonth = [31 feb 31 30 31 30 31 31 30 31 30 31];
    daysCum = zeros(13,1);
    daysCum(2:13) = cumsum(daysPerMonth);

    data_daily_selected = data_daily(:, :, Index_day+1:Index_day+daysPerYr);
    
    for imonth = 1:12
        Index_month = Index_month + 1;
        average_day = daysCum(imonth)+1:daysCum(imonth+1);
        data_monthly_sum(:, :, Index_month) = sum(data_daily_selected(:, :, average_day),3);
    end
    
    Index_day = Index_day + daysPerYr;
end

end
        