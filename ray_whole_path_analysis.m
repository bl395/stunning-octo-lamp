%%
% This script is the analysis of the output form ray_whole_path.m
% Find out the receiving rays, the coorisponding landing points and
% reflection points.
% It needs to load

month=3;
date=2;
load('VIPIR_2019_02.mat');%load vipir observation data, mainly time information
elevs=3:0.2:81;% elevation
for frequencycount=1:5
    i=1;% index for O mode multihop
    j=1;% index for O mode direct transmission
    m=1;% index for X mode direct transmission
    k=1;% index for X mode multihop
    for timecount=1:675
        minute=single(min(timecount));
        hor=single(hour(timecount));
        fr=[4.1 5.1 6.0 6.4 7.2];%frequency channel in MHz
        bearing_angle=175:0.5:185;
        elevs=3:0.2:81;
        tic
        for bearnumber=1:length(bearing_angle)
            
            direct=['D:\ray_whole_data_MAR02\',num2str(fr(frequencycount)),'MHz'];%data file directory
            filename=['\raydata_',num2str(fr(frequencycount)),'_',num2str(bearing_angle(bearnumber)),'_',num2str(hor),'_',num2str(minute),'.mat'];
            FileName=[direct,filename];
            load(FileName);
            for elevsnumber=1:391 %go through all elevations
                O_landlocation=find(ray_O_final(elevsnumber).height<=0);%find land point loaction in arrry
                if isempty(O_landlocation)==0 % There is landing points in the ray
                    if length(O_landlocation)>1 % multi hop situation
                        land_selection_multi_O = O_lat_land(2)<-89.7;% restrict landing points 0.1degree in latitude=11km
                        absorption_selection_multi_O = O_absorption_land(2)<20;% restrict absorption
                        if land_selection_multi_O&&absorption_selection_multi_O % find multihop rays
                            ray_O_multihop(i).lat=ray_O_final(elevsnumber).lat;
                            ray_O_multihop(i).lon=ray_O_final(elevsnumber).lon;
                            ray_O_multihop(i).ground_range=ray_O_final(elevsnumber).ground_range;
                            ray_O_multihop(i).group_range=ray_O_final(elevsnumber).group_range;
                            ray_O_multihop(i).height=ray_O_final(elevsnumber).height;
                            ray_O_multihop(i).absorption=ray_O_final(elevsnumber).absorption;
                            ray_O_multihop(i).hour=hor;
                            ray_O_multihop(i).minute=minute;
                            ray_O_multihop(i).elevation=elevs(elevsnumber);
                            ray_O_multihop(i).bearing=bearing_angle(bearnumber);
                            i=i+1;
                        end
                        % find direct transmission in rays that have
                        % multihop attempted.
                        land_selection_single_O=O_lat_land(1)<-89.7;
                        absorption_selection_single_O=O_absorption_land(1)<20;
                        if land_selection_single_O&&absorption_selection_single_O
                            ray_O_single(j).lat=ray_O_final(elevsnumber).lat;
                            ray_O_single(j).lon=ray_O_final(elevsnumber).lon;
                            ray_O_single(j).ground_range=ray_O_final(elevsnumber).ground_range;
                            ray_O_single(j).group_range=ray_O_final(elevsnumber).group_range;
                            ray_O_single(j).height=ray_O_final(elevsnumber).height;
                            ray_O_single(j).absorption=ray_O_final(elevsnumber).absorption;
                            ray_O_single(j).hour=hor;
                            ray_O_single(j).minute=minute;
                            ray_O_single(j).elevation=elevs(elevsnumber);
                            ray_O_single(j).bearing=bearing_angle(bearnumber);
                            j=j+1;
                        end
                        
                    elseif length(O_landlocation)==1% single hop attempted situation
                        land_selection_direct_O=O_lat_land(1)<-89.7;
                        absorption_selection_O=O_absorption_land(1)<20;
                        if land_selection_direct_O&&absorption_selection_O
                            ray_O_single(j).lat=ray_O_final(elevsnumber).lat;
                            ray_O_single(j).lon=ray_O_final(elevsnumber).lon;
                            ray_O_single(j).ground_range=ray_O_final(elevsnumber).ground_range;
                            ray_O_single(j).group_range=ray_O_final(elevsnumber).group_range;
                            ray_O_single(j).height=ray_O_final(elevsnumber).height;
                            ray_O_single(j).absorption=ray_O_final(elevsnumber).absorption;
                            ray_O_single(j).hour=hor;
                            ray_O_single(j).minute=minute;
                            ray_O_single(j).elevation=elevs(elevsnumber);
                            ray_O_single(j).bearing=bearing_angle(bearnumber);
                            j=j+1;
                        end
                    end
                end
                % for X mode rays, the same process as O mode.
                X_landlocation=find(ray_X_final(elevsnumber).height<=0);
                if isempty(X_landlocation)==0
                    X_lat_land=ray_X_final(elevsnumber).lat(X_landlocation);
                    X_lon_land=ray_X_final(elevsnumber).lon(X_landlocation);
                    X_absorption_land=ray_X_final(elevsnumber).absorption(X_landlocation);
                    X_grouprange_land=ray_X_final(elevsnumber).group_range(X_landlocation);
                    X_groundrange_land=ray_X_final(elevsnumber).ground_range(X_landlocation);
                    if length(X_landlocation)>1
                        land_selection_multi_X = X_lat_land(2)<-89.7;
                        absorption_selection_multi_X = X_absorption_land(2)<20;
                        if land_selection_multi_X&&absorption_selection_multi_X % find multihop rays
                            ray_X_multihop(k).lat=ray_X_final(elevsnumber).lat;
                            ray_X_multihop(k).lon=ray_X_final(elevsnumber).lon;
                            ray_X_multihop(k).ground_range=ray_X_final(elevsnumber).ground_range;
                            ray_X_multihop(k).group_range=ray_X_final(elevsnumber).group_range;
                            ray_X_multihop(k).height=ray_X_final(elevsnumber).height;
                            ray_X_multihop(k).absorption=ray_X_final(elevsnumber).absorption;
                            ray_X_multihop(k).hour=hor;
                            ray_X_multihop(k).minute=minute;
                            ray_X_multihop(k).elevation=elevs(elevsnumber);
                            ray_X_multihop(k).bearing=bearing_angle(bearnumber);
                            k=k+1;
                        end
                        land_selection_single_X=X_lat_land(1)<-89.7;
                        absorption_selection_single_X=X_absorption_land(1)<20;
                        if land_selection_single_X&&absorption_selection_single_X
                            ray_X_single(m).lat=ray_X_final(elevsnumber).lat;
                            ray_X_single(m).lon=ray_X_final(elevsnumber).lon;
                            ray_X_single(m).ground_range=ray_X_final(elevsnumber).ground_range;
                            ray_X_single(m).group_range=ray_X_final(elevsnumber).group_range;
                            ray_X_single(m).height=ray_X_final(elevsnumber).height;
                            ray_X_single(m).absorption=ray_X_final(elevsnumber).absorption;
                            ray_X_single(m).hour=hor;
                            ray_X_single(m).minute=minute;
                            ray_X_single(m).elevation=elevs(elevsnumber);
                            ray_X_single(m).bearing=bearing_angle(bearnumber);
                            m=m+1;
                        end
                        
                    elseif length(X_landlocation)==1
                        land_selection_direct_X=X_lat_land(1)<-89.7;
                        absorption_selection_X=X_absorption_land(1)<20;
                        if land_selection_direct_X&&absorption_selection_X
                            ray_X_single(m).lat=ray_X_final(elevsnumber).lat;
                            ray_X_single(m).lon=ray_X_final(elevsnumber).lon;
                            ray_X_single(m).ground_range=ray_X_final(elevsnumber).ground_range;
                            ray_X_single(m).group_range=ray_X_final(elevsnumber).group_range;
                            ray_X_single(m).height=ray_X_final(elevsnumber).height;
                            ray_X_single(m).absorption=ray_X_final(elevsnumber).absorption;
                            ray_X_single(m).hour=hor;
                            ray_X_single(m).minute=minute;
                            ray_X_single(m).elevation=elevs(elevsnumber);
                            ray_X_single(m).bearing=bearing_angle(bearnumber);
                            m=m+1;
                        end
                    end
                end
            end
        end
        toc
        timecount % show the running stage of the code
    end
    % for different frequencies, there is not necessarily have all four
    % trasmission mode so the saved variable need manually adjust.
    switch frequencycount
        case 1
            save(['ray_whole_path_selected_',num2str(fr(frequencycount)),'.mat'],...
                'ray_O_multihop','ray_O_single');
        case 2
            save(['ray_whole_path_selected_',num2str(fr(frequencycount)),'.mat'],...
                'ray_O_multihop','ray_O_single','ray_X_single');
        case 3
            save(['ray_whole_path_selected_',num2str(fr(frequencycount)),'.mat'],...
                'ray_O_multihop','ray_O_single','ray_X_single');
        case 4
            save(['ray_whole_path_selected_',num2str(fr(frequencycount)),'.mat'],...
                'ray_X_single','ray_O_multihop','ray_O_single','ray_X_multihop');
        case 5
            save(['ray_whole_path_selected_',num2str(fr(frequencycount)),'.mat'],...
                'ray_X_single','ray_O_multihop','ray_O_single','ray_X_multihop');
    end
end
%%
fr=[4.1,5.1,6,6.4,7.2];% frequency used in the raytracing
frequencycount=1;
% Load up the selected ray information.This .mat file not necessarily include all
% four tansmission mode (X/O mode direct/multihop transmission). Manually selection is needed
load(['ray_whole_path_selected_',num2str(fr(frequencycount)),'.mat']);

for i=1:length(ray_O_single)
    % find out the landing points for O mode direct transmission
    land_O_single_location=find(ray_O_single(i).height<=0);
    lat_O_land_single(i)=ray_O_single(i).lat(land_O_single_location(1));
    lon_O_land_single(i)=ray_O_single(i).lon(land_O_single_location(1));
    absorption_O_land_single(i)=ray_O_single(i).absorption(land_O_single_location(1));
    grouprange_O_land_single(i)=ray_O_single(i).group_range(land_O_single_location(1));
    groundrange_O_land_single(i)=ray_O_single(i).ground_range(land_O_single_location(1));
    % find out the cooresponding reflection points
    [O_reflection,O_reflection_location]=findpeaks(ray_O_single(i).height);
    O_reflection_height(i)=O_reflection(1);
    O_reflection_lat(i)=ray_O_single(i).lat(O_reflection_location(1));
    O_reflection_lon(i)=ray_O_single(i).lon(O_reflection_location(1));
    O_reflection_absorption(i)=ray_O_single(i).absorption(O_reflection_location(1));
    O_reflection_grouprange(i)=ray_O_single(i).group_range(O_reflection_location(1));
    O_reflection_groundrange(i)=ray_O_single(i).ground_range(O_reflection_location(1));
    minute_single_O(i)=ray_O_single(i).minute;
    hour_single_O(i)=ray_O_single(i).hour;
end
time_O_single=hour_single_O+minute_single_O/60;% get time information for each ray

for i=1:length(ray_O_multihop)
    % find out the landing points for O mode multihop(two hops mode is intrested)
    land_O_multihop_location=find(ray_O_multihop(i).height<=0);
    % with index as (1,:)means the first landing points
    % with index as (2,:)means the second landing points
    lat_O_land_multihop(:,i)=ray_O_multihop(i).lat(land_O_multihop_location(1:2));
    lon_O_land_multihop(:,i)=ray_O_multihop(i).lon(land_O_multihop_location(1:2));
    absorption_O_land_multihop(:,i)=ray_O_multihop(i).absorption(land_O_multihop_location(1:2));
    grouprange_O_land_multihop(:,i)=ray_O_multihop(i).group_range(land_O_multihop_location(1:2));
    groundrange_O_land_multihop(:,i)=ray_O_multihop(i).ground_range(land_O_multihop_location(1:2));
    % find out the coorespond reflection points
    [O_reflection,O_reflection_location]=findpeaks(ray_O_multihop(i).height);
    % with index as (1,:)means the first reflection points
    % with index as (2,:)means the second reflection points
    O_reflection_height_multi(:,i)=O_reflection(1:2);
    O_reflection_lat_multi(:,i)=ray_O_multihop(i).lat(O_reflection_location(1:2));
    O_reflection_lon_multi(:,i)=ray_O_multihop(i).lon(O_reflection_location(1:2));
    O_reflection_absorption_multi(:,i)=ray_O_multihop(i).absorption(O_reflection_location(1:2));
    O_reflection_grouprange_multi(:,i)=ray_O_multihop(i).group_range(O_reflection_location(1:2));
    O_reflection_groundrange_multi(:,i)=ray_O_multihop(i).ground_range(O_reflection_location(1:2));
    minute_multi_O(i)=ray_O_multihop(i).minute;
    hour_multi_O(i)=ray_O_multihop(i).hour;
end
time_O_multihop=hour_multi_O+minute_multi_O/60;% save time information for each ray

% X mode is the same procedure as O mode
for i=1:length(ray_X_single)
    land_X_single_location=find(ray_X_single(i).height<=0);
    lat_X_land_single(i)=ray_X_single(i).lat(land_X_single_location(1));
    lon_X_land_single(i)=ray_X_single(i).lon(land_X_single_location(1));
    absorption_X_land_single(i)=ray_X_single(i).absorption(land_X_single_location(1));
    grouprange_X_land_single(i)=ray_X_single(i).group_range(land_X_single_location(1));
    groundrange_X_land_single(i)=ray_X_single(i).ground_range(land_X_single_location(1));
    [X_reflection,X_reflection_location]=findpeaks(ray_X_single(i).height);
    X_reflection_height(i)=X_reflection(1);
    X_reflection_lat(i)=ray_X_single(i).lat(X_reflection_location(1));
    X_reflection_lon(i)=ray_X_single(i).lon(X_reflection_location(1));
    X_reflection_absorption(i)=ray_X_single(i).absorption(X_reflection_location(1));
    X_reflection_grouprange(i)=ray_X_single(i).group_range(X_reflection_location(1));
    X_reflection_groundrange(i)=ray_X_single(i).ground_range(X_reflection_location(1));
    minute_X_single(i)=ray_X_single(i).minute;
    hour_X_single(i)=ray_X_single(i).hour;
end
time_X_single=hour_X_single+minute_X_single/60;

for i=1:length(ray_X_multihop)
    land_X_multihop_location=find(ray_X_multihop(i).height<=0);
    lat_X_land_multihop(:,i)=ray_X_multihop(i).lat(land_X_multihop_location(1:2));
    lon_X_land_multihop(:,i)=ray_X_multihop(i).lon(land_X_multihop_location(1:2));
    absorption_X_land_multihop(:,i)=ray_X_multihop(i).absorption(land_X_multihop_location(1:2));
    grouprange_X_land_multihop(:,i)=ray_X_multihop(i).group_range(land_X_multihop_location(1:2));
    groundrange_X_land_multihop(:,i)=ray_X_multihop(i).ground_range(land_X_multihop_location(1:2));
    [X_reflection,X_reflection_location]=findpeaks(ray_X_multihop(i).height);
    X_reflection_height_multi(:,i)=X_reflection(1:2);
    X_reflection_lat_multi(:,i)=ray_X_multihop(i).lat(X_reflection_location(1:2));
    X_reflection_lon_multi(:,i)=ray_X_multihop(i).lon(X_reflection_location(1:2));
    X_reflection_absorption_multi(:,i)=ray_X_multihop(i).absorption(X_reflection_location(1:2));
    X_reflection_grouprange_multi(:,i)=ray_X_multihop(i).group_range(X_reflection_location(1:2));
    X_reflection_groundrange_multi(:,i)=ray_X_multihop(i).ground_range(X_reflection_location(1:2));
    minute_multi_X(i)=ray_X_multihop(i).minute;
    hour_multi_X(i)=ray_X_multihop(i).hour;
end
time_X_multihop=hour_multi_X+minute_multi_X/60;

save(['landing_points_selection_',num2str(fr(frequencycount)),'.mat']);
%%
%scattered plot of the landing points information for all five frequency
%channels.
figure(1)
fr=[4.1,5.1,6,6.4,7.2];
for frequencycount=1:5
    load(['landing_points_selection_',num2str(fr(frequencycount)),'.mat']);
    subplot(5,1,frequencycount)
    %change the variable below to acheive different scattered figure
    scatter(time_O_multihop,grouprange_O_land_multihop(2,:),10, absorption_O_land_multihop(2,:),'filled');
    if frequencycount==1
        title('Landing points,within 30km','FontSize',14);
    elseif frequencycount==5
        xlabel('Mar 2nd 2018 UT','FontSize',12);
        
    end
    colormap(flipud(viridis));%get the colorblind friendly
    %colormap(viridis);
    h = colorbar;
    set(get(h,'label'),'string','Absorption dB','FontSize',12);%name the colorbar
    
    set(gca,'xtick',0:3:24)
    %set(gca,'ytick',1200:200:2000)
    caxis([5,20])%fix the range of colorbar
    if length(num2str(fr(frequencycount)))<2
        ylabel(['GR',num2str(fr(frequencycount)),'.0MHz(km)'],'FontSize',12);
    else
        ylabel(['GR',num2str(fr(frequencycount)),'MHz(km)'],'FontSize',12);
    end
    xlim([0,24]);
    ylim([1200,2200]);
    grid on
end

%%
% plot the whole ray path of selected ray mode thoughout all bearing angle
% and time.
for i=1:length(ray_O_single)
    plot(ray_O_single(i).ground_range,ray_O_single(i).height);
    hold on
    grid on
end
xlabel('Ground Range km');
ylabel('Altitude km');
set(gca,'xtick',0:300:1500)
xlim([0,1500]);