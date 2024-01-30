clear all

% Load the reef outlines that Lou used to create the connectivity matrices
load MAT_files/MergedReefPolygons_All AllBuffer*

% Load the centroids that sev created
load MAT_files/crcb_domain_reserve_contribution NumReefs SevCentroid

% Allocate Sev's numbers to Lou's centroids
for rf = 1:length(SevCentroid)
    
    % Assuming it truly existed in Sev's dataset
    if SevCentroid(rf,1) ~= 0
        
        if mod(rf,250) == 0; disp(rf); end
        
        % What's the nearest point in the Buffered reefs?
        [~,nearest] = min(pdist2(SevCentroid(rf,:),AllBufferWithNumber(:,1:2)));
        nearest_lou_reef = AllBufferWithNumber(nearest(1),3);
        
        GiveSev_GetLou(rf,1) = nearest_lou_reef;
    end
end

% Now work out how many of Sev's reefs match each of Lou's
for rf = 1:1127 % This is how many reefs there are in Lou's model (1127) vs Sev's model (2296)
    
    F = find(GiveSev_GetLou == rf);
    
    GiveLou_GetSev{rf} = F;
    NumSev_perLou(rf,1) = length(F);
    
end

save MAT_files/crcb_domain_reserve_contribution Give* NumSev_perLou -append
