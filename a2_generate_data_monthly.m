clear all
close all
clc

data_path = './Generate Data/esm2mb-urban-continue-sheffield-8xdaily-20years/';


disp('loading...')
load ([data_path 'time'])
load ([data_path 'lprec'])
load ([data_path 'fprec']) 
load ([data_path 'swdn'])

pre_value = lprec + fprec;



%%

% variable_all = {'t_bot','q_bot','lwdn','swdn','ps',...
%     'flw_urbn','fsw_urbn','grnd_flux_urbn','evap_urbn','sens_urbn','Tca_urbn','qca_urbn','t_ref_urbn','q_ref_urbn',...
%     'flw_rural','fsw_rural','grnd_flux_rural','evap_rural','sens_rural','Tca_rural','qca_rural','t_ref_rural','q_ref_rural'};

variable_all = {'t_ref_urbn','q_ref_urbn',...
    'flw_rural','fsw_rural','grnd_flux_rural','evap_rural','sens_rural','Tca_rural','qca_rural','t_ref_rural','q_ref_rural'};

var_Num = length(variable_all);


for ivar = 1:var_Num

    variable = variable_all{ivar};

    disp(variable)
    
    load ([data_path variable])
    
    eval([variable,'_month = monthly_average(',variable, ', yr_Start, yr_End)']);    
    eval([variable,'_month_daytime = monthly_average_daytime(',variable, ',swdn, yr_Start, yr_End)']);
    eval([variable,'_month_nighttime = monthly_average_nighttime(',variable, ',swdn, yr_Start, yr_End)']);       
    
    
    eval([variable,'_month_clear = monthly_average_pre(',variable, ',pre_value, yr_Start, yr_End)']);   
    eval([variable,'_month_clear_daytime = monthly_average_daytime_pre(',variable, ',swdn, pre_value, yr_Start, yr_End)']);
    eval([variable,'_month_clear_nighttime = monthly_average_nighttime_pre(',variable, ',swdn, pre_value, yr_Start, yr_End)']);    

    save([data_path [variable '_month.mat']], strcat(variable,'_month'))  
    save([data_path [variable '_month_daytime.mat']], strcat(variable,'_month_daytime'))
    save([data_path [variable '_month_nighttime.mat']], strcat(variable,'_month_nighttime'))    
    
    save([data_path [variable '_month_clear.mat']], strcat(variable,'_month_clear'))
    save([data_path [variable '_month_clear_daytime.mat']], strcat(variable,'_month_clear_daytime'))
    save([data_path [variable '_month_clear_nighttime.mat']], strcat(variable,'_month_clear_nighttime'))
    
    
    
end

disp('Completed!')

%%

function [data_monthly] = monthly_average(data_calculate, yr_Start, yr_End)

[nrows,ncols,N]=size(data_calculate);

for iday = 1:N/8
    
    data_calculate_selected = data_calculate(:, :, (iday-1)*8+1:iday*8);
    data_daily(:, :, iday) = nanmean(data_calculate_selected,3);
        
end

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
        data_monthly(:, :, Index_month) = nanmean(data_daily_selected(:, :, average_day),3);
    end
    
    Index_day = Index_day + daysPerYr;
end

end        

%%
function [data_monthly] = monthly_average_pre(data_daily, prec_daily, yr_Start, yr_End)


pre_mask = nan(size(prec_daily));
    
pre_mask(prec_daily > 0) = NaN;
pre_mask(prec_daily == 0) = 1;

data_daily = data_daily.*pre_mask;

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
        data_monthly(:, :, Index_month) = nanmean(data_daily_selected(:, :, average_day),3);
    end
    
    Index_day = Index_day + daysPerYr;
end

end

%% 
function [data_monthly] = monthly_average_daytime(data_calculate, data_ref_swdn, yr_Start, yr_End)

[nrows,ncols,N]=size(data_ref_swdn);


for iday = 1:N/8
    
    data_ref_swdn_selected = data_ref_swdn(:, :, (iday-1)*8+1:iday*8);
%     data_ref_pre_selected = data_ref_pre(:, :, (iday-1)*8+1:iday*8);
    data_calculate_selected = data_calculate(:, :, (iday-1)*8+1:iday*8);
    
    time_mask = ones(nrows,ncols,8);
    time_mask(data_ref_swdn_selected<25) = NaN;
    data_daily(:, :, iday) = nanmean(data_calculate_selected.*time_mask,3);
    
