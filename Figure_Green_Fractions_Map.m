clear all; clc
load MAT_files/crcb_domain_reserve_contribution
load MAT_files/ReleaseDateList
load MAT_files/GreenOutline
load MAT_files/Outputs GSERF Green* Blue*
% load MAT_files/AllCatchOutputs GridCatch S
load MAT_files/GridPolygon
load MAT_files/ReefRaw

figure(1), clf; 
set(gcf,'color','w'); FS = 15; MS = 16;
FA = 1; LandCol = 0.8.*ones(1,3); 
subplot('position',[0 0 1 1]); hold on, axis off; 

% Set up the colour scheme
M1 = [0 0.85]; M2 = [0 0.95];
CCLL = [[linspace(M1(1),M1(2),30)' linspace(M1(1),M1(2),30)' ones(30,1)];...
        [linspace(M2(2),M2(1),70)' ones(70,1) linspace(M2(2),M2(1),70)']];
CCLL = CCLL./1.2;

% Set up the colour scheme
CCLL = [zeros(100,1) linspace(0.2,1,100)' linspace(0.8,0,100)'];
CCLL = CCLL.^0.75;

GSERF = mean(GSERF);
for i = 1:NumReefs
    if GSERF(i) ~= 0
        plot(SevCentroid(i,1),SevCentroid(i,2),'.','markersize',MS,'color',CCLL(ceil(GSERF(i)*99+1),:))
    end
end
xlim([141.79  153.43]); ylim([-24.77  -10.33])
colormap(CCLL)
h = colorbar;
set(get(h,'label'),'string','Recruitment sourced from reserves (\%)','interpreter','latex','Rotation',90,'fontsize',FS+3);
set(h,'ytick',[0 30 50 75 100],'position',[0.125 0.06 0.03 0.6])
caxis([0 100])

LC = [145  -23];
plot([LC(1)-0.5/1.1 LC(1)+0.5/1.1],LC(2).*[1 1]-0.7,'k','linewidth',1.5)
text(LC(1),LC(2)-0.7-0.3,'100 km','horizontalalignment','center','fontsize',FS-2)

CCCLLL = [0.5 0 0];
plot(146.8472,-19.2768,'.','color',CCCLLL,'markersize',24)
plot(145.7623,-16.9664,'.','color',CCCLLL,'markersize',24)
text(146.8472-0.2,-19.2768-0.2,'T','fontsize',FS-1,'color',CCCLLL)
text(145.7623-0.2,-16.9664-0.2,'C','fontsize',FS-1,'color',CCCLLL)

%% INSET a histogram of the Green Recruitment proportion on each reef across the years
load MAT_files/Outputs GSERF
CL = get(gca,'colororder');
axes('position',[0.525 0.76 0.375 0.15]); hold on; box on
P = patch([0 100 100 0],[0 0 100 100],1-(1-CL(1,:))./2);

X = 100*linspace(0,1,size(GSERF,2));
SSG = 100*full(sort(sum(GSERF)./24,'descend'));
B = bar(X,SSG,1);
set(B,'edgecolor','none','facealpha',1,'facecolor',1-(1-CL(5,:))./2)

[~,F1] = min(abs(SSG-30));
plot([0 X(F1) X(F1)],[30 30 0],'--','linewidth',1.5,'color',[0 0.5 0])
[~,F2] = min(abs(SSG-50));
plot([0 X(F2) X(F2)],[50 50 0],'--','linewidth',1.5,'color',[0 0.5 0])
set(gca,'layer','top','ytick',[0 30 50 75 100],'xtick',sort(round([0 25 X(F2) X(F1) 75]),'ascend'))

text(95,85,'Inset (a)','fontsize',FS,'interpreter','latex','horizontalalignment','right')
xlabel('All reefs (\%)','fontsize',FS,'interpreter','latex')
ylabel({'Recruitment';'from reserves (\%)'},'fontsize',FS,'interpreter','latex')

%% INSET a histogram of the catch on each reef across the years

axes('position',[0.525 0.535 0.375 0.15]); 
hold on; box on;
CL = get(gca,'colororder');
GCF = 100*GreenCatchEachReef_tonnes./(GreenCatchEachReef_tonnes+BlueCatchEachReef_tonnes);
GCF(isnan(GCF)) = [];
GCF = sort(GCF,'descend');
X = 100*linspace(0,1,length(GCF));

P = patch([0 100 100 0],100*[0 0 1 1],1-(1-CL(1,:))./2);
B = bar(X,GCF,1);
set(B,'edgecolor','none','facealpha',1,'facecolor',1-(1-CL(5,:))./2)

[~,F1] = min(abs(GCF-30));
plot([0 X(F1) X(F1)],[30 30 0],'--','linewidth',1.5,'color',[0 0.5 0])
[~,F2] = min(abs(GCF-50));
plot([0 X(F2) X(F2)],[50 50 0],'--','linewidth',1.5,'color',[0 0.5 0])
text(95,85,'Inset (b)','fontsize',FS,'interpreter','latex','horizontalalignment','right')
xlabel('Fished reefs (\%)','fontsize',FS,'interpreter','latex')
ylabel({'Catch from ';'reserves (\%)'},'fontsize',FS,'interpreter','latex')
set(gca,'layer','top','ytick',[0 30 50 75 100],'xtick',sort(round([0 25 X(F2) X(F1) 100])))






