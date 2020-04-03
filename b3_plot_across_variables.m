close all
clear all
clc;

do_global_regional_attribution = 1;
do_global_pattern = 1;
figure_path = './figures/';
%% load common variables

data_path = './Generate Data/esm2mb-urban-continue-sheffield-8xdaily-20years/';
load([data_path 'time']) 
load([data_path 'lon_lat'])
load([data_path 'urban_frac'])

%% load data

id_Ts    = 1;
id_WGT   = 2;
id_T2    = 3;
id_WGT2  = 4;

experiment_names = {'Canopy air temperature (^oC)','Canopy air SWBGT ','Reference temperature (^oC)','Reference SWBGT '};
experiment_Num   = length(experiment_names);

for iexperiment = 1:experiment_Num
    
    if iexperiment == id_Ts
    
load([data_path 'all_Ts_rural_urbn_clear_daytime'])

mask_all{iexperiment}= mask;
Diff_Ts_all{iexperiment}=Diff_Ts;
Ts_sum_TRM_all{iexperiment}=Ts_sum_TRM;
Ts_term_alpha_TRM_all{iexperiment}=Ts_term_alpha_TRM;
Ts_term_ra_TRM_all{iexperiment}=Ts_term_ra_TRM;
Ts_term_rs_TRM_all{iexperiment}=Ts_term_rs_TRM;
Ts_term_Grnd_TRM_all{iexperiment}=Ts_term_Grnd_TRM;

    end
    
    
    if iexperiment == id_T2
    
load([data_path 'all_T2_rural_urbn_clear_daytime'])

mask_all{iexperiment}= mask;
Diff_Ts_all{iexperiment}=Diff_T2;
Ts_sum_TRM_all{iexperiment}=T2_sum_TRM;
Ts_term_alpha_TRM_all{iexperiment}=T2_term_alpha_TRM;
Ts_term_ra_TRM_all{iexperiment}=T2_term_ra_TRM+T2_term_ra_prime_TRM;
Ts_term_rs_TRM_all{iexperiment}=T2_term_rs_TRM;
Ts_term_Grnd_TRM_all{iexperiment}=T2_term_Grnd_TRM;
    end    

    if iexperiment == id_WGT
    
load([data_path 'all_WGT_rural_urbn_clear_daytime'])

mask_all{iexperiment}= mask;
Diff_Ts_all{iexperiment}=Diff_WGT;
Ts_sum_TRM_all{iexperiment}=WGT_sum_TRM;
Ts_term_alpha_TRM_all{iexperiment}=WGT_term_alpha_TRM;
Ts_term_ra_TRM_all{iexperiment}=WGT_term_ra_TRM;
Ts_term_rs_TRM_all{iexperiment}=WGT_term_rs_TRM;
Ts_term_Grnd_TRM_all{iexperiment}=WGT_term_Grnd_TRM;
    end   
    
    if iexperiment == id_WGT2
    
load([data_path 'all_WGT_2m_rural_urbn_clear_daytime'])

mask_all{iexperiment}= mask;
Diff_Ts_all{iexperiment}=Diff_WGT;
Ts_sum_TRM_all{iexperiment}=WGT_sum_TRM;
Ts_term_alpha_TRM_all{iexperiment}=WGT_term_alpha_TRM;
Ts_term_ra_TRM_all{iexperiment}=WGT_term_ra_TRM;
Ts_term_rs_TRM_all{iexperiment}=WGT_term_rs_TRM;
Ts_term_Grnd_TRM_all{iexperiment}=WGT_term_Grnd_TRM;

    end       




end


data_path ='./';

%% create mask_urban
[nrow, ncol , N] = size(Diff_Ts); % N is number of months in the whole time series

mask_urban_temp = nan(size(urban_frac));
mask_urban_temp(urban_frac>0.001) = 1;
mask_urban = repmat(mask_urban_temp, 1, 1, N);

%% create mask_season

%average_period_value = 1 (annual), 2(summer), 3(winter)
average_period_value = 2; % need modify

    
    mask_season = nan(nrow, ncol , N);

    switch average_period_value
        
        case 1
            
            mask_season = 1;
            
        case 2
            
                        
            for i =1: yr_Num
                
                mask_season(:,:,(i-1)*12+6:(i-1)*12+8) = 1;
    
            end
            
        case 3
            
            for i =1: yr_Num
                
                mask_season(:,:,(i-1)*12+1:(i-1)*12+1) = 1;                
                mask_season(:,:,(i-1)*12+11:(i-1)*12+12) = 1;
    
            end            

        otherwise 
            
            disp('average_period_value needs to be 1 or 2 or 3')
        
    end