%     pre_sum = nansum(data_ref_pre_selected,3);
%     pre_sum(pre_sum > 0) = NaN;
%     pre_sum(pre_sum == 0) = 1;
%     pre_mask(:, :, iday) = pre_sum;
    
end

data_daily = data_daily;


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
        data_monthly(:, :, Index_month) = nanmean(data_daily_selected(:, :, average_day),3);
    end
    
    Index_day = Index_day + daysPerYr;
end

end

%%

function [data_monthly] = monthly_average_daytime_pre(data_calculate, data_ref_swdn, data_ref_pre, yr_Start, yr_End)

[nrows,ncols,N]=size(data_ref_swdn);


for iday = 1:N/8
    
    data_ref_swdn_selected = data_ref_swdn(:, :, (iday-1)*8+1:iday*8);
    data_ref_pre_selected = data_ref_pre(:, :, (iday-1)*8+1:iday*8);
    data_calculate_selected = data_calculate(:, :, (iday-1)*8+1:iday*8);
    
    time_mask = ones(nrows,ncols,8);
    time_mask(data_ref_swdn_selected<25) = NaN;
    data_daily(:, :, iday) = nanmean(data_calculate_selected.*time_mask,3);
    
    pre_sum = nansum(data_ref_pre_selected,3);
    pre_sum(pre_sum > 0) = NaN;
    pre_sum(pre_sum == 0) = 1;
    pre_mask(:, :, iday) = pre_sum;
    
end

data_daily = data_daily.*pre_mask;


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
        data_monthly(:, :, Index_month) = nanmean(data_daily_selected(:, :, average_day),3);
    end
    
    Index_day = Index_day + daysPerYr;
end

end
%%

function [data_monthly] = monthly_average_nighttime(data_calculate, data_ref_swdn, yr_Start, yr_End)

[nrows,ncols,N]=size(data_ref_swdn);

for iday = 1:N/8
    
    data_ref_swdn_selected = data_ref_swdn(:, :, (iday-1)*8+1:iday*8);
%     data_ref_pre_selected = data_ref_pre(:, :, (iday-1)*8+1:iday*8);
    data_calculate_selected = data_calculate(:, :, (iday-1)*8+1:iday*8);
    
    time_mask = ones(nrows,ncols,8);
    time_mask(data_ref_swdn_selected>=25) = NaN;
    data_daily(:, :, iday) = nanmean(data_calculate_selected.*time_mask,3);
    
%     pre_sum = nansum(data_ref_pre_selected,3);
%     pre_sum(pre_sum > 0) = NaN;
%     pre_sum(pre_sum == 0) = 1;
%     pre_mask(:, :, iday) = pre_sum;
    
end

data_daily = data_daily;

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
        data_monthly(:, :, Index_month) = nanmean(data_daily_selected(:, :, average_day),3);
    end
    
    Index_day = Index_day + daysPerYr;
end
       
end        

%%

function [data_monthly] = monthly_average_nighttime_pre(data_calculate, data_ref_swdn, data_ref_pre, yr_Start, yr_End)

[nrows,ncols,N]=size(data_ref_swdn);

for iday = 1:N/8
    
    data_ref_swdn_selected = data_ref_swdn(:, :, (iday-1)*8+1:iday*8);
    data_ref_pre_selected = data_ref_pre(:, :, (iday-1)*8+1:iday*8);
    data_calculate_selected = data_calculate(:, :, (iday-1)*8+1:iday*8);
    
    time_mask = ones(nrows,ncols,8);
    time_mask(data_ref_swdn_selected>=25) = NaN;
    data_daily(:, :, iday) = nanmean(data_calculate_selected.*time_mask,3);
    
    pre_sum = nansum(data_ref_pre_selected,3);
    pre_sum(pre_sum > 0) = NaN;
    pre_sum(pre_sum == 0) = 1;
    pre_mask(:, :, iday) = pre_sum;
    
end

data_daily = data_daily.*pre_mask;

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
        data_monthly(:, :, Index_month) = nanmean(data_daily_selected(:, :, average_day),3);
    end
    
    Index_day = Index_day + daysPerYr;
end
       
end
        
