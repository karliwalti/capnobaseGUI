

function idx=getExpFlow(data,sampling,offset)
% created 15.2.10 WK

%computes zero crossings for flow window, ignores a short window in the
%detection

if nargin<2
  
    sampling =300;
end
%get zero crossing
PIdx=posZeroCrossing(data-offset,sampling);%
%NIdx=negZeroCrossing(data-offset,sampling);

%NIdx(NIdx<PIdx(1))=[];
 PIdx=[1; PIdx];

% for i=2:length(PIdx)
%      [a b]=min(abs(diff(data(PIdx(i-1):PIdx(i)))));
%  	idx(i-1)=b+PIdx(i-1);
% %first 0before 
% %	[a b]=min(abs(diff(data(PIdx(i):-1:PIdx(i-1)))));
% %	idx(i-1)=-b+PIdx(i);
% end

idx=PIdx;