%% make masks for all experiments 

mask_universal = mask_all{id_Ts}.*mask_all{id_WGT}.*mask_all{id_T2}.*mask_all{id_WGT2};
save('mask_universal_clear_daytime.mat','mask_universal');


%% Global and regional attribution

if do_global_regional_attribution == 1
    
mask_only_urban_season = mask_season.*mask_urban;
mask_to_use = mask_universal.*mask_season.*mask_urban;
   
region_names = {'Global','US','China','Europe'};
region_Num   = length(region_names);

global_index = 1;
US_index     = 2;
China_index  = 3;
EU_index     = 4;

load ./MatlabFunctions/favoritecolor.mat
color(1,:) = [0 0 0]/255;
color(2,:) = red_rgb;
color(3,:) = blue_rgb;
color(4,:) = green_rgb;

% Global
lat_index{global_index} = 1:length(lat);
lon_index{global_index} = 1:length(lon);

% % US
lon_left_EA  = -90+360;
lon_right_EA = -70+360;
lat_low_EA   = 30;
lat_up_EA    = 50;
lat_index{US_index} = find (lat >lat_low_EA  & lat<lat_up_EA);
lon_index{US_index} = find (lon >lon_left_EA & lon<lon_right_EA);    

% % China
lon_left_EC  = 100;
lon_right_EC = 120;
lat_low_EC   = 20;
lat_up_EC    = 40;
lat_index{China_index} = find (lat >lat_low_EC  & lat<lat_up_EC);
lon_index{China_index} = find (lon >lon_left_EC & lon<lon_right_EC);
 
% Europe
lon_left_EC  = 15;
lon_right_EC = 30;
lat_low_EC   = 35;
lat_up_EC    = 55;
lat_index{EU_index} = find (lat >lat_low_EC  & lat<lat_up_EC);
lon_index{EU_index} = find (lon >lon_left_EC & lon<lon_right_EC);

% mask_lat_lon = zeros(size(mask_urban))+NaN;
% mask_lat_lon(lon_index{US_index},lat_index{US_index},:)=1;
% 
% plot_map_daily(mask_lat_lon(:,:,1), 1, 0.1)

%
variable_all = {'Diff_Ts_all','Ts_sum_TRM_all','Ts_term_alpha_TRM_all','Ts_term_ra_TRM_all','Ts_term_rs_TRM_all','Ts_term_Grnd_TRM_all'};
var_Num = length(variable_all);


for iexperiment = 1:experiment_Num

for region_index = 1:region_Num
    
for ivar = 1:var_Num

    variable = variable_all{ivar};

    disp(variable)
    
    clear x_temp1 x_temp2 y_temp nan_value
 
    eval(['[',variable,'_global{region_index,iexperiment},',variable,'_mean{region_index,iexperiment},',strtrim(variable),'_std{region_index,iexperiment}]=temporal_DL(',variable,'{iexperiment}(lon_index{region_index},lat_index{region_index},:).*mask_to_use(lon_index{region_index},lat_index{region_index},:))']);

    if ivar == 1
    eval(['[',variable,'_global_only_urban_season{region_index,iexperiment},',variable,'_mean_only_urban_season{region_index,iexperiment},',strtrim(variable),'_std_only_urban_season{region_index,iexperiment}]=temporal_DL(',variable,'{iexperiment}(lon_index{region_index},lat_index{region_index},:).*mask_only_urban_season(lon_index{region_index},lat_index{region_index},:))']);
    end    
        
end

end

end

%%
FontSize_value = 14;
Fontname_value = 'Arial';
n_row = 3;
n_col = 1;
h = figure;

set(h, 'Position', [100, 100, 1200, 1200]); % [Left Bottom Width Hight]

