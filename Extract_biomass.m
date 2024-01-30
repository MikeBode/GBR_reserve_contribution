clear all
warning off

% Load the biomass data as a Matlab table
load 'InputDatasets/EnsembleModelResults_1984-2019_ZONEREEF_SZDY_2' Tmodelled

% How many reefs are there in this definition of the GBR?
NumReefs = max(Tmodelled{:,1});

% Go through the reefs one-by-one
for rf = 1:NumReefs

    if mod(rf,250) == 1; disp(rf); end
    
    % Find this reef number in the table (from multiple years)
    F = find(table2array(Tmodelled(:,1))==rf);

    % If you can find it, save the relevant data from each year
    if isempty(F) == 0
        
        % Extract the latitude (Y component) and longitude (X component)
        LAT_COL = find(strcmp(Tmodelled.Properties.VariableNames,'LAT'));
        LON_COL = find(strcmp(Tmodelled.Properties.VariableNames,'LONG'));
        SevCentroid(rf,:) = [Tmodelled{F(1),LON_COL} Tmodelled{F(1),LAT_COL}];
        
        % Determine whether this reef is protected or not (this will be the primary definition of MPA)
        ZONE_COL = find(strcmp(Tmodelled.Properties.VariableNames,'ZONE'));
        SevProtected(rf,1) = Tmodelled{F(1),ZONE_COL};
        
        % Extract the reef area from the table
        AREA_COL = find(strcmp(Tmodelled.Properties.VariableNames,'ReefArea'));
        SevReefArea(rf,1) = Tmodelled{F(1),AREA_COL};
        
        % Extract the reef outline from the table
        OUTX_COL = find(strcmp(Tmodelled.Properties.VariableNames,'X'));
        OUTY_COL = find(strcmp(Tmodelled.Properties.VariableNames,'Y'));
        SevReefOutline{rf,1} = [Tmodelled{F(1),OUTX_COL}{:}; Tmodelled{F(1),OUTY_COL}{:}];
        
        % Calculate the perimeter of Sev's polygon
        polyin = polyshape([Tmodelled{F(1),OUTX_COL}{:}; Tmodelled{F(1),OUTY_COL}{:}]');
        SevReefPerimeter(rf,1) = perimeter(polyin);
        
        % What years have data?
        YEAR_COL = find(strcmp(Tmodelled.Properties.VariableNames,'YEAR'));
        YRS = Tmodelled{F,YEAR_COL};

        % We store a value for each year in the dataset. If we can't find the right year, we substitute with the closest
        % year that data is available.
        BIOMASSDENSITY_COL = find(strcmp(Tmodelled.Properties.VariableNames,'BIOMASS'));
        for yr = 2011:2013
            
            % Grab the nearest year
            [~,FF] = min(abs(YRS-yr));
            
            % Total biomass is area * density (converted from g/250m^2 to total kg)
            SevBiomass(rf,yr-2010) = Tmodelled{F(FF),AREA_COL} ... % Area in square metres
                                     .*Tmodelled{F(FF),BIOMASSDENSITY_COL}... % Biomass density in g/250m^2 
                                     *250/1000; 
            
            % Total biomass density in g/250m^2
            SevBiomassDensity(rf,yr-2010) = Tmodelled{F(FF),BIOMASSDENSITY_COL}; 
            
        end
    end
    
end

clear Tmodelled
save MAT_files/crcb_domain_reserve_contribution
















