%%
% prepare for the iri_options as input for generating ionosphere.
latitude=-90:1:-68;
longitude=0:4:356;
UTselect=h5read('IRI_correction.h5','/UTselect');% time information based on VIPIR observation
foF2_correction=h5read('IRI_correction.h5','/foF2IRI_correct');
foE_correction=h5read('IRI_correction.h5','/foEIRI_correct');% load corrected foF2 and foE information
for latcount=1:length(latitude)
    for loncount=1:length(longitude)
        for timecount=1:675
            iri_options(loncount,latcount,timecount).foF2=foF2_correction(loncount,latcount,timecount);
            %iri_options(loncount,latcount,time).foE=foE_correction(loncount,latcount,time);
        end
    end
end
%%
%parpool(16)
month=3;
date=2;
load('VIPIR_2019_02.mat');
for timecount=1:675
    
    %timecount=310;
    month=3;
    date=2;
    minute=double(min(timecount));
    hor=double(hour(timecount));
    UT = [2018,month,date,hor,minute];
    %findUT=double(UT(5)==UTselect(5,:))+double(UT(4)==UTselect(4,:));% UT - year, month, day, hour, minute
    speed_of_light = 2.99792458e8;
    R12 = 12;
    elevs = 3:0.2:81;               % initial elevation of rays
    
    ray_bears =ones(size(elevs));
    %McMurdo Station
    origin_lat = -77.8464;             % latitude of the start point of rays
    origin_long = 166.6683;            % longitude of the start point of rays
    origin_ht = 0.01;                % altitude of the start point of rays
    
    doppler_flag = 1;               % interested in Doppler shift
    
    %
    % generate ionospheric, geomagnetic and irregularity grids
    %
    ht_start = 60;          % start height for ionospheric grid (km)
    ht_inc = 3;             % height increment step length (km)
    num_ht = 120;
    lat_start = -90;
    lat_inc = 1;
    num_lat = 23;
    lon_start= 0;
    lon_inc = 4;
    num_lon = 90;% change here
    iono_grid_parms = [lat_start, lat_inc, num_lat, lon_start, lon_inc, num_lon, ...
        ht_start, ht_inc, num_ht, ];
    
    B_ht_start = ht_start;          % start height for geomagnetic grid (km)
    B_ht_inc = 3;                  % height increment (km)
    B_num_ht = ceil(num_ht .* ht_inc ./ B_ht_inc);
    B_lat_start = lat_start;
    B_lat_inc = 1.0;
    B_num_lat = ceil(num_lat .* lat_inc ./ B_lat_inc);
    B_lon_start = lon_start;
    B_lon_inc = 4.0;
    B_num_lon = ceil(num_lon .* lon_inc ./ B_lon_inc);
    geomag_grid_parms = [B_lat_start, B_lat_inc, B_num_lat, B_lon_start, ...
        B_lon_inc, B_num_lon, B_ht_start, B_ht_inc, B_num_ht];
    tic
    [iono_pf_grid, iono_pf_grid_5, collision_freq, Bx, By, Bz] = ...
        gen_iono_grid_3d(UT, R12, iono_grid_parms, ...
        geomag_grid_parms, doppler_flag, 'iri2016',iri_options);% generate ionosphere
    toc
    save(['ionogridtest_',num2str(hor),'_',num2str(minute),'.mat'],'iono_pf_grid','iono_pf_grid_5',...
        'collision_freq','Bx','By','Bz');% save ionospheric information
    %load(['ionogridtest_',num2str(hor),'_',num2str(minute),'.mat']);
    % convert plasma frequency grid to  electron density in electrons/cm^3
    iono_en_grid = iono_pf_grid.^2 / 80.6164e-6;
    iono_en_grid_5 = iono_pf_grid_5.^2 / 80.6164e-6;
    %
    % call raytrace
    %
    fr=[4.1 5.1 6.0 6.4 7.2];
    bearing_angle=175:0.5:185;
    tic
    for frequencycount=1:5
        %frequencycount=4;
        freqs = ones(size(elevs))*fr(frequencycount);   % frequency (MHz)
        for bearnumber=1:length(bearing_angle)
            ray_bears =ones(size(elevs))*bearing_angle(bearnumber);
            nhops = 4;                  % number of hops
            tol = [1e-7 0.01 5];       % ODE solver tolerance and min max stepsizes
            num_elevs = length(elevs);
            
            OX_mode = 1;
            [ray_data_O, ray_O, ray_state_vec_O] = ...
                raytrace_3d(origin_lat, origin_long, origin_ht, elevs, ray_bears, freqs, ...
                OX_mode, nhops, tol, iono_en_grid, iono_en_grid_5, ...
                collision_freq, iono_grid_parms, Bx, By, Bz, ...
                geomag_grid_parms);%O mode rays
            for rayId=1:num_elevs
                num = length(ray_O(rayId).lat);
                ground_range = zeros(1, num);
                lat = ray_O(rayId).lat;
                lon = ray_O(rayId).lon;
                ground_range(2:num) = latlon2raz(lat(2:num), lon(2:num), origin_lat, ...
                    origin_long,'wgs84')/1000.0;
                ray_O(rayId).ground_range = ground_range;
            end
            OX_mode = -1;
            [ray_data_X, ray_X, ray_sv_X] = ...
                raytrace_3d(origin_lat, origin_long, origin_ht, elevs, ray_bears, freqs, ...
                OX_mode, nhops, tol);%X mode rays
            for rayId=1:num_elevs
                num = length(ray_X(rayId).lat);
                ground_range = zeros(1, num);
                lat = ray_X(rayId).lat;
                lon = ray_X(rayId).lon;
                ground_range(2:num) = latlon2raz(lat(2:num), lon(2:num), origin_lat, ...
                    origin_long,'wgs84')/1000.0;
                ray_X(rayId).ground_range = ground_range;
            end
            OX_mode = 0;
            
            [ray_data_N, ray_N, ray_sv_N] = ...
                raytrace_3d(origin_lat, origin_long, origin_ht, elevs, ray_bears, freqs, ...
                OX_mode, nhops, tol);% N mode rays (without Magnetic field)
            
            for rayId=1:num_elevs
                num = length(ray_N(rayId).lat);
                ground_range = zeros(1, num);
                lat = ray_N(rayId).lat;
                lon = ray_N(rayId).lon;
                ground_range(2:num) = latlon2raz(lat(2:num), lon(2:num), origin_lat, ...
                    origin_long,'wgs84')/1000.0;
                ray_N(rayId).ground_range = ground_range;
            end
            for i=1:length(elevs)% select useful ray data and form structure
                ray_O_final(i).lat=ray_O(i).lat;
                ray_O_final(i).lon=ray_O(i).lon;
                ray_O_final(i).height=ray_O(i).height;
                ray_O_final(i).group_range=ray_O(i).group_range;
                ray_O_final(i).ground_range=ray_O(i).ground_range;
                ray_O_final(i).absorption=ray_O(i).absorption;
                ray_O_final(i).lable=ray_data_O(i).ray_label;
                ray_O_final(i).hopnumber=ray_data_O(i).nhops_attempted;
                ray_X_final(i).lat=ray_X(i).lat;
                ray_X_final(i).lon=ray_X(i).lon;
                ray_X_final(i).height=ray_X(i).height;
                ray_X_final(i).group_range=ray_X(i).group_range;
                ray_X_final(i).ground_range=ray_X(i).ground_range;
                ray_X_final(i).absorption=ray_X(i).absorption;
                ray_X_final(i).lable=ray_data_X(i).ray_label;
                ray_X_final(i).hopnumber=ray_data_X(i).nhops_attempted;
            end
            filename=['raydata_',num2str(fr(frequencycount)),'_',num2str(bearing_angle(bearnumber)),'_',num2str(hor),'_',num2str(minute),'.mat'];
            save(filename,'ray_O_final','ray_X_final');%save the raydata
        end
    end
    timecount %keep tracking the stage of the code running
    toc
end
