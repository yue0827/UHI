function [ output1,output2] = linearregression(X, Y )


[xa,xb]=size(X);
[ya,yb]=size(Y);

x=reshape(X,xa*xb,1);
y=reshape(Y,ya*yb,1);

X = [ones(size(x)) x];
[output1,output2_temp] = regress(y,X);

output2=abs(output2_temp(:,1)-output2_temp(:,2))/2;

end

