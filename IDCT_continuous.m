function B = IDCT_continuous(k,t)
% k: the number of time sequence
% n: the number of frequency signal(base)

B = sqrt(1/k);
for i = 2 : k
    B = [B sqrt(2/k)*cos((2*t+1)*(i-1)*pi/2/k)];
end
