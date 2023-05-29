function cell2csv(filename,cellArray,delimiter)
% Writes cell array content into a *.csv file.
%
% CELL2CSV(filename,cellArray,delimiter)
%
% filename      = Name of the file to save. [ i.e. 'text.csv' ]
% cellarray    = Name of the Cell Array where the data is in
% delimiter = seperating sign, normally:',' (it's default)
%
% by Sylvain Fiedler, KA, 2004
% modified by Rob Kohr, Rutgers, 2005 - changed to english and fixed delimiter
% modified by WK 2010 - added " as enclosure for text
if nargin<3
    delimiter = ',';
end

datei = fopen(filename,'wt');
for z=1:size(cellArray,1)
    for s=1:size(cellArray,2)
        
        %var = eval('cellArray{z,s}');%
        % var = cellArray{z,s}; %
        
        if size(cellArray{z,s},1) == 0
            var = ['"' '"'];
            fprintf(datei,var);
        elseif   ischar(cellArray{z,s}) == 1
            var = cellArray{z,s};
          %  if iscell(var)
            if size(var,1)>1
                var=[strjust(var)]
                for i=1:size(var,1)
                var(i,end+1)=';';
                end
                var=strtrim(reshape(strjust(var)',1,[]))
            end
            var = ['"' var '"'];
            fprintf(datei,var);
        elseif isnumeric(cellArray{z,s}) == 1
            %             var = num2str(cellArray{z,s});
            %          fprintf(datei,var);
            if length(cellArray{z,s}) > 1
                  fprintf(datei,' %g',cellArray{z,s});
            else
                fprintf(datei,'%g',cellArray{z,s});
            end
        else
            fprintf(datei,cellArray{z,s});
        end
        
        if s ~= size(cellArray,2)
            fprintf(datei,[delimiter]);
        end
    end
    fprintf(datei,'\n');
end
fclose(datei);
