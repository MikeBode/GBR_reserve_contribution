clear all

% We need to connect the connectivity matrices (which are a set of buffered polygons) to Sev's reef definition.

% Load the reef outlines used to create the connectivity matrices
load MAT_files/MergedReefPolygons_All AllBuffer*

% Load Sev's definitions of the reef centroids
load MAT_files/crcb_domain_reserve_contribution SevCentroid Give* NumSev_perLou SevReefOutline

% Load the list of the release dates
load MAT_files/ReleaseDateList ReleaseDates

% How many larvae were released from each reef?
load MAT_files/ReleasesFromEachReef

NumReefs = size(SevCentroid,1);

for LL = 1:24
    Err = 0;
    disp(ReleaseDates(LL,:))
    
    % Load the biophysical outputs
    eval(['load ''/Users/bodem/Library/CloudStorage/GoogleDrive-mbode.web@gmail.com/My Drive/Reserve_Contribution/Data/MatlabData/ConnMats/ConnMat_CoralTrout_pp_' ...
        ReleaseDates(LL,:) '_FullGBR'' ConnMat_m003 ']); ConnMat = ConnMat_m003;

    % Sev's biomass data contains a 2296 x 2296 connectivity matrix
    % Lou's connectivity data contains a 1127 x 1127 matrix. We need to go through
    % each of Sev's reefs, work out which of Lou's reefs they're closest to, and replicate that
    % row of Lou's connectivity matrix
    
    for ReefSource_Sev = 1:NumReefs % This is the source reef ID number according to Sev
        
        % This is the nearest reef in Lou's dataset to Sev's source reef location
        ReefSource_Lou = GiveSev_GetLou(ReefSource_Sev);
        
        if ReefSource_Lou ~= 0
            for ReefDest_Sev = 1:NumReefs % This is the destination reef ID number according to Sev
                
                % This is Sev's reef
                ReefDest_Lou = GiveSev_GetLou(ReefDest_Sev);
                
                if ReefDest_Lou ~= 0
                    TCM(ReefSource_Sev,ReefDest_Sev) = ...
                        ConnMat(ReefSource_Lou,ReefDest_Lou)./...
                        NumSev_perLou(ReefDest_Lou)./...
                        Num_releases_from_each_reef(ReefSource_Lou);
                    
                end
            end
        end
    end
    TCM(isinf(TCM)) = 0;
    FullConnMat_m018{LL} = sparse(TCM);
end

save MAT_files/ConnectivityMatrices_2296




















