%% this code can be used for both T2 and T2. Just replace T2 with T2 throughout the script

close all
clear all
clc;

addpath('./MatlabFunctions')
addpath('./MatlabFunctions/TRM')
addpath('./MatlabFunctions/HW')

do_attribution_check = 1;
do_global_pattern    = 1;
do_attribution = 1;


data_path = './Generate Data/esm2mb-urban-continue-sheffield-8xdaily-20years/';
load([data_path 'time']) 
load([data_path 'lon_lat'])
load([data_path 'urban_frac'])
load([data_path 'all_T2_rural_urbn_clear_nighttime'])
load([data_path 'prec_month']);

T2_sum_test = T2_term_alpha_TRM+T2_term_ra_TRM+T2_term_rs_TRM+T2_term_Grnd_TRM+T2_term_ra_prime_TRM;

plot(T2_sum_TRM(:),T2_sum_test(:),'r.');

%% create mask_urban
[nrow, ncol , N] = size(Diff_T2); % N is number of months in the whole time series

mask_urban_temp = nan(size(urban_frac));
mask_urban_temp(urban_frac>0.001) = 1;
mask_urban = repmat(mask_urban_temp, 1, 1, N);

%% determine average period

%average_period_value = 1 (annual), 2(summer), 3(winter)
average_period_value = 2; % need modify

mask_2 = nan(size(mask));

    switch average_period_value
        
        case 1
            
            mask_2 = mask;
            
        case 2
            
                        
            for i =1: yr_Num
                
                mask_2(:,:,(i-1)*12+6:(i-1)*12+8) = mask (:,:,(i-1)*12+6:(i-1)*12+8);
    
            end
            
        case 3
            
            for i =1: yr_Num
                
                mask_2(:,:,(i-1)*12+1:(i-1)*12+1) = mask (:,:,(i-1)*12+1:(i-1)*12+1);                
                mask_2(:,:,(i-1)*12+11:(i-1)*12+12) = mask (:,:,(i-1)*12+11:(i-1)*12+12);
    
            end            

        otherwise 
            
            disp('average_period_value needs to be 1 or 2 or 3')
        
    end

mask_combined = mask_2.*mask_urban;

% plot_map_daily(nansum(prec_month(:,:,61:72),3)/1, 1, 1500)

%% Attribution check

if do_attribution_check == 1
Diff_TRM = (Diff_T2.*mask_combined - T2_sum_TRM.*mask_combined).^2;
RMSE_TRM = sqrt(nanmean(Diff_TRM(:)));

FontSize_value = 18;
Fontname_value = 'Arial';
n_row = 1;
n_col = 1;
h = figure;
set(h, 'Position', [100, 100, 500, 500]); % [Left Bottom Width Hight]

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
ha = tight_subplot(n_row,n_col,[.01 .01],[.15 .05],[.15 .03]);

TRM_color = [237 47 53]/255;
% IBM_color = [22 123 255]/255;

axes(ha(1))

x = reshape(Diff_T2.*mask_combined,[nrow*ncol*N,1]);
y = reshape(T2_sum_TRM.*mask_combined,[nrow*ncol*N,1]);

num_point_TRM = length(find(~isnan(x)));
plot(x,y,'o','MarkerEdgeColor',TRM_color)
hold on
axis equal
limit_up = 3;
limit_down = -3;
xx = [limit_down limit_up];
yy = [limit_down limit_up];
plot(xx,yy,'k--')
xlim([limit_down limit_up])
ylim([limit_down limit_up])
set(gca, 'XTick', limit_down:1:limit_up);
set(gca, 'YTick', limit_down:1:limit_up);
xlabel('Direct \DeltaT_s (^oC)');
ylabel('Modeled \DeltaT_s (^oC)');
text((limit_up+limit_down)/2,(limit_up-limit_down)*1/10+limit_down,['RMSE = ' num2str(RMSE_TRM,'%0.2f') '^oC'],'fontname',Fontname_value,'FontSize',FontSize_value)
text((limit_up+limit_down)/2,(limit_up-limit_down)*1.7/10+limit_down,['n = ' num2str(num_point_TRM,'%0.0f')],'fontname',Fontname_value,'FontSize',FontSize_value)
set(gca, 'fontname',Fontname_value,'FontSize',FontSize_value)

