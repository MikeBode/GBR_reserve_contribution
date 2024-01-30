function Estimate_EggProduction()

load MAT_files/crcb_domain_reserve_contribution Fraction* Fork* NumReefs Length* Sev* MassVec SSB*
load MAT_files/SpawningProportionMonths RelativeOutput_month_reef

% This is how many eggs are produced by each length-class (translated first to mass, then to eggs)
EggsByLengthVec   = FractionReproducing.*(0.73.*(0.008.*ForkLengthVec.^3.2).^1.6); % This is fit to the Carter data directly, plus Ferreira & Russ

load MAT_files/ReleaseDateList
for LL = 1:24
    Month_number = eval(ReleaseDates(LL,6:7));
    for rf = 1:NumReefs
        
        % For each reef, extract and normalise the length frequency distribution
        ThisLengthFreqVec = LengthFreq_interp{rf,ReleaseYear(LL)-2010};
        ThisLengthFreqVec = ThisLengthFreqVec./sum(ThisLengthFreqVec);
        
        % We know the total biomass on this reef this year
        ThisReefBiomass = SevBiomass(rf,ReleaseYear(LL)-2010);
        
        % We multiply the LFD by "multiplier" to give the number of individuals in each size class
        Multiplier = ThisReefBiomass./(sum(ThisLengthFreqVec.*MassVec));
        Population = Multiplier.*ThisLengthFreqVec; % This is the number of individuals in each length class
        
        % Egg production requires maturity and female
        TEP(rf,LL) = RelativeOutput_month_reef(rf,Month_number).*EggsByLengthVec*Population';
        SSB(rf,LL) = Population*SSBMVec';
        SevAbundance(rf,LL) = sum(Population);
    end
end

save MAT_files/crcb_domain_reserve_contribution TEP* SSB -append SevAbundance










