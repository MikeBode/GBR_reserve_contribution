clear all
warning off

% The following function prepares the input datasets
% for analysis, ensuring that they're in the right
% format, contain the right information, and have the 
% right dimensions. They only need to be run once.

DoAnalyses = 0;
if DoAnalyses == 1

    % Initialise saved files
    save MAT_files/crcb_domain_reserve_contribution

    % First extract the biomass of each reef in the GBR
    Extract_biomass

    % Now extract the gridded catch data from QLD fisheries
    Extract_catch_data

    % Extract life history parameters for maturity and sex transition with age
    Extract_maturity_sex_age

    % Estimate the length frequency distributions for coral grouper at each site
    Estimate_LengthFreq

    % Estimate the distribution of spawning across the months for each reef
    Estimate_SpawningPeriod

    % Estimate the egg production at each reef
    Estimate_EggProduction

    % Ensure that the biomass dataset is harmonised with the connectivity dataset
    Lou_sev_crossreference
    Convert_connectivity_matrices_to_2296_definition

end

% This function integrates the input datasets above into 
% a series of predictions for each reef, in each year.
CalculateOverallContribution

% These two functions create the two main figures in the manuscript
Figure_Green_Fractions_Bars
Figure_Green_Fractions_Map