% [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
%
%   in:  Nh      number of axes in hight (vertical direction)
%        Nw      number of axes in width (horizontaldirection)
%        gap     gaps between the axes in normalized units (0...1)
%                   or [gap_h gap_w] for different gaps in height and width 
%        marg_h  margins in height in normalized units (0...1)
%                   or [lower upper] for different lower and upper margins 
%        marg_w  margins in width in normalized units (0...1)
%                   or [left right] for different left and right margins
ha = tight_subplot(n_row,n_col,[.08 .1],[.15 .05],[.1 .02]);

BarWidth_value = 0.2;
ErrorbarLineWidth_value = 0.3;
ErrorbarRelativeWidth_value = 0.3;

for region_index = 2: region_Num
axes(ha(region_index-1))

for iexperiment = 1:experiment_Num

% superbar(1+0.1125*(iexperiment-2)*2,Diff_Ts_all_mean_only_urban_season{region_index,iexperiment},'E',Diff_Ts_all_std_only_urban_season{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)
% hold on
% box on 

superbar(1+0.1125*(iexperiment-2)*2,Diff_Ts_all_mean{region_index,iexperiment},'E',Diff_Ts_all_std{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)
hold on
box on

superbar(2+0.1125*(iexperiment-2)*2,Ts_sum_TRM_all_mean{region_index,iexperiment},'E',Ts_sum_TRM_all_std{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

superbar(3+0.1125*(iexperiment-2)*2,Ts_term_alpha_TRM_all_mean{region_index,iexperiment},'E',Ts_term_alpha_TRM_all_std{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

superbar(4+0.1125*(iexperiment-2)*2,Ts_term_ra_TRM_all_mean{region_index,iexperiment},'E',Ts_term_ra_TRM_all_std{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

superbar(5+0.1125*(iexperiment-2)*2,Ts_term_rs_TRM_all_mean{region_index,iexperiment},'E',Ts_term_rs_TRM_all_std{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

superbar(6+0.1125*(iexperiment-2)*2,Ts_term_Grnd_TRM_all_mean{region_index,iexperiment},'E',Ts_term_Grnd_TRM_all_std{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

% y_up = 6;
% y_down = -2;
% 
% set(gca,'YLim',[y_down y_up]);
% set(gca, 'YTick',y_down:2:y_up);
% set(gca, 'YTickLabel', {'-2','0','2','4','6'});

y_up = 4;
y_down = -2;

set(gca,'YLim',[y_down y_up]);
set(gca, 'YTick',y_down:1:y_up);
set(gca, 'YTickLabel', {'-2','-1','0','1','2','3','4'});
if region_index == 2
plot(4.5,(y_up-y_down)*(8.2-0.6*(iexperiment-3))/10+y_down,'s','MarkerEdgeColor','none','MarkerFaceColor',color(iexperiment,:),'MarkerSize',14)
text(4.65,(y_up-y_down)*(8.2-0.6*(iexperiment-3))/10+y_down,experiment_names{iexperiment},'fontname',Fontname_value,'FontSize', FontSize_value-1,'Color',color(iexperiment,:))
end
end

xlim([0.5 6.8])
set(gca, 'XTick', 1:6);
set(gca, 'XTickLabel', {'GFDL','TRM','\alpha','r_a','r_s','G'});
ylabel('Urban - Rural', 'fontname',Fontname_value,'FontSize',FontSize_value);
set(gca, 'fontname',Fontname_value,'FontSize',FontSize_value)
title(region_names{region_index})
end

print('-djpeg', '-r600', [figure_path 'figure_attribution_clear_daytime.jpg'])


%% The following is for AGU presentation

FontSize_value = 14;
Fontname_value = 'Arial';
n_row = 1;
n_col = 1;
h = figure;

set(h, 'Position', [100, 100, 600, 400]); % [Left Bottom Width Hight]

% [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
%
%   in:  Nh      number of axes in hight (vertical direction)
%        Nw      number of axes in width (horizontaldirection)
%        gap     gaps between the axes in normalized units (0...1)
%                   or [gap_h gap_w] for different gaps in height and width 
%        marg_h  margins in height in normalized units (0...1)
%                   or [lower upper] for different lower and upper margins 
%        marg_w  margins in width in normalized units (0...1)
%                   or [left right] for different left and right margins
ha = tight_subplot(n_row,n_col,[.08 .1],[.15 .05],[.1 .02]);

BarWidth_value = 0.2;
ErrorbarLineWidth_value = 0.3;
ErrorbarRelativeWidth_value = 0.3;

for region_index = 2: 2
axes(ha(region_index-1))

for iexperiment = 1:experiment_Num

% superbar(1+0.1125*(iexperiment-2)*2,Diff_Ts_all_mean_only_urban_season{region_index,iexperiment},'E',Diff_Ts_all_std_only_urban_season{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)
% hold on
% box on 

superbar(1+0.1125*(iexperiment-2)*2,Diff_Ts_all_mean{region_index,iexperiment},'E',Diff_Ts_all_std{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)
hold on
box on

superbar(2+0.1125*(iexperiment-2)*2,Ts_sum_TRM_all_mean{region_index,iexperiment},'E',Ts_sum_TRM_all_std{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

superbar(3+0.1125*(iexperiment-2)*2,Ts_term_alpha_TRM_all_mean{region_index,iexperiment},'E',Ts_term_alpha_TRM_all_std{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

superbar(4+0.1125*(iexperiment-2)*2,Ts_term_ra_TRM_all_mean{region_index,iexperiment},'E',Ts_term_ra_TRM_all_std{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

superbar(5+0.1125*(iexperiment-2)*2,Ts_term_rs_TRM_all_mean{region_index,iexperiment},'E',Ts_term_rs_TRM_all_std{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

superbar(6+0.1125*(iexperiment-2)*2,Ts_term_Grnd_TRM_all_mean{region_index,iexperiment},'E',Ts_term_Grnd_TRM_all_std{region_index,iexperiment},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(iexperiment,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

% y_up = 6;
% y_down = -2;
% 
% set(gca,'YLim',[y_down y_up]);
% set(gca, 'YTick',y_down:2:y_up);
% set(gca, 'YTickLabel', {'-2','0','2','4','6'});

y_up = 4;
y_down = -2;

set(gca,'YLim',[y_down y_up]);
set(gca, 'YTick',y_down:1:y_up);
set(gca, 'YTickLabel', {'-2','-1','0','1','2','3','4'});
if region_index == 2
plot(2.5,(y_up-y_down)*(8.2-0.6*(iexperiment-3))/10+y_down,'s','MarkerEdgeColor','none','MarkerFaceColor',color(iexperiment,:),'MarkerSize',14)
text(2.65,(y_up-y_down)*(8.2-0.6*(iexperiment-3))/10+y_down,experiment_names{iexperiment},'fontname',Fontname_value,'FontSize', FontSize_value-1,'Color',color(iexperiment,:))
end



xlim([0.5 6.8])
set(gca, 'XTick', 1:6);
set(gca, 'XTickLabel', {'GFDL','TRM','\alpha','r_a','r_s','G'});
ylabel('Urban - Rural', 'fontname',Fontname_value,'FontSize',FontSize_value);
set(gca, 'fontname',Fontname_value,'FontSize',FontSize_value)
title(region_names{region_index})

print('-djpeg', '-r600', [figure_path strcat('figure_attribution_clear_daytime_for_presentation',num2str(iexperiment),'.jpg')])


end

end



end

%% global patterns

if do_global_pattern == 1

average_period_value = 2;

for i = 1:experiment_Num

        Values_input = Diff_Ts_all{i};
    
    if i == 1        
        value_limit  = 6; % need modify        
    elseif i == 2
        value_limit  = 3; % need modify                
    elseif i == 3
        value_limit  = 6; % need modify      
    elseif i == 4
        value_limit  = 3; % need modify  
    end
    
%    plot_map_daily(Values_input, mask_input, value_limit)
     plot_map(Values_input, mask_urban, average_period_value, value_limit, yr_Num)
    
    % save
    filename = ['figure_' num2str(i)];
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points');
    set(gcf, 'PaperPosition', [100, 100, 650, 310]);
    print('-djpeg', '-r600', [figure_path filename])
    
    x_limit = [-1 1]*value_limit;
    
    plot_latitudinal_dependence(Values_input, mask_urban, average_period_value, lat, x_limit, yr_Num)
    
    filename = ['figure_latitudinal_dependence_' num2str(i)];
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points');
    set(gcf, 'PaperPosition', [100, 1000, 200, 310]);
    print('-djpeg', '-r600', [figure_path filename])
    
    close all
    
end

% figure combination
figure_combined = [];
for i = [1 3]
    
    a1 = imread([figure_path 'figure_' num2str(i) '.jpg']);
    b1 = imread([figure_path 'figure_latitudinal_dependence_' num2str(i) '.jpg']);
    c1 = [a1 b1];
    
    a2 = imread([figure_path 'figure_' num2str(i+1) '.jpg']);
    b2 = imread([figure_path 'figure_latitudinal_dependence_' num2str(i+1) '.jpg']);
    c2 = [a2 b2];
    
    c = [c1, c2];
    
    figure_combined = cat(1, figure_combined, c);
    
end
imshow(figure_combined)
print('-djpeg', '-r600', [figure_path 'figure_combined_clear_daytime.jpg'])

end