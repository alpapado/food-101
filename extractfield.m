function A = extractfield(S, name)
%EXTRACTFIELD Field values from structure array
%
%   A = EXTRACTFIELD(S, NAME) returns the field values specified by the
%   fieldname NAME in the 1-by-N output array A.  N is the total number
%   of elements in the field NAME of structure S:
%
%                   N = numel([S(:).(name)]).
%
%   NAME is a case-sensitive string defining the field name of the
%   structure S.  A will be a cell array if any field values in the
%   fieldname contain a string or if the field values are not uniform in
%   type; otherwise A will be the same type as the field values. The shape
%   of the input field is not preserved in A.
%   
%   Examples
%   --------
%   % Plot X, Y coordinates from a geographic data structure
%   roads = shaperead('concord_roads.shp');
%   plot(extractfield(roads,'X'),extractfield(roads,'Y'));
%
%   % Extract feature names from a geographic data structure
%   roads = shaperead('concord_roads.shp');
%   names = extractfield(roads,'STREETNAME');
%
%   % Extract a mixed-type field into a cell array
%   S(1).Type = 0;
%   S(2).Type = logical(0);
%   mixedType = extractfield(S,'Type');
%
%   See also STRUCT, SHAPEREAD.

% Copyright 1996-2015 The MathWorks, Inc.

% Validate inputs
narginchk(2,2)
fcnname = mfilename;
validateattributes(S,    {'struct'}, {'vector'}, fcnname, 'S', 1)
validateattributes(name, {'char'},   {'row'},    fcnname, 'NAME', 2)

if isfield(S,name)

   % Determine if need to return a cell array
   if cellType(S,name)
      % The elements in the field are strings or mixed type
      A = {S(:).(name)};
      return;
   end

   try 
      % The field is numeric.
      % This will error if the fieldname's shape is neither row vector 
      %  nor uniform. 
      A = [S(:).(name)];
      % Do not preserve the shape
      if size(A,1) ~= 1
         A = reshape(A, [1 numel(A)]);
      end
   catch
      % The elements in the field are mixed size
      % Reshape into a row vector and append
      A = reshape(S(1).(name),[ 1 numel(S(1).(name)) ]);
      for i=2:length(S)
         values = reshape(S(i).(name),[ 1 numel(S(i).(name)) ]);
         A = [A values];
      end
   end

else
   error('map:extractfield:invalidFieldname', ...
       'Fieldname ''%s'' does not exist.', name)
end

%----------------------------------------------------------------
function returnCell = cellType(S, name)
%CELLTYPE Return true if field values of NAME are mixed type,  or
% non-numeric.

% Determine if the field is non-numeric or mixed type
classType = class(S(1).(name));
for i=1:length(S)
   if issparse(S(i).(name))
      error('map:extractfield:expectedNonSparse', ...
          'Sparse storage class is not supported.');
   end
   if ~isnumeric(S(i).(name)) || ...
      ~isequal(class(S(i).(name)), classType)
      returnCell = true;
      return;
   end
end
returnCell = false;