% text(-limit-4.2, (limit+limit)*10.6/10-limit,'a','FontWeight','bold','fontname',Fontname_value,'FontSize', FontSize_value)

% save
filename = 'figure_rmse_T2';
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'points');
set(gcf, 'PaperPosition', [100, 100, 500, 500]);
print('-djpeg', '-r300', [data_path filename])

end
%% Global pattern

if do_global_pattern == 1
% Values_input chooses from below: 
% Diff_T2; T2_sum_TRM;
% T2_term_alpha_TRM; T2_term_ra_TRM; T2_term_rs_TRM; T2_term_Grnd_TRM

% dT2_dalpha_TRM_ref; dT2_dalpha_TRM_sel; dT2_dalpha_TRM
% dT2_dra_TRM_ref; dT2_dra_TRM_sel; dT2_dra_TRM
% dT2_drs_TRM_ref; dT2_drs_TRM_sel; dT2_drs_TRM

mask_input = mask.*mask_urban;

value_limit = 3; % need modify

for i = 1:6
    
    if i == 1
        Values_input = Diff_T2;
    elseif i == 2
        Values_input = T2_sum_TRM;
    elseif i == 3
        Values_input = T2_term_alpha_TRM;
    elseif i == 4
        Values_input = T2_term_ra_TRM + T2_term_ra_prime_TRM;
    elseif i == 5
        Values_input = T2_term_rs_TRM;
    elseif i == 6
        Values_input = T2_term_Grnd_TRM;
    end
    
%    plot_map_daily(Values_input, mask_input, value_limit)
     plot_map(Values_input, mask_input, average_period_value, value_limit, yr_Num)
    
    % save
    filename = ['figure_' num2str(i)];
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points');
    set(gcf, 'PaperPosition', [100, 100, 650, 310]);
    print('-djpeg', '-r300', [data_path filename])
    
    x_limit = [-1 1]*value_limit;
%     plot_latitudinal_dependence_daily(Values_input, mask_input, lat, x_limit)
    plot_latitudinal_dependence(Values_input, mask_input, average_period_value, lat, x_limit, yr_Num)
    
    filename = ['figure_latitudinal_dependence_' num2str(i)];
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points');
    set(gcf, 'PaperPosition', [100, 1000, 200, 310]);
    print('-djpeg', '-r300', [data_path filename])
    
    close all
    
end

% figure combination
figure_combined = [];
for i = [1 3 5]
    
    a1 = imread([data_path 'figure_' num2str(i) '.jpg']);
    b1 = imread([data_path 'figure_latitudinal_dependence_' num2str(i) '.jpg']);
    c1 = [a1, b1];
    
    a2 = imread([data_path 'figure_' num2str(i+1) '.jpg']);
    b2 = imread([data_path 'figure_latitudinal_dependence_' num2str(i+1) '.jpg']);
    c2 = [a2, b2];
    
    c = [c1, c2];
    
    figure_combined = cat(1, figure_combined, c);
    
end
imshow(figure_combined)
print('-djpeg', '-r600', [data_path 'figure_combined_T2.jpg'])

end


if do_attribution == 1
%% Global and regional

    
mask_to_use  = mask_combined;

region_names = {'Global','US','China','Europe'};
region_Num   = length(region_names);

global_index = 1;
US_index     = 2;
China_index  = 3;
EU_index     = 4;

load favoritecolor.mat
color(1,:) = [0 0 0]/255;
color(2,:) = red_rgb;
color(3,:) = blue_rgb;
color(4,:) = green_rgb;

% Global
lat_index{global_index} = 1:length(lat);
lon_index{global_index} = 1:length(lon);

