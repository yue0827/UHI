function [ output, diff ] = calculateR2(X, Y )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[xa,xb]=size(X);
[ya,yb]=size(Y);

x=reshape(X,xa*xb,1);
y=reshape(Y,ya*yb,1);

whichstats = {'mse','rsquare'};
stats = regstats(y,x,'linear',whichstats);
output = stats.rsquare;

R = corrcoef(x,y,'rows','pairwise');

output2 = R(1,2);

diff = output - output2^2;




end

