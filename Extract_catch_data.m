clear all

% This function targets catch in kilos per year

% Extract the grids used by Queensland commercial fishery datasets, at both 30 and 6 minute scales
S_grids = shaperead('InputDatasets/CommercialFishingGrids/Commercial_fishery_30_minute_reporting_grid.shp');
S_sites = shaperead('InputDatasets/CommercialFishingGrids/Commercial_fishery_6_minute_reporting_grid.shp');

% Extract the location of the polygons and the associated codes for both sites and grids
for s = 1:length(S_sites)
    CODE = S_sites(s).RELCODE;
    F = find(CODE == 'S'); F = F(end);
    SiteGridSiteCode{s,1} = CODE(1:F-1);
    SiteGridSiteCode{s,2} = eval(CODE(F+1:end));
    SiteGridSiteCode{s,3} = CODE;
    SitePolygon(s,:,1) = S_sites(s).X(1:4);
    SitePolygon(s,:,2) = S_sites(s).Y(1:4);
end

for s = 1:length(S_grids)
    GridCode{s,1} = S_grids(s).GRID_CODE;
    GridPolygon(s,:,1) = S_grids(s).X(1:end-1);
    GridPolygon(s,:,2) = S_grids(s).Y(1:end-1);
end

% Save the grid structure
save MAT_files/GridPolygon GridPolygon

% Extract the catch data from the QLD fishery datasets
[D_grids,T_grids] = xlsread('InputDatasets/CoralTroutData_new_grids.xlsx');
[D_sites,T_sites] = xlsread('InputDatasets/CoralTroutData_new_sites.xlsx');

% Grab the subset of the data that corresponds to our modelling period
F_sites = find(D_sites(:,1) >= 2009 & D_sites(:,1) <= 2014);
D_sites = D_sites(F_sites,:); T_sites = T_sites(F_sites,:);
F_grids = find(D_grids(:,1) >= 2009 & D_grids(:,1) <= 2014);
D_grids = D_grids(F_grids,:); T_grids = T_grids(F_grids,:);

% Load outlines of the reefs
load MAT_files/ReefRaw

% Go through the grids looking for which reefs belong to each (and can therefore be assigned catch)
for i = 1:length(D_sites)
    
    % Does this site contain reefs?
    F = find(inpolygon(ReefRaw(:,1),ReefRaw(:,2),SitePolygon(i,:,1),SitePolygon(i,:,2)));
    
    if isempty(F) == 0
        SiteContainsReef(i) = 1;
    end
    
end
SiteContainsReef = find(SiteContainsReef==1)';

% How much catch occurred in each of these sites?
SiteCatch = zeros(length(SiteGridSiteCode),6);
for i = 1:length(D_sites)
    ThisGrid = T_sites{i,2};
    ThisSite = D_sites(i,5);
    ThisCatch = D_sites(i,10);
    
    % Some of the sites don't have data because there are too few vessels
    if isnan(ThisCatch) == 0 % These sites have enough data
        MG = find(strcmp([ThisGrid 'S' num2str(ThisSite)],SiteGridSiteCode(:,3)));
        SiteCatch(MG,D_sites(i,1)-2008) = ThisCatch;
    end
end

% Some of the sites don't have values in them. We're going to use the grid data to estimate their value
% That is, we're downscaling the grid data to the site scale.
for i = 1:length(D_grids)
    % Go through the grids one-by-one
    ThisGrid = T_grids{i,2};
    ThisCatch = D_grids(i,9);
    ThisYear = D_grids(i,1);
    
    % If there was at least some catch in the grid
    if isnan(ThisCatch) == 0
        
        % Which sites are in this grid, and also contain reefs
        Sites_in_grid = find(strcmp(ThisGrid,SiteGridSiteCode(:,1)));
        Sites_in_grid_with_reefs = intersect(Sites_in_grid,SiteContainsReef);
        
        % How much of the catch in this grid in this year is already accounted for?
        Sites_in_grid_with_reef_wout_catch = intersect(Sites_in_grid_with_reefs,find(SiteCatch(:,ThisYear-2008) == 0));
        Sites_in_grid_with_reef_with_catch = intersect(Sites_in_grid_with_reefs,find(SiteCatch(:,ThisYear-2008)  > 0));
        CatchAccountedFor = sum(SiteCatch(Sites_in_grid,ThisYear-2008));

        SiteCatch(Sites_in_grid_with_reef_wout_catch,ThisYear-2008) = ...
            (ThisCatch - CatchAccountedFor)./length(Sites_in_grid_with_reef_wout_catch);
    end
    
end

% Plot the catch data for each year
figure(1), clf; CLS = jet(11);
for y = 1:6
    subplot(2,3,y)
    hold on
    text(149,-12,['Catch in ' num2str(2008+y)],'fontsize',16,'horizontalalignment','center')
    text(149,-14,['(tonnes)'],'fontsize',16,'horizontalalignment','center')
    PlotAustralianOutline;
    for s = 1:length(SitePolygon)
        if SiteCatch(s,1) > 0
            if SiteCatch(s,y) > 0
                pp = patch(SitePolygon(s,:,1),SitePolygon(s,:,2),'r');
                set(pp,'facecolor',CLS(ceil(log(SiteCatch(s,y))),:),'edgecolor','none','facealpha',1)
            end
        end
    end
    xlim([141.9542  154.2077]);
    ylim([-24.8643  -10.3984]);
    set(gca,'xticklabel',{},'yticklabel',{})
    box on
end
Make_TIFF('Figures/CatchYears.tiff',[0 0 50 45].*0.6)

% These values give the total kilogrammes of coral trout caught at each site.
% We need to distribute this catch among the reefs in that grid cell,
% allocating it equally to fished hectares in each cell.

load MAT_files/crcb_domain_reserve_contribution SevCentroid SevProtected SevReefArea
ReefCatch_kilos = zeros(size(SevCentroid,1),6);
FishedReefArea = SevReefArea.*(1-SevProtected); % Not all reef area is fished - a proportion is protected

% For each of six years
for y = 1:6
    
    % Go through all the grids and allocate their tonnage catch to the reefs inside them
    for g = 1:size(SiteCatch,1)
        
        % Don't bother if there was no catch in this cell
        if SiteCatch(g,y) > 0
            
            % Which centroids are inside this site polygon?
            F = find(inpolygon(SevCentroid(:,1),SevCentroid(:,2),SitePolygon(g,:,1),SitePolygon(g,:,2)));
            
            if isempty(F) == 1
                
                % We need to allocate this catch to a close reef if there is one
                F = find(pdist2(SevCentroid,[mean(SitePolygon(g,:,1)) mean(SitePolygon(g,:,2))]) < 0.2);
                
            end
            
            if isempty(F) == 0
                
                PropGridReefArea = FishedReefArea(F)'./sum(FishedReefArea(F));
                CatchInEachReef = PropGridReefArea.*SiteCatch(g,y);
                
                if sum(isnan(CatchInEachReef)) > 0
                    CatchInEachReef = 0;
                end
                
                ReefCatch_kilos(F,y) =  ReefCatch_kilos(F,y) + CatchInEachReef';
            end
        end
    end
end

save MAT_files/AllCatchOutputs
save MAT_files/crcb_domain_reserve_contribution ReefCatch_kilos SitePolygon -append
