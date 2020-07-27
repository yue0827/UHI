close all
clear all
clc;
%%
do_global_regional_attribution = 1;
do_global_pattern = 1;
figure_path = '/Users/yueqin/Documents/UHI_atrribution/UHIfigure/';
%% load common variables
addpath('./MatlabFunctions')
addpath('./MatlabFunctions/TRM')
addpath('./MatlabFunctions/HW')
data_path = './Generate Data/esm2mb-urban-continue-sheffield-8xdaily-20years/';
load([data_path 'all_Ts_rural_urbn_clear_daytime'])
load([data_path 'all_T2_rural_urbn_clear_daytime'])
load([data_path 'time'])
load([data_path 'lon_lat'])
load([data_path 'urban_frac'])

%% create mask_urban
[nrow, ncol , N] = size(Diff_Ts); % N is number of months in the whole time series

mask_urban_temp = nan(size(urban_frac));
mask_urban_temp(urban_frac>0.001) = 1;
mask_urban = repmat(mask_urban_temp, 1, 1, N);

%% urban rural contrast in all terms
% added on June 25

Diff_alpha = alpha_sel - alpha_ref;
Diff_ra    = ra_sel - ra_ref;
Diff_rs    = rs_sel - rs_ref;
Diff_Grnd  = Grnd_sel - Grnd_ref;

Diff_ra_prime    = ra_prime_sel - ra_prime_ref;
Diff_Rn_str = Rn_str_sel - Rn_str_ref;
Diff_Qh    = Qh_sel - Qh_ref;
Diff_Qle   = Qle_sel - Qle_ref;

%%
dT_ref = Ts_ref - Ta_ref;
dT_sel = Ts_sel - Ta_sel;
diff_dT = dT_sel - dT_ref;
%%
average_period_value = 2;
Values_input = diff_dT;
value_limit = 6;
plot_map(Values_input, mask_urban, average_period_value, value_limit, yr_Num)
% save
filename = 'figure_daytime_summer_diff_dT';
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'points');
set(gcf, 'PaperPosition', [100, 100, 650, 310]);
print('-djpeg', '-r600', [figure_path filename])
        

%% plot
if do_global_pattern == 1  
    variable_all = {'Diff_alpha','Diff_ra','Diff_rs','Diff_Grnd','Diff_ra_prime','Diff_Rn_str','Diff_Qh','Diff_Qle'};
    var_Num = length(variable_all);
    %% summer
    average_period_value = 2;
    
    for ivar = 1:var_Num
        if ivar==1 
            value_limit = 0.15; % day-0.15 night-0.15
        elseif ivar == 2 
            value_limit = 200; % 200 200
        elseif ivar == 3
            value_limit = 8000; % 8000 8000
        elseif ivar ==4
            value_limit = 150; % 150 150
        elseif ivar == 5
            value_limit = 150; % 50 150
        elseif ivar == 6 
            value_limit = 0.5; % 50 0.5
        elseif ivar == 7
            value_limit = 100; % 100 100
        else
            value_limit = 25; % 150 25
        end
            
        variable = variable_all{ivar};
        Values_input = eval(variable);
        plot_map(Values_input, mask_urban, average_period_value, value_limit, yr_Num)
        % save
        filename = ['figure_daytime_summer_' variable];
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'points');
        set(gcf, 'PaperPosition', [100, 100, 650, 310]);
        print('-djpeg', '-r600', [figure_path filename])
        
        x_limit = [-1 1]*value_limit;
        plot_latitudinal_dependence(Values_input, mask_urban, average_period_value, lat, x_limit, yr_Num)
        filename = ['figure_latitudinal_dependence_daytime_summer_' variable];
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'points');
        set(gcf, 'PaperPosition', [100, 1000, 200, 310]);
        print('-djpeg', '-r600', [figure_path filename])
        
        close all
    end
    
    % figure combination
    figure_combined = [];
    for i = [1 3 5 7]
        
        a1 = imread([figure_path 'figure_daytime_summer_' variable_all{i} '.jpg']);
        b1 = imread([figure_path 'figure_latitudinal_dependence_daytime_summer_' variable_all{i} '.jpg']);
        c1 = [a1 b1];
        
        a2 = imread([figure_path 'figure_daytime_summer_' variable_all{i+1} '.jpg']);
        b2 = imread([figure_path 'figure_latitudinal_dependence_daytime_summer_' variable_all{i+1} '.jpg']);
        c2 = [a2 b2];
        
        c = [c1, c2];
        %             imshow(c)
        %             print('-djpeg', '-r600', [figure_path 'figure_combined_clear_daytime_summer_all' num2str(i) '.jpg'])
        
        figure_combined = cat(1, figure_combined, c);
        
    end
    imshow(figure_combined)
    print('-djpeg', '-r600', [figure_path 'figure_dif_clear_daytime_summer_all.jpg'])
        
    %% winter 
    average_period_value = 3;
     
    for ivar = 1:var_Num
        if ivar==1 
            value_limit = 0.4; % 0.4 0.4
        elseif ivar == 2 
            value_limit = 400; % 300 400
        elseif ivar == 3
            value_limit = 8000; % 8000 8000
        elseif ivar ==4
            value_limit = 200; % 160 200
        elseif ivar == 5
            value_limit = 300; % 200 300
        elseif ivar == 6 
            value_limit = 0.5; % 50 0.5
        elseif ivar == 7
            value_limit = 150; % 150 150
        else 
            value_limit = 25; % 150 25
        end
            
        variable = variable_all{ivar};
        Values_input = eval(variable);
        plot_map(Values_input, mask_urban, average_period_value, value_limit, yr_Num)
        % save
        filename = ['figure_daytime_winter_' variable];
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'points');
        set(gcf, 'PaperPosition', [100, 100, 650, 310]);
        print('-djpeg', '-r600', [figure_path filename])
        
        x_limit = [-1 1]*value_limit;
        plot_latitudinal_dependence(Values_input, mask_urban, average_period_value, lat, x_limit, yr_Num)
        filename = ['figure_latitudinal_dependence_daytime_winter_' variable];
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'points');
        set(gcf, 'PaperPosition', [100, 1000, 200, 310]);
        print('-djpeg', '-r600', [figure_path filename])
        
        close all
    end
    
    % figure combination
    figure_combined = [];
    for i = [1 3 5 7]
        
        a1 = imread([figure_path 'figure_daytime_winter_' variable_all{i} '.jpg']);
        b1 = imread([figure_path 'figure_latitudinal_dependence_daytime_winter_' variable_all{i} '.jpg']);
        c1 = [a1 b1];
        
        a2 = imread([figure_path 'figure_daytime_winter_' variable_all{i+1} '.jpg']);
        b2 = imread([figure_path 'figure_latitudinal_dependence_daytime_winter_' variable_all{i+1} '.jpg']);
        c2 = [a2 b2];
        
        c = [c1, c2];
        %             imshow(c)
        %             print('-djpeg', '-r600', [figure_path 'figure_combined_clear_daytime_winter_all' num2str(i) '.jpg'])
        
        figure_combined = cat(1, figure_combined, c);
        
    end
    imshow(figure_combined)
    print('-djpeg', '-r600', [figure_path 'figure_dif_clear_daytime_winter_all.jpg']) 
    
end