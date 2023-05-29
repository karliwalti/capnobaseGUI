function [header value]=setHeaderValue(header,value,newFieldname,newValue,signalcounter)

if iscell(newValue)
newValue=newValue{:};
end

TF=strcmp(header,newFieldname);
idx=find(TF);
if isempty(idx)
    header{end+1}=newFieldname;
     value{signalcounter,end+1}=newValue;
else
    
  %header{idx}=newFieldname;
  value{signalcounter,idx}=newValue;
end
                                   