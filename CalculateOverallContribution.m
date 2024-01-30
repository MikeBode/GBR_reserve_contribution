function CalculateOverallContribution()

load MAT_files/crcb_domain_reserve_contribution
load MAT_files/ReleaseDateList
load MAT_files/ConnectivityMatrices_2296 FullConnMat_m018
load MAT_files/AllCatchOutputs

Habitat_basis = 'Area';
AvTransport = zeros(NumReefs);

YearVec = [2011:2013];
for LL = 1:24 % Go through the different release dates

    disp(['Analysing the spawning event around ' ReleaseDates(LL,:)])
    
    % Which catch year is this release date in?
    DT = ReleaseYear(LL) - 2010;

    % Which LTMP/Inshore year is this release date in?
    F_n = find(YearVec == ReleaseYear(LL));

    % What proportion of coral trout habitat is green (AREA)?
    GreenFraction_Habitat_Area = sum(SevReefArea.*SevProtected)./sum(SevReefArea);
    disp([num2str(ceil(100*GreenFraction_Habitat_Area)) '% of coral trout habitat (AREA) is green (green habitat fraction)'])

    % What proportion of coral trout habitat is green (PERIMETER)?
    GreenFraction_Habitat_Peri = sum(SevReefPerimeter.*SevProtected)./sum(SevReefPerimeter);
    disp([num2str(ceil(100*GreenFraction_Habitat_Peri)) '% of coral trout habitat (PERIMETER) is green (green habitat fraction)'])
    eval(['GreenFraction_Habitat = GreenFraction_Habitat_' Habitat_basis ';'])

    % What proportion of the total biomass is green?
    GreenFraction_Biomass(LL) = sum(SevBiomass(:,DT).*SevProtected)./sum(SevBiomass(:,DT));
    disp([num2str(ceil(100*GreenFraction_Biomass(LL))) '% of coral trout biomass is green (green abundance fraction)'])

    % What is the green biomass
    Green_Biomass(LL) = sum(SevBiomass(:,DT).*SevProtected);
    Blue_Biomass(LL) = sum(SevBiomass(:,DT).*(1-SevProtected));
    Green_Biomass_density(LL) = sum(SevBiomass(:,DT).*SevProtected)./sum(SevReefArea.*SevProtected);
    Blue_Biomass_density(LL)  = sum(SevBiomass(:,DT).*(1-SevProtected))./sum(SevReefArea.*(1-SevProtected));

    % What proportion of the total SSB is green?
    GreenFraction_SSB(LL) = sum(SSB(:,DT).*SevProtected)./sum(SSB(:,DT));
    disp([num2str(ceil(100*GreenFraction_SSB(LL))) '% of coral trout SSB is green (green SSB)'])

    % What proportion of the total egg production is green?
    GreenFraction_TEP(LL) = sum(TEP(:,LL).*SevProtected)./sum(TEP(:,LL));
    disp([num2str(ceil(100*GreenFraction_TEP(LL))) '% of egg production occurs in the green zones (green egg fraction)'])

    % What is the total egg production?
    Green_TEP(LL) = sum(TEP(:,LL).*SevProtected);
    Blue_TEP(LL)  = sum(TEP(:,LL).*(1-SevProtected));
    Green_TEP_density(LL) = sum(TEP(:,LL).*SevProtected)./sum(SevReefArea.*SevProtected);
    Blue_TEP_density(LL)  = sum(TEP(:,LL).*(1-SevProtected))./sum(SevReefArea.*(1-SevProtected));

    % Extract the relevant connectivity matrix
    CM = full(FullConnMat_m018{LL});

    % Calculate the transport matrix
    Transport = repmat(TEP(:,LL),1,NumReefs).*CM;
    Transport(isnan(Transport)) = 0;
    AvTransport = AvTransport + Transport;

    TotalTransport = sum(sum(Transport));
    TotalTransport_AllToGreen   = sum(sum(Transport.*repmat(SevProtected',NumReefs,1)));
    TotalTransport_AllToBlue    = sum(sum(Transport.*repmat(1-SevProtected',NumReefs,1)));
    TotalTransport_GreenToAll   = sum(sum(Transport.*repmat(SevProtected,1,NumReefs)));
    TotalTransport_BlueToAll    = sum(sum(Transport.*repmat(1-SevProtected,1,NumReefs)));

    TotalTransport_GreenToBlue  = sum(sum(Transport...
        .*repmat(SevProtected,1,NumReefs)...
        .*repmat(1-SevProtected',NumReefs,1)));

    TotalTransport_GreenToGreen = sum(sum(Transport...
        .*repmat(SevProtected,1,NumReefs)...
        .*repmat(SevProtected',NumReefs,1)));

    % What fraction of the settlement onto blue reefs came from green reefs?
    GreenToBlue_Fraction(LL) = TotalTransport_GreenToBlue./TotalTransport_AllToBlue;
    disp([num2str(ceil(100*GreenToBlue_Fraction(LL))) '% of settlement on blue reefs comes from the green zones (green/blue settlement fraction)'])

    % What fraction of the settlement onto green reefs came from green reefs?
    GreenToGreen_Fraction(LL) = TotalTransport_GreenToGreen./TotalTransport_AllToGreen;
    disp([num2str(ceil(100*GreenToGreen_Fraction(LL))) '% of settlement on green reefs comes from the green zones (green/green settlement fraction)'])

    % Calculate the reserve contribution TO each reef
    TotalTransportToEachReef = sum(Transport);
    TotalGreenTransportToEachReef = sum(Transport.*repmat(SevProtected,1,NumReefs));
    GSERF(LL,:) = TotalGreenTransportToEachReef./TotalTransportToEachReef;
    GSERF(LL,isnan(GSERF(LL,:))) = 0;

    % We know the catch on each reef, so calculate the green catch proportion
    GreenCatchEachReef_tonnes(LL,:) = GSERF(LL,:)'.*ReefCatch_kilos(:,DT)/1000;
    BlueCatchEachReef_tonnes(LL,:) = (1-GSERF(LL,:)').*ReefCatch_kilos(:,DT)/1000;
    GreenCatchTotal_Fraction(LL) = sum(GreenCatchEachReef_tonnes(LL,:))./sum(ReefCatch_kilos(:,DT)/1000);
    disp([num2str(ceil(100*GreenCatchTotal_Fraction(LL))) '% of coral trout catch comes from the green zones'])

    GreenCatchTotal(LL) = sum(GreenCatchEachReef_tonnes(LL,:));
    BlueCatchTotal(LL) = sum(BlueCatchEachReef_tonnes(LL,:));

    % Define the green catch proportion by the gridsquare
    for g = 1:size(GridPolygon,1)
        % Which centroids are inside this gridsquare?
        F = find(inpolygon(SevCentroid(:,1),SevCentroid(:,2),GridPolygon(g,:,1),GridPolygon(g,:,2)));
        TotalCatchInThisPolygon = sum(ReefCatch_kilos(F,DT)/1000);
        GreenCatchInThisPolygon = sum(GreenCatchEachReef_tonnes(LL,F))/1000;
        if isempty(TotalCatchInThisPolygon) == 1; TotalCatchInThisPolygon = 0; end
        if isempty(GreenCatchInThisPolygon) == 1; GreenCatchInThisPolygon = 0; end
        GreenFractionPolygon(LL,g) = GreenCatchInThisPolygon./TotalCatchInThisPolygon;
    end

    % How much catch was produced (in tonnes) by each reef, green and blue
    CatchOutput(LL,:) = zeros(1,NumReefs);
    for r = 1:NumReefs
        % How many tonnes were caught on this reef?
        ThisReefCatch = ReefCatch_kilos(r,DT)/1000;

        if sum(Transport(:,r)) > 0
            % Who contributed to this reef?
            RelativeContributionToThisReef = Transport(:,r)./sum(Transport(:,r));

            CatchOutput(LL,:) = CatchOutput(LL,:) + RelativeContributionToThisReef'.*ThisReefCatch;
        end
    end
    disp('-=-=-=-=-=-=-=-=-=-=')

end

clear FullConnMat_m018 Reef* Sev* Transport UseFor* LengthF*
save MAT_files/Outputs











