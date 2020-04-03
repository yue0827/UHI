function [output1,output2] = meanandstd(X)


[xa,xb]=size(X);

data = X;

data(abs(data)>5)=NaN;

x=reshape(data,xa*xb,1);


[output1] = nanmean(x);
[output2] = nanstd(x);


end

