function display_structure(structure, max_array_size, start_indent_size, step_size)
%This function displays the fields
%in a structure. This is done using
%the disp function.
%Fields in structures within the structure
%are shown indented.
%Arrays will be shown if the length of the array
%is smaller than a preset value (default: 10).
%Also column vectors will be shown: they are marked
%by the ' (transpose) sign.
%Input:     -Structure
%           -Integer, the maximum length of an array that still will be displayed
%           -Integer, the size of the first indent
%           -Integer, the size of the indent
%Mark Jobse 23-07-2002
%14-08-2002 Added class and size info
%19-08-2002 Added append and split_array, removed bug: error when matrix > 2D
%15-11-2002 Added functionality to display arrays; names are now aligned as in Matlab
%18-11-2002 Removed bug when 'displaying' cells.
%27-11-2002 Removed bug when displaying int or uint arrays.
%08-01-2003 Can now also display character arrays (they were previously converted to doubles)
%11-02-2003 Can now display cell ARRAYS. Only array will be displayed. Cell is converted to 
%           a structure with each cell having a name like: 'cell1', 'cell2'...

if (nargin < 4)
    step_size = 3;
end

if (nargin < 3)
    start_indent_size = 1;
end

if (nargin < 2)
    max_array_size = 10;
end

if (start_indent_size < step_size) %First put the name of the structure
    name_string = inputname(1);
    disp(name_string);
    start_indent_size = start_indent_size + step_size;
end

start_indent(1:start_indent_size) = ' ';
new_start_indent_size = start_indent_size + step_size;
indent = start_indent;

%Declarations
structure_out = [];
struct_cell = [];
non_struct_cell = [];
arCellCell = [];

%Get all fields out of the structure
cell = fieldnames(structure);

%Now split those fields into structures and other fields
counter = 1;
counter2 = 1;
cellcounter = 1;
for i = 1:length(cell)
    Field = getfield(structure, cell{i});
    boolean = isstruct(Field);
    blCell = iscell(Field);
    if (boolean)
        struct_cell{counter} = cell{i};
        counter = counter + 1;
    else
        if blCell
            [new_structure, blFailed] = myCell2Struct(getfield(structure, cell{i}));
            if ~blFailed
                arCellCell{cellcounter} = cell{i};
                cellcounter = cellcounter + 1;
            else
                non_struct_cell{counter2} = cell{i};
                counter2 = counter2 + 1;
            end
        else
            non_struct_cell{counter2} = cell{i};
            counter2 = counter2 + 1;
        end
    end
end

%First display the structure fields
for i = 1:length(struct_cell)
    new_structure = getfield(structure, struct_cell{i});
    string = (struct_cell{i});
    string = append(indent, string);
    disp(string);
    display_structure(new_structure, max_array_size, new_start_indent_size, step_size);
end

%Now the cellfields, which will be converted to structures
for i = 1:length(arCellCell)
    [new_structure, blFailed] = myCell2Struct(getfield(structure, arCellCell{i}));
    if ~blFailed
        string = arCellCell{i};
        string = append(indent, string);
        disp(string);
        display_structure(new_structure, max_array_size, new_start_indent_size, step_size);
    else
        non_struct_cell{counter2} = getfield(structure, arCellCell{i});
        counter2 = counter2 + 1;
    end
end

%Now display the names of the non-structure fields
%First determine the maximum length of the variable name, so they can be aligned
max_length = 0;
for i = 1:length(non_struct_cell);
    length_name = length(non_struct_cell{i});
    if (length_name > max_length)
        max_length = length_name;
    end
end
    
