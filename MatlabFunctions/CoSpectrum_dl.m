function [f_we,Cxy_we,Cor_u]=CoSpectrum_dl(y1,y2,fs)

% Computes and returns the Fourier Spectra
%--------------------------------------------------------------------------
nany1 = isnan(y1); % remove NaNs
nany2 = isnan(y2);
% y1(nany1|nany2) = [];
% y2(nany1|nany2) = [];
y1(nany1|nany2) = nanmean(y1);
y2(nany1|nany2) = nanmean(y2);


up=y1;
wid=1;                      %--- Number of windows to smooth data
n1=floor(length(up)/wid);
n2=floor(log2(n1));
%----------- Compute Fourier spectral density (using FFT)
wind_we=2^n2; f_we=[]; Cxy_we=[]; 
[Cxy_we,f_we]=cpsd(y1,y2,wind_we,[],[],fs,'onesided');
df=f_we(2)-f_we(1);
%----------- Checks the energy loss due to windowing and averaging for FFT
Cor_u=mean(y1.*y2)/(sum(Cxy_we.*df));
Cxy_we=real(Cxy_we)/mean(y1.*y2);  % modified by danli, simply a normalization
end

