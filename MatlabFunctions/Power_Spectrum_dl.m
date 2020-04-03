function [f_we,Eu_we,Cor_u]=Power_Spectrum_dl(u_tur,fs)

% Computes and returns the Fourier Spectra
%--------------------------------------------------------------------------


nanu = isnan(u_tur); % remove NaNs, added by danli
u_tur(nanu) = nanmean(u_tur);

up=u_tur;
wid=1;                      %--- Number of windows to smooth data
n1=floor(length(up)/wid);
n2=floor(log2(n1));
%----------- Compute Fourier spectral density (using FFT)
wind_we=2^n2; f_we=[]; Eu_we=[]; Ew_we=[];
[Eu_we,f_we]=pwelch(up,wind_we,[],[],fs,'onesided');
df=f_we(2)-f_we(1);
%----------- Checks the energy loss due to windowing and averaging for FFT
Cor_u=mean(up.^2)/(sum(Eu_we.*df));
Eu_we=Eu_we/mean(up.^2);  % modified by danli, simply a normalization
end