for i = 1:length(non_struct_cell);
    length_name = length(non_struct_cell{i});
    string = repmat(' ', 1, max_length - length_name);
    string = append(string, non_struct_cell{i});
    string = append(indent, string);
    variable_string = '';
    class_string = '';
    size_string = '';
    size_variable = size(getfield(structure, non_struct_cell{i}));
    if (length(size(getfield(structure, non_struct_cell{i}))) < 3 & ~isequal(class(getfield(structure, non_struct_cell{i})), 'cell'))
        %size_variable = sort(size_variable);
        if (size_variable(1) == 1 & size_variable(2) <= max_array_size) %Variable is an array (row)
            if (size_variable(2) == 1) %Variable is a scalar
                temp = getfield(structure, non_struct_cell{i});
                if isequal(class(temp), 'char')
                    variable_string = append(variable_string, temp);
                else
                    variable_string = append(variable_string, num2str(double(temp)));
                end
            else
                temp = getfield(structure, non_struct_cell{i});
                if isequal(class(temp), 'char')
                    variable_string = append(variable_string, temp);
                else
                    variable_string = '[';
                    variable_string = append(variable_string, num2str(double(temp)));
                    variable_string = append(variable_string, ']');
                end
            end
        else
            if (size_variable(2) == 1 & size_variable(1) <= max_array_size) %Variable is an array (column)
                %Scalar case is handled by previous if construction
                temp = getfield(structure, non_struct_cell{i});
                if isequal(class(temp), 'char')
                    variable_string = append(variable_string, temp);
                else
                    variable_string = '[';
                    variable_string = append(variable_string, num2str(double(temp)'));
                    variable_string = append(variable_string, ']');
                end
                %Now we append a ' to show this is a column vector
                variable_string = append(variable_string, '''');
            else
                class_string = class(getfield(structure, non_struct_cell{i}));
                size_string = create_size_string(size(getfield(structure, non_struct_cell{i})));
            end
        end
    else
        class_string = class(getfield(structure, non_struct_cell{i}));
        size_string = create_size_string(size(getfield(structure, non_struct_cell{i})));
    end
    string = append(string, ': ');
    string = append(string, variable_string);
    if ~isempty(class_string) %If the variable was displayed, there is no need to display class and size info
        string = append(string, '[');
        string = append(string, size_string);
        string = append(string, ' ');
        string = append(string, class_string);
        string = append(string, ']');
    end
    disp(string);
end




function size_string = create_size_string(array)
size_string = num2str(array);
%Replace the spaces in the string with x-es
pos = find(size_string == ' ');
pos = split_array(pos);
size_string(pos(:,1)) = 'x';
pos(:,1) = [];
zeropos = find(pos == 0); %Detect zeros in the matrix created by split_array
pos(zeropos) = []; %Remove them
size_string(pos) = [];

function matrix = split_array(array)
%This function splits an array into a number of colums. 
%This by creating a new row every time there is a large step in
%the values in the array. This function assumes the values to be sorted!
%Input:     -Array containing SORTED (intensity) values
%Output:    -Matrix created from the original array
array = double(array);
lengte = length(array);
previous_value = array(1);
teller2 = 1;
teller3 = 1;
for teller = 1:lengte
    if ((array(teller) == previous_value) | (array(teller) == (previous_value + 1)))
        matrix(teller3, teller2)=array(teller);
        teller = teller + 1;
        teller2 = teller2 + 1;
    else
        matrix(teller3 + 1, 1)=array(teller);
        teller = teller + 1;
        teller2 = 2;
        teller3 = teller3 + 1;
    end
    previous_value = array(teller - 1);
end
%matrix = unint8(matrix);

function array_out = append(array_in, array_to_append)
%This function appends an array to the tail of another array.
%Input:     -Array, the original array
%           -Array, the array that will be attached to array_in
%Output:    -Array

length_array_in = length(array_in);
length_array_to_append = length(array_to_append);
array_out = array_in;
array_out((length_array_in + 1):(length_array_in + length_array_to_append)) = array_to_append;


function [strOut, blFailed] = myCell2Struct(clIn)
%This function converts a cell ARRAY(!)
%into a structure. The original
%cell2struct will convert a cell 
%array into a structure ARRAY. 
%This function creates structure
%fieldnames 'cell1', 'cell2', etc.
%If the cell is not an array, the 
%flag Failed will be set. And no structure
%will be created.
%Input:     -Cell
%Output:    -Structure

arSize = size(clIn);

strOut = [];
blFailed = 1;
if length(arSize) > 2
    %3D matrix
    return
end

if min(arSize) > 1
    %Not an array
    return
end

strName = 'Cell';
for i = 1:max(arSize) %Length(clIn)
    strNameNew = [strName, num2str(i)];
    strOut = setfield(strOut, strNameNew, clIn{i});
end
blFailed = 0;