% US
lon_left_EA  = -130+360;
lon_right_EA = -70+360;
lat_low_EA   = 30;
lat_up_EA    = 55;
lat_index{US_index} = find (lat >lat_low_EA  & lat<lat_up_EA);
lon_index{US_index} = find (lon >lon_left_EA & lon<lon_right_EA);    

% % China
lon_left_EC  = 95;
lon_right_EC = 120;
lat_low_EC   = 20;
lat_up_EC    = 45;
lat_index{China_index} = find (lat >lat_low_EC  & lat<lat_up_EC);
lon_index{China_index} = find (lon >lon_left_EC & lon<lon_right_EC);
 
% Europe
lon_left_EC  = 0;
lon_right_EC = 60;
lat_low_EC   = 35;
lat_up_EC    = 60;
lat_index{EU_index} = find (lat >lat_low_EC  & lat<lat_up_EC);
lon_index{EU_index} = find (lon >lon_left_EC & lon<lon_right_EC);

mask_lat_lon = zeros(size(mask_urban))+NaN;
mask_lat_lon(lon_index{US_index},lat_index{US_index},:)=1;

% plot_map_daily(mask_lat_lon(:,:,1), 1, 0.1)


%%
variable_all = {'Diff_T2','T2_sum_TRM','T2_term_alpha_TRM','T2_term_ra_TRM','T2_term_rs_TRM','T2_term_Grnd_TRM'};
var_Num = length(variable_all);

spatial_R2 = zeros(var_Num,length(lat_index))+NaN;
spatial_cov_prec = zeros(var_Num,length(lat_index))+NaN;
spatial_R2_prec = zeros(var_Num,length(lat_index))+NaN;


for region_index = 1:region_Num
    
for ivar = 1:var_Num

    variable = variable_all{ivar};

    disp(variable)
    
    clear x_temp1 x_temp2 y_temp nan_value
 
    if ivar == 4
    eval(['[',variable,'_global{region_index},',variable,'_mean{region_index},',strtrim(variable),'_std{region_index}]=spatial_DL((T2_term_ra_TRM(lon_index{region_index},lat_index{region_index},:)+T2_term_ra_prime_TRM(lon_index{region_index},lat_index{region_index},:)).*mask_to_use(lon_index{region_index},lat_index{region_index},:))']);
    else
    eval(['[',variable,'_global{region_index},',variable,'_mean{region_index},',strtrim(variable),'_std{region_index}]=spatial_DL(',variable,'(lon_index{region_index},lat_index{region_index},:).*mask_to_use(lon_index{region_index},lat_index{region_index},:))']);        
    end
    
    % calculate covariances 
    x_temp1 = nanmean(Diff_T2(lon_index{region_index},lat_index{region_index},:).*mask_to_use(lon_index{region_index},lat_index{region_index},:),3);
    x_temp2 = nansum(prec_month(lon_index{region_index},lat_index{region_index},:).*mask_to_use(lon_index{region_index},lat_index{region_index},:),3)/yr_Num; 
    eval(['y_temp  = nanmean(',variable,'(lon_index{region_index},lat_index{region_index},:).*mask_to_use(lon_index{region_index},lat_index{region_index},:),3)'])
    
    nan_value  = find(isnan(y_temp));
    x_temp1(nan_value) = [];
    x_temp2(nan_value) = [];
    y_temp(nan_value) = [];

    z_temp = cov(x_temp2(:),y_temp(:));

    spatial_R2(ivar,region_index)=calculateR2(x_temp1(:),y_temp(:));
    spatial_R2_prec(ivar,region_index)=calculateR2(x_temp2(:),y_temp(:));
    spatial_cov_prec(ivar,region_index)=z_temp(2,1);
    

end

end

%% 
FontSize_value = 14;
Fontname_value = 'Arial';
n_row = 1;
n_col = 1;
h = figure;
set(h, 'Position', [100, 100, 600, 350]); % [Left Bottom Width Hight]

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

for region_index = 2:region_Num

