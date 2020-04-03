function [Tca_diff_pdf,Tca_diff_cdf] = find_pdf_cdf(Tca_diff,x)

Tca_diff((isnan(Tca_diff)))=[];
Tca_diff_pdf = hist(Tca_diff,x);
Tca_diff_pdf = Tca_diff_pdf/length(Tca_diff);
Tca_diff_cdf = cumsum(Tca_diff_pdf)./sum(Tca_diff_pdf);