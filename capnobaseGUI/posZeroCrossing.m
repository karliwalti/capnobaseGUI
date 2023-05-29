function idx=posZeroCrossing(flow,sampling);
% created 10.8.09 WK

%computes zero crossings for flow window, ignores a short window in the
%detection

if nargin<2
    inertwindow=100;
    sampling =300;
else
     inertwindow=round(1/3*sampling);
end
%min flow change amplitude to accept 
minchange=1;

Y=sign(flow);

% replace zero
idx=find(Y==0);
Y(idx)=-1;
%% crossing over 0
Z=Y(1:end-1)-Y(2:end);
idx=find(Z<0);

%delete too close change
a =find(idx<=inertwindow,1);
if (~isempty(a))
    idx(a)=[];
end

% for i=length(idx)-1:-1:1
% % mean next 0.3s are too small 
%    if ( mean(flow(idx(i):min(idx(i)+round(1/3*sampling),length(flow))))<minchange)
%       idx(i)=[]; %clear 
%    end
% end

for i=length(idx)-1:-1:1
    
    
     if (Y(max(1,idx(i)-inertwindow))>0) %clear if noise
         idx(i)=[]; %clear 
     elseif ((idx(i+1)-idx(i))<inertwindow)
        idx(i+1)=[]; %clear close detection
        end
end
        
        