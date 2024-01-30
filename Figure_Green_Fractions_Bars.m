clear all

load MAT_files/Outputs *Biomass_density *TEP *TEP_density GSERF GreenTo* *CatchTotal Green_Biomass Blue_Biomass

% Initialise the figure, colours, etc.
figure(1), clf; set(gcf,'color','w')
subplot('position',[0.3 0.02 0.7 0.96]); hold on
GN = [0 0.7 0]; GNL = [0 0.4 0];
BL = [0.5 0.5 1]; BLL = [0 0 0.6];
d = 6;
Xt = -30;
FS = 13;

Y = d; 

%% Habitat results
Y = Y-d;
Inflate = 0.30;%GreenFraction_Habitat_Area;
Pb = patch((1-Inflate)*[0 100 100 0],Y+[0 0 -1 -1],BL);
Pg = patch(Inflate.*[0 100 100 0],Y+[0 0 -1 -1]-2,GN);
set(Pg,'edgecolor','none','facealpha',0.75)
set(Pb,'edgecolor','none','facealpha',0.75)
text(Xt,Y-1,'Coral trout','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(Xt,Y-2,'habitat','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(5+(1-Inflate)*100,Y-0.5,[num2str(round(100-Inflate*100)) '\%'],'interpreter','latex','fontsize',FS,'color',BLL)
text(5+Inflate*100,Y-2.5,[num2str(round(Inflate*100)) '\%'],'interpreter','latex','fontsize',FS,'color',GNL)

%% Biomass density and biomass results
% Total biomass density is in g/250m^2. To convert to kg/ha, we need to divide by 1000, divide by 250, and multiply by 10,000
% In sev's modelled data, the median biomass density is 20 kg/ha, the mean is 25 kg/ha
Y = Y-d; 
INF = 10000/250/1000; SC = 5;
VECg = Green_Biomass_density.*INF;
VECb = Blue_Biomass_density .*INF;
Inflateg = mean(VECg); Qg = quantile(VECg,[0 1]);
Inflateb = mean(VECb); Qb = quantile(VECb,[0 1]);
Pb = patch(Inflateb.*SC*[0 1 1 0],Y+[0 0 -1 -1],BL);
Pg = patch(Inflateg.*SC*[0 1 1 0],Y+[0 0 -1 -1]-2,GN);
plot(SC*Qg,Y-2.5+[0 0],'color',GNL,'linewidth',2)
plot(SC*Qb,Y-0.5+[0 0],'color',BLL,'linewidth',2)
set(Pg,'edgecolor','none','facealpha',0.75)
set(Pb,'edgecolor','none','facealpha',0.75)
text(Xt,Y-1,'Biomass','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(Xt,Y-2,'density','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(5+Qb(2)*SC,Y-0.5,[num2str(Inflateb,3) ' kg ha$^{-1}$'],'interpreter','latex','fontsize',FS,'color',BLL)
text(5+Qg(2)*SC,Y-2.5,[num2str(Inflateg,3) ' kg ha$^{-1}$'],'interpreter','latex','fontsize',FS,'color',GNL)
BlueL = Inflateb*SC;

MN = mean(Green_Biomass_density./Blue_Biomass_density);
RN = [min(Green_Biomass_density./Blue_Biomass_density) max(Green_Biomass_density./Blue_Biomass_density)];
disp(['Mean green biomass density multiplier = ' num2str(MN)])
disp(['Range green biomass density multiplier = ' num2str(RN)])
disp('============')

MN = mean(Green_Biomass./(Blue_Biomass + Green_Biomass));
RN = [min(Green_Biomass./(Blue_Biomass + Green_Biomass)) max(Green_Biomass./(Blue_Biomass + Green_Biomass))];
disp(['Mean green biomass % = ' num2str(MN)])
disp(['Range green biomass % = ' num2str(RN)])
disp('============')

%% Egg production results
Y = Y-d; 
VECg = Green_TEP;
VECb = Blue_TEP;
INF = mean(VECb)./BlueL;
VECg = VECg./INF; VECb = VECb./INF;
Inflateg = mean(VECg); Qg = quantile(VECg,[0.16 0.84]);
Inflateb = mean(VECb); Qb = quantile(VECb,[0.16 0.84]);
Pb = patch(Inflateb.*[0 1 1 0],Y+[0 0 -1 -1],BL);
Pg = patch(Inflateg.*[0 1 1 0],Y+[0 0 -1 -1]-2,GN);
plot(Qg,Y-2.5+[0 0],'color',GNL,'linewidth',2)
plot(Qb,Y-0.5+[0 0],'color',BLL,'linewidth',2)
set(Pg,'edgecolor','none','facealpha',0.75)
set(Pb,'edgecolor','none','facealpha',0.75)
text(Xt,Y-1,'Total egg','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(Xt,Y-2,'production','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(2+Inflateb,Y+0.25,[num2str(round(mean(Blue_TEP)./1e12,2)) '$\times 10^{12}$ eggs'],'interpreter','latex','fontsize',FS,'color',BLL)
text(2+Inflateg,Y-3.5,[num2str(round(mean(Green_TEP)./1e12,2)) '$\times 10^{12}$ eggs'],'interpreter','latex','fontsize',FS,'color',GNL)

MN = mean(Green_TEP_density./Blue_TEP_density);
RN = [min(Green_TEP_density./Blue_TEP_density) max(Green_TEP_density./Blue_TEP_density)];
disp(['Mean green biomass density multiplier = ' num2str(MN)])
disp(['Range green biomass density multiplier = ' num2str(RN)])
disp('============')

MN = mean(Green_TEP./(Blue_TEP + Green_TEP));
RN = [min(Green_TEP./(Green_TEP+Blue_TEP)) max(Green_TEP./(Green_TEP+Blue_TEP))];
disp(['Mean green TEP multiplier = ' num2str(MN)])
disp(['Range green TEP multiplier = ' num2str(RN)])
disp('============')

%% Total larval supply
Y = Y-d;
VECg = mean(GSERF,2);
VECb = 1-mean(GSERF,2);
Inflateg = mean(VECg); Qg = quantile(VECg,[0 1]);
Inflateb = mean(VECb); Qb = quantile(VECb,[0 1]);
Pb = patch(Inflateb.*[0 100 100 0],Y+[0 0 -1 -1],BL);
Pg = patch(Inflateg.*[0 100 100 0],Y+[0 0 -1 -1]-2,GN);
plot(100*Qg,Y-2.5+[0 0],'color',GNL,'linewidth',2)
plot(100*Qb,Y-0.5+[0 0],'color',BLL,'linewidth',2)
set(Pg,'edgecolor','none','facealpha',0.75)
set(Pb,'edgecolor','none','facealpha',0.75)
text(Xt,Y-0.5,'Source of','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(Xt,Y-1.5,'total larval','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(Xt,Y-2.5,'supply','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(5+Qb(2)*100,Y-0.5,[num2str(round(Inflateb*100)) '\%'],'interpreter','latex','fontsize',FS,'color',BLL)
text(5+Qg(2)*100,Y-2.5,[num2str(round(Inflateg*100)) '\%'],'interpreter','latex','fontsize',FS,'color',BLL)
% text(5+Qb(2)*100,Y-0.5,[num2str(round(Inflateb*100)) '\% [' num2str(round(Qb(1)*100)) '-' num2str(round(Qb(2)*100)) '\%]'],'interpreter','latex','fontsize',FS,'color',BLL)
% text(5+Qg(2)*100,Y-2.5,[num2str(round(Inflateg*100)) '\% [' num2str(round(Qg(1)*100)) '-' num2str(round(Qg(2)*100)) '\%]'],'interpreter','latex','fontsize',FS,'color',BLL)

MN = mean(mean(GSERF,2));
RN = [min(mean(GSERF,2)) max(mean(GSERF,2))];
disp(['Mean green larval supply % = ' num2str(MN)])
disp(['Range green larval supply % = ' num2str(RN)])
disp('============')

%% Larval supply to reserves
Y = Y-d;
VECg = GreenToGreen_Fraction;
VECb = 1-GreenToGreen_Fraction;
Inflateg = mean(VECg); Qg = quantile(VECg,[0 1]);
Inflateb = mean(VECb); Qb = quantile(VECb,[0 1]);
Pb = patch(Inflateb.*[0 100 100 0],Y+[0 0 -1 -1],BL);
Pg = patch(Inflateg.*[0 100 100 0],Y+[0 0 -1 -1]-2,GN);
plot(100*Qg,Y-2.5+[0 0],'color',GNL,'linewidth',2)
plot(100*Qb,Y-0.5+[0 0],'color',BLL,'linewidth',2)
set(Pg,'edgecolor','none','facealpha',0.75)
set(Pb,'edgecolor','none','facealpha',0.75)
text(Xt,Y-0.5,'Source of','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(Xt,Y-1.5,'larval supply to','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(Xt,Y-2.5,'marine reserves','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(5+Qb(2)*100,Y-0.5,[num2str(round(Inflateb*100)) '\%'],'interpreter','latex','fontsize',FS,'color',BLL)
text(5+Qg(2)*100,Y-2.5,[num2str(round(Inflateg*100)) '\%'],'interpreter','latex','fontsize',FS,'color',BLL)
% text(5+Qb(2)*100,Y-0.5,[num2str(round(Inflateb*100)) '\% [' num2str(round(Qb(1)*100)) '-' num2str(round(Qb(2)*100)) '\%]'],'interpreter','latex','fontsize',FS,'color',BLL)
% text(5+Qg(2)*100,Y-2.5,[num2str(round(Inflateg*100)) '\% [' num2str(round(Qg(1)*100)) '-' num2str(round(Qg(2)*100)) '\%]'],'interpreter','latex','fontsize',FS,'color',BLL)

MN = mean(GreenToGreen_Fraction);
RN = [min(GreenToGreen_Fraction) max(GreenToGreen_Fraction)];
disp(['Mean green to green larval supply % = ' num2str(MN)])
disp(['Range green to green larval supply % = ' num2str(RN)])
disp('============')

%% Larval supply to fished areas
Y = Y-d;
VECg = GreenToBlue_Fraction;
VECb = 1-GreenToBlue_Fraction;
Inflateg = mean(VECg); Qg = quantile(VECg,[0 1]);
Inflateb = mean(VECb); Qb = quantile(VECb,[0 1]);
Pb = patch(Inflateb.*[0 100 100 0],Y+[0 0 -1 -1],BL);
Pg = patch(Inflateg.*[0 100 100 0],Y+[0 0 -1 -1]-2,GN);
plot(100*Qg,Y-2.5+[0 0],'color',GNL,'linewidth',2)
plot(100*Qb,Y-0.5+[0 0],'color',BLL,'linewidth',2)
set(Pg,'edgecolor','none','facealpha',0.75)
set(Pb,'edgecolor','none','facealpha',0.75)
text(Xt,Y-0.5,'Source of','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(Xt,Y-1.5,'larval supply','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(Xt,Y-2.5,'to fished reefs','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(5+Qb(2)*100,Y-0.5,[num2str(round(Inflateb*100)) '\%'],'interpreter','latex','fontsize',FS,'color',BLL)
text(5+Qg(2)*100,Y-2.5,[num2str(round(Inflateg*100)) '\%]'],'interpreter','latex','fontsize',FS,'color',BLL)
% text(5+Qb(2)*100,Y-0.5,[num2str(round(Inflateb*100)) '\% [' num2str(round(Qb(1)*100)) '-' num2str(round(Qb(2)*100)) '\%]'],'interpreter','latex','fontsize',FS,'color',BLL)
% text(5+Qg(2)*100,Y-2.5,[num2str(round(Inflateg*100)) '\% [' num2str(round(Qg(1)*100)) '-' num2str(round(Qg(2)*100)) '\%]'],'interpreter','latex','fontsize',FS,'color',BLL)

MN = mean(GreenToBlue_Fraction);
RN = [min(GreenToBlue_Fraction) max(GreenToBlue_Fraction)];
disp(['Mean green to blue larval supply % = ' num2str(MN)])
disp(['Range green to blue larval supply % = ' num2str(RN)])
disp('============')

%% Green catch proportion
Y = Y-d;
VECg = GreenCatchTotal./(BlueCatchTotal+GreenCatchTotal);
VECb = BlueCatchTotal./(BlueCatchTotal+GreenCatchTotal);
Inflateg = mean(VECg); Qg = quantile(VECg,[0 1]);
Inflateb = mean(VECb); Qb = quantile(VECb,[0 1]);
Pb = patch(Inflateb.*[0 100 100 0],Y+[0 0 -1 -1],BL);
Pg = patch(Inflateg.*[0 100 100 0],Y+[0 0 -1 -1]-2,GN);
plot(100*Qg,Y-2.5+[0 0],'color',GNL,'linewidth',2)
plot(100*Qb,Y-0.5+[0 0],'color',BLL,'linewidth',2)
set(Pg,'edgecolor','none','facealpha',0.75)
set(Pb,'edgecolor','none','facealpha',0.75)
text(Xt,Y-0.5,'Source of','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(Xt,Y-1.5,'commercial','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(Xt,Y-2.5,'catch','interpreter','latex','horizontalalignment','center','fontsize',FS)
text(5+Qb(2)*100,Y-0.5,[num2str(round(Inflateb*100)) '\%'],'interpreter','latex','fontsize',FS,'color',BLL)
text(5+Qg(2)*100,Y-2.5,[num2str(round(Inflateg*100)) '\%'],'interpreter','latex','fontsize',FS,'color',BLL)
% text(5+Qb(2)*100,Y-0.5,[num2str(round(Inflateb*100)) '\% [' num2str(round(Qb(1)*100)) '-' num2str(round(Qb(2)*100)) '\%]'],'interpreter','latex','fontsize',FS,'color',BLL)
% text(5+Qg(2)*100,Y-2.5,[num2str(round(Inflateg*100)) '\% [' num2str(round(Qg(1)*100)) '-' num2str(round(Qg(2)*100)) '\%]'],'interpreter','latex','fontsize',FS,'color',BLL)

MN = mean(GreenCatchTotal./(BlueCatchTotal+GreenCatchTotal));
RN = [min((GreenCatchTotal./(BlueCatchTotal+GreenCatchTotal))) max((GreenCatchTotal./(BlueCatchTotal+GreenCatchTotal)))];
disp(['Mean green catch % = ' num2str(MN)])
disp(['Range green catch % = ' num2str(RN)])
disp('============')

axis off

xlim([0 140])
YL = ylim;
ylim([YL(1)-1 3])

set(gca,'ytick',[])
