clear all
close all
clc

data_path = '../esm2mb-urban-continue-sheffield-8xdaily-20years/';
output_path_land = './Generate Data/esm2mb-urban-continue-sheffield-8xdaily-20years/';

%% analysis years and months
yr_Start = 1981;
yr_End   = 2000;
yr_Num   = yr_End - yr_Start + 1;

save ([output_path_land 'time.mat'],'yr_Start','yr_End','yr_Num');


%% lat-lon
latb = ncread([data_path num2str(yr_Start) '0101.nc/',num2str(yr_Start),'0101.atmos_daily.nc'],'latb');
lat = ncread([data_path num2str(yr_Start) '0101.nc/',num2str(yr_Start),'0101.atmos_daily.nc'],'lat');
lonb = ncread([data_path num2str(yr_Start) '0101.nc/',num2str(yr_Start),'0101.atmos_daily.nc'],'lonb');
lon = ncread([data_path num2str(yr_Start) '0101.nc/',num2str(yr_Start),'0101.atmos_daily.nc'],'lon');

save([output_path_land 'lon_lat'], 'lat','lon','latb','lonb')

%% urban fraction
urban_frac_temp = ncread([data_path num2str(yr_Start) '0101.nc/',num2str(yr_Start),'0101.land_month_inst_urbn.nc'],'frac');
urban_frac_yr_Start=urban_frac_temp(:,:,12);
urban_frac_temp = ncread([data_path num2str(yr_End) '0101.nc/',num2str(yr_End),'0101.land_month_inst_urbn.nc'],'frac');
urban_frac_yr_End=urban_frac_temp(:,:,12);

urban_frac = urban_frac_yr_End;

% plot_map(squeeze(urban_frac), 1, 0.1, 1)

save([output_path_land 'urban_frac'], 'urban_frac', 'urban_frac_yr_Start', 'urban_frac_yr_End')

%% load data from land

land_type_all = {'rural'}; %'urbn','rural','cany','roof','ntrl','crop','past','scnd',

variable_all = {'flw','fsw','grnd_flux','evap','sens','Tca','qca','t_ref','q_ref'}; %'flw','fsw','grnd_flux','evap','sens','Tca','qca'

land_type_Num = length(land_type_all);
var_Num = length(variable_all);

for iland_type = 1:land_type_Num
    for ivar = 1:var_Num
        
        land_type = land_type_all{iland_type};
        variable  = variable_all{ivar};
        
        disp([land_type ': ' variable])

        var_land_type = [];
        for iYr = yr_Start:1:yr_End

            var = ncread([data_path num2str(iYr) '0101.nc/' num2str(iYr) '0101.land_8xdaily.nc'], strcat(variable_all{ivar},'_',land_type_all{iland_type}));
            
            var_selected = var(:, :, :);
            
            var_land_type = cat(3, var_land_type, var_selected);

        end

        var_name = [variable '_' land_type];
        eval([var_name,' = var_land_type;']);

        filename = [variable '_' land_type '.mat'];
        save([output_path_land filename], var_name, '-v7.3')
        clear var_name 
    end
end

disp('LAND DONE!')


%% load data from atmosphere

variable_all = {'t_bot','q_bot','lwdn','swdn','ps','lprec','fprec'};
var_Num = length(variable_all);


for ivar = 1:var_Num

    variable = variable_all{ivar};

    disp(variable)

    var_atmos_type = [];
    for iYr = yr_Start:1:yr_End

        var = ncread([data_path num2str(iYr) '0101.nc/' num2str(iYr) '0101.atmos_8xdaily.nc'], variable);
       
        var_selected = var(:, :, :);

        var_atmos_type = cat(3, var_atmos_type, var_selected);

    end

    var_name = variable;
    eval([var_name,' = var_atmos_type;']);

    filename = [variable '.mat'];
    save([output_path_land filename], var_name, '-v7.3')
    clear var_name
end

disp('ATMOS DONE!')
