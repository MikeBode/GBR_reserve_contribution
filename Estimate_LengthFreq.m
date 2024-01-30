clear all

% This function creates length frequency distributions for each of the reefs in the system, based on 
% nearby observed data (in time and space), and the biomass estimated for each reef.

% Load the data on what fraction of each length class are mature, and are producing eggs (e.g., mature and still female)
load MAT_files/crcb_domain_reserve_contribution FractionReproducing FractionMature

% ============ Extract the data from the excel spreadsheet ================
[D,T] = xlsread('InputDatasets/Coral trout density distribution.xlsx');

% Cut off the headers
ForkLengthVec = D(1,5:end);
MassVec = 0.008.*(ForkLengthVec).^3.2; % Mass in grams for an individual in each length class
SSBMVec = MassVec.*FractionReproducing; % Spawning stock biomass for an individual in each length class
D = D(2:end,:); T = T(2:end,:);

% What are the unique reefs?
UniqueReefs = unique(T(:,4));
NumSampledReefs = length(UniqueReefs);

% Split the years between 2009 and 2014
YearVec = [2011:2013]; NumYears = length(YearVec);

% Go through all the sampled reefs
NTR_count = 1;
for sr = 1:NumSampledReefs
    
    % Which rows correspond to this reef and are NTRs?
    F = find(strcmp(T(:,4),UniqueReefs{sr}) & strcmp(T(:,2),'NTR'));
    
    % If some of these reefs are NTRs
    if isempty(F) == 0
        
        % What's the centroid of this sampled reef?
        SampledReefCentroid_NTR(NTR_count,:) = [D(F(1),4) D(F(1),3)];
        
        % Which years were sampled for this reef?
        SampledReef_Years_NTR{NTR_count} = D(F,1);
        
        for y = 1:length(YearVec)
            
            % What's the closest year to this in the dataset?
            [~,ClosestYear] = min(abs(SampledReef_Years_NTR{NTR_count}-YearVec(y)));
            
            % Collect the length-frequency distributions for each of these years (or the closest we can find)
            SampledReef_LengthFreq_NTR{NTR_count,YearVec(y)-(YearVec(1)-1)} = D(F(ClosestYear),5:24);
        end
        NTR_count = NTR_count + 1;
    end
end

% FISHED reefs
FISHED_count = 1;
for sr = 1:NumSampledReefs
    
    % Which rows correspond to this reef and are NTRs?
    F = find(strcmp(T(:,4),UniqueReefs{sr}) & strcmp(T(:,2),'FISHED'));
    
    if isempty(F) == 0
        
        % What's the centroid of this sampled reef?
        SampledReefCentroid_FISHED(FISHED_count,:) = [D(F(1),4) D(F(1),3)];
        
        % Which years were sampled for this reef?
        SampledReef_Years_FISHED{FISHED_count} = D(F,1);
        
        for y = 1:length(YearVec)
            
            % What's the closest year to this in the dataset?
            [~,ClosestYear] = min(abs(SampledReef_Years_FISHED{FISHED_count}-YearVec(y)));
            
            % Collect the length-frequency distributions for each of these years (or the closest we can find)
            SampledReef_LengthFreq_FISHED{FISHED_count,YearVec(y)-(YearVec(1)-1)} = D(F(ClosestYear),5:24);
        end
        FISHED_count = FISHED_count + 1;
    end
end

% ============ Interpolate the data to the unsampled reefs ================
load MAT_files/crcb_domain_reserve_contribution SevCentroid SevProtected
NumReefs = size(SevCentroid,1);

% Spatial decay rate. Mellin et al. 2010 (Fig 2) find that autocorrelation decays over 
% a scale of about 200  km.
d = 0.015; 

% Go through the reefs
for r = 1:NumReefs
    
    % Where is this reef?
    ThisReefCentroid = SevCentroid(r,:);
    
    % Is it protected?
    ThisProtected = SevProtected(r);
        
    % Calculate the distance to all sampled NTR & FISHED reefs and use them to weight the sampled reefs' contribution
    WeightVec_NTR    = exp(-d.*110.*pdist2(ThisReefCentroid,SampledReefCentroid_NTR));
    WeightVec_FISHED = exp(-d.*110.*pdist2(ThisReefCentroid,SampledReefCentroid_FISHED));
    WeightVec_NTR    = ThisProtected.*WeightVec_NTR./sum(WeightVec_NTR);
    WeightVec_FISHED = (1-ThisProtected).*WeightVec_FISHED./sum(WeightVec_FISHED);
    
    % Aggregated all the weighted contributions for each year
    for y = 1:length(YearVec)
        ThisLengthFreqVec = zeros(1,20);
        
        for i = 1:length(WeightVec_NTR) % NTR
            ThisLengthFreqVec = ThisLengthFreqVec + WeightVec_NTR(i).*SampledReef_LengthFreq_NTR{i,y};
        end
        for i = 1:length(WeightVec_FISHED) % FISHED
            ThisLengthFreqVec = ThisLengthFreqVec + WeightVec_FISHED(i).*SampledReef_LengthFreq_FISHED{i,y};
        end
        LengthFreq_interp{r,y} = ThisLengthFreqVec;
    end
end

save MAT_files/crcb_domain_reserve_contribution MassVec Fraction* SSBMVec Fork* SSBMVec LengthFreq_interp YearVec -append




