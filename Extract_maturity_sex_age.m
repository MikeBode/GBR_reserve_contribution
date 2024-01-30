clear all

% This function relates the length of a fish to its sex and the probability that it is reproductively mature.

% ============ Extract the data from the excel spreadsheet ================
[D,T] = xlsread('InputDatasets/Coral trout density distribution.xlsx');

% Cut off the headers
ForkLengthVec = D(1,5:end);

% Fork length vector
FL = linspace(0,80,100);

% Fraction mature
Mat = [...
0 0
24 0
30 0
32 0.75
36 0.95
40 1.0
50 1.0];

% Fraction male
Male = [...
0 0
24 0
32 0.025
36 0.05
40 0.18
44 0.20
48 0.25
52 0.50
56 0.75
60 1.00
70 1.00];

% Fished reefs
k = 1;
S = 32;
FMat   = 1./(1+exp(-k.*(FL-S))); % Fraction mature
FMat_i = 1./(1+exp(-k.*(Mat(:,1)-S))); % Fraction mature
FractionMature = 1./(1+exp(-k.*(ForkLengthVec-S)));
FractionReproducing = FractionMature;
SSD = sum((FMat_i - Mat(:,2)).^2);

save MAT_files/crcb_domain_reserve_contribution Fraction* *ork* -append