superbar(1+0.1125*(region_index-3)*2,Diff_T2_mean{region_index},'E',Diff_T2_std{region_index},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(region_index,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)
hold on
box on

superbar(2+0.1125*(region_index-3)*2,T2_sum_TRM_mean{region_index},'E',T2_sum_TRM_std{region_index},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(region_index,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

superbar(3+0.1125*(region_index-3)*2,T2_term_alpha_TRM_mean{region_index},'E',T2_term_alpha_TRM_std{region_index},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(region_index,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

superbar(4+0.1125*(region_index-3)*2,T2_term_ra_TRM_mean{region_index},'E',T2_term_ra_TRM_std{region_index},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(region_index,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

superbar(5+0.1125*(region_index-3)*2,T2_term_rs_TRM_mean{region_index},'E',T2_term_rs_TRM_std{region_index},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(region_index,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

superbar(6+0.1125*(region_index-3)*2,T2_term_Grnd_TRM_mean{region_index},'E',T2_term_Grnd_TRM_std{region_index},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(region_index,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)

% superbar(7+0.1125*(region_index-3)*2,T2_term_ra_prime_TRM_mean{region_index},'E',T2_term_ra_prime_TRM_std{region_index},'BarWidth',BarWidth_value,'ErrorbarLineWidth',ErrorbarLineWidth_value,'BarFaceColor',color(region_index,:),'ErrorbarColor','k','ErrorbarRelativeWidth', ErrorbarRelativeWidth_value)


y_up = 1;
y_down = -0.5;

set(gca,'YLim',[y_down y_up]);
set(gca, 'YTick',y_down:0.5:y_up);
set(gca, 'YTickLabel', {'-0.5','0','0.5','1'});

plot(5,(y_up-y_down)*(9.2-0.6*(region_index-2))/10+y_down,'s','MarkerEdgeColor','none','MarkerFaceColor',color(region_index,:),'MarkerSize',14)
text(5.15,(y_up-y_down)*(9.2-0.6*(region_index-2))/10+y_down,region_names{region_index},'fontname',Fontname_value,'FontSize', FontSize_value-1,'Color',color(region_index,:))

end
xlim([0.5 6.5])
set(gca, 'XTick', 1:6);
set(gca, 'XTickLabel', {'GFDL','TRM','\alpha','r_a','r_s','G'}); %,'{r_a}^{\prime}'
ylabel('\Delta T (^oC)', 'fontname',Fontname_value,'FontSize',FontSize_value);
set(gca, 'fontname',Fontname_value,'FontSize',FontSize_value)
print('-djpeg', '-r600', [data_path 'figure_attribution_T2.jpg'])

% %%
% FontSize_value = 14;
% Fontname_value = 'Arial';
% LineWidth_value = 1.5;
% n_row = 2;
% n_col = 2;
% h = figure;
% set(h, 'Position', [100, 100, 1200, 600]); % [Left Bottom Width Hight]
% 
% % [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
% %
% %   in:  Nh      number of axes in hight (vertical direction)
% %        Nw      number of axes in width (horizontaldirection)
% %        gap     gaps between the axes in normalized units (0...1)
% %                   or [gap_h gap_w] for different gaps in height and width 
% %        marg_h  margins in height in normalized units (0...1)
% %                   or [lower upper] for different lower and upper margins 
% %        marg_w  margins in width in normalized units (0...1)
% %                   or [left right] for different left and right margins
% ha = tight_subplot(n_row,n_col,[.08 .18],[.06 .04],[.15 .04]);
% 
% for region_index = 1:region_Num
%     
%     axes(ha(region_index))
% 
%     clear x_temp y_temp y_temp2
%     
%     x_temp   = nansum(prec_month(lon_index{region_index},lat_index{region_index},:).*mask_to_use(lon_index{region_index},lat_index{region_index},:),3)/yr_Num;     
%     y_temp   = nanmean(Diff_T2(lon_index{region_index},lat_index{region_index},:).*mask_to_use(lon_index{region_index},lat_index{region_index},:),3);
%     y_temp2  = nanmean(T2_sum_TRM(lon_index{region_index},lat_index{region_index},:).*mask_to_use(lon_index{region_index},lat_index{region_index},:),3);
% 
%     
%     plot(x_temp, y_temp,'o','color',color(region_index,:));
%     hold on
%     plot(x_temp, y_temp2,'s','color',color(region_index,:));
%     hold on
%     if region_index == 1
%     y_up = 10;
%     y_down = -10;
%     else
%     y_up = 6;
%     y_down = -1;        
%     end
%     
%     set(gca,'YLim',[y_down y_up]);
%     xlim([0 2000])
%     set(gca, 'XTick', 0:500:2000)
% %      set(gca, 'XTickLabel', {'sum', '\alpha', 'r_a', 'r_s', 'G'})
%     xlabel('Precipitation (mm/year)');
%     ylabel('\Delta T2');
%     set(gca, 'fontname',Fontname_value,'FontSize',FontSize_value)
%     
%     % text(-0.4, (y_up-y_down)*10.6/10+y_down,'(a)','fontname',Fontname_value,'FontSize', FontSize_value+2)
%     text(1300,(y_up-y_down)*9/10+y_down-0.1,region_names{region_index},'fontname',Fontname_value,'FontSize', FontSize_value,'Color',color(region_index,:))
%     text(1600,(y_up-y_down)*9/10+y_down,strcat('R^2=',num2str(round(spatial_R2_prec(1,region_index)*100)/100)),'fontname',Fontname_value,'FontSize', FontSize_value,'Color',color(region_index,:))
%     
% 
% 
% end
% 
% 
% print('-djpeg', '-r600', [data_path 'figure_scatter_T2.jpg'])
% 
% 
% %
% FontSize_value = 14;
% Fontname_value = 'Arial';
% LineWidth_value = 1.5;
% n_row = 2;
% n_col = 2;
% h = figure;
% set(h, 'Position', [100, 100, 1200, 600]); % [Left Bottom Width Hight]
% 
% % [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
% %
% %   in:  Nh      number of axes in hight (vertical direction)
% %        Nw      number of axes in width (horizontaldirection)
% %        gap     gaps between the axes in normalized units (0...1)
% %                   or [gap_h gap_w] for different gaps in height and width 
% %        marg_h  margins in height in normalized units (0...1)
% %                   or [lower upper] for different lower and upper margins 
% %        marg_w  margins in width in normalized units (0...1)
% %                   or [left right] for different left and right margins
% ha = tight_subplot(n_row,n_col,[.08 .18],[.06 .04],[.15 .04]);
% 
% for region_index = 1:length(lat_index)
%     
% axes(ha(region_index))
% 
% for ivar = 2:var_Num
% 
% Cov_IBM(ivar,region_index) = spatial_cov_prec(ivar,region_index)/spatial_cov_prec(2,region_index)*100;
% 
% 
% b(ivar,region_index) = bar(ivar-1, Cov_IBM(ivar,region_index));
% hold on
% 
% set(b(ivar,region_index), 'Facecolor', color(region_index,:),'EdgeColor','none','barWidth',0.8);
% 
% 
% 
% y_up = 200;
% y_down = -200;
% set(gca,'YLim',[y_down y_up]);
% xlim([0.3 5.7])
% set(gca, 'XTick', 1:5)
% set(gca, 'XTickLabel', {'sum', '\alpha', 'r_a', 'r_s', 'G'})
% ylabel('Covariance explained %');
% set(gca, 'fontname',Fontname_value,'FontSize',FontSize_value)
% 
% % text(-0.4, (y_up-y_down)*10.6/10+y_down,'(a)','fontname',Fontname_value,'FontSize', FontSize_value+2)
% text(0.6,(y_up-y_down)*9/10+y_down,region_names{region_index},'fontname',Fontname_value,'FontSize', FontSize_value,'Color',color(region_index,:))
% 
% 
% 
% end
% end
% 
% print('-djpeg', '-r600', [data_path 'figure_covariance_T2.jpg'])

end
