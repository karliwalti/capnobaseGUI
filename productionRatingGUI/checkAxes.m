function checkAxes(hObject,number)

a=sort(findobj(hObject, 'Type','axes'));
if length(a)>number
%  for i=1:length(a)
%      get(a(i))
%      delete(a(i))
disp('Warning: killed phantom axes. No user action needed.')
delete(a(1)); % TODO no proof that this is so delete axes with smallest ID
%  end
end