Off statistics;
Symbols N, CF, TR;
Indices a, b, c, i, j, k, l;
Functions T;
Local ColorTrace = T(a, i, j) * T(a, j, i);

* TEST 1:
id T(a?, i?, j?) * T(a?, k?, l?) = TR * ( d_(i,l)*d_(j,k) - d_(i,j)*d_(k,l)/N );

contract;
id d_(i?, i?) = N;
id TR = 1/2;
Print +s;
.end
