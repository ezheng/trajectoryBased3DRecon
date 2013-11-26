function B = IDCTmappingMatrix(k)
% k: the number of time sequence
% n: the number of frequency signal(base)
if nargin == 1
    n = k;
end
for i = 1 : k
    for j = 1 : n
        if j == 1
            B(i,j) = sqrt(1/k)*cos((j-1)*(2*i-1)*pi/2/k);
        else
            B(i,j) = sqrt(2/k)*cos((j-1)*(2*i-1)*pi/2/k);
        end
    end
end

