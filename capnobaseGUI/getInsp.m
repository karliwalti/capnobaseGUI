

function idx=getInsp(data,sampling)
% created 15.2.10 WK

%computes zero crossings for flow window, ignores a short window in the
%detection

if nargin<2
  
    sampling =300;
end
%get zero crossing
%PIdx=posZeroCrossing(data-1.5,sampling)
NIdx=negZeroCrossing(data-1.5,sampling);

%NIdx(NIdx<PIdx(1))=[];
 NIdx=[1; NIdx];

for i=2:length(NIdx)
    [a b]=max(data(NIdx(i-1):NIdx(i)));
idx(i-1)=b+NIdx(i-1);
end

        idx=idx;