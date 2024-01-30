clear all

load MAT_files/crcb_domain_reserve_contribution SevCentroid
load ReefRaw ReefRaw

% Plot the GBR reefs 
figure(1), clf
axes('position',[0 0 1 1]), hold on
set(gca,'xtick',[],'ytick',[])
plot(ReefRaw(:,1),ReefRaw(:,2),'color',[0 0.6 0])
xlim([141.6081  158]); XL = xlim;
ylim([-24.5  -10.3165]); YL = ylim;
ScaleRatio = (YL(2)-YL(1))./(XL(2)-XL(1));

% Plot the spawning times for the Southern GBR values 
axes('position',[0.75 0.15 0.2 0.1]), hold on
load('/Users/bodem/Dropbox/Biophysical_vs_empirical/Matlab_3/Data/Spawning_density_function.mat')
G = 17; X = X(G-11:G); 
H = H(G-11:G) + H(G+1:G+12) + H(G+13:G+24) + H(G+25:G+36); % First month is June
S = [8:12 1:7]; X = X(S); H = H(S);
bar(H,0.6)
title('Southern')
set(gca,'xtick',[1:2:12],'xticklabel',{'J';'M';'M';'J';'S';'N'})
H = H./sum(H);
Southern_SpawningProportion = H; 

% Plot the spawning times for the Central GBR values
axes('position',[0.45 0.5 0.2 0.1]), hold on
D1 = xlsread('/Users/bodem/Library/CloudStorage/GoogleDrive-mbode.web@gmail.com/My Drive/Reserve_Contribution/Data/CoralTroutSpawningFreq/Samoilys_1997_1991spawning.xlsx');
D1 = [[0 D1(1,2)]; D1; [12 D1(end,2)]];
D2 = xlsread('/Users/bodem/Library/CloudStorage/GoogleDrive-mbode.web@gmail.com/My Drive/Reserve_Contribution/Data/CoralTroutSpawningFreq/Samoilys_1997_1992spawning.xlsx');
D2 = [[0 D2(1,2)]; D2; [12 D2(end,2)]];
D3 = xlsread('/Users/bodem/Library/CloudStorage/GoogleDrive-mbode.web@gmail.com/My Drive/Reserve_Contribution/Data/CoralTroutSpawningFreq/Samoilys_1997_1993spawning.xlsx');
D3 = [[0 D3(1,2)]; D3; [12 D3(end,2)]];

spawn_month = linspace(0,12,365);
d1 = max(0,interp1(D1(:,1),D1(:,2),spawn_month));
d2 = max(0,interp1(D2(:,1),D2(:,2),spawn_month));
d3 = max(0,interp1(D3(:,1),D3(:,2),spawn_month));

x = ceil([0:12]*30.4);
for i = 1:12;
    h1(i) = sum(d1(x(i)+1:x(i+1)));
    h2(i) = sum(d2(x(i)+1:x(i+1)));
    h3(i) = sum(d3(x(i)+1:x(i+1)));
end
h = h1+h2+h3; h = h./sum(h);
h = h([8:12 1:7]);
bar(h,0.6)
title('Central')
set(gca,'xtick',[1:2:12],'xticklabel',{'J';'M';'M';'J';'S';'N'})
Northern_SpawningProportion = h; 

% Plot the spawning times for the Northern GBR values
axes('position',[0.25 0.8 0.2 0.1]), hold on
bar(h,0.6)
title('Northern')
set(gca,'xtick',[1:2:12],'xticklabel',{'J';'M';'M';'J';'S';'N'})

C_Reef = [146.20 -17.07];
S_Reef = [151.72 -23.00];

% Save the values for each reef in the dataset
for r = 1:length(SevCentroid)
    dist_c = pdist2(SevCentroid(r,:),C_Reef);
    dist_s = pdist2(SevCentroid(r,:),S_Reef);
    
    if SevCentroid(r,2) > C_Reef(2) % We're north of the central reef
        Ratio = 1;
    else
        Ratio = max(0,min(1,1 - dist_c./(dist_c + dist_s))); % This is the ratio belonging to the northern/central reef
    end
    
    for mth = 1:12
        RelativeOutput_month_reef(r,mth) = Ratio*Northern_SpawningProportion(mth) + (1-Ratio)*Southern_SpawningProportion(mth); 
    end
end

save MAT_files/SpawningProportionMonths *SpawningProportion RelativeOutput_month_reef
d






