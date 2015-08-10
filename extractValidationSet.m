<<<<<<< HEAD
function shuffledValidationSet = extractValidationSet(n)
=======
function validationSet = extractValidationSet(n)
>>>>>>> ae9dd03f6aced89ed60d1f9ff15778d846068647
%extractValidationSet Summary of this function goes here
%   Detailed explanation goes here
% n : samples per class (1000)
field1 = 'features'; value1 = zeros(8576, 1);
field2 = 'classLabel'; value2 = '';
field3 = 'classIndex'; value3 = 0;
field4 = 'image'; value4 = '';

% Generate random seed
[~, seed] = system('od /dev/urandom --read-bytes=4 -tu | awk ''{print $2}''');
seed = str2double(seed);

% Seed the generator
rng(seed);

% Read class labels from file
base = 'data/';
classFile = [base 'meta/classes.txt'];
fid = fopen(classFile);
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

% Preallocate space for result
validationSet(n * length(classes)) = struct(field1, value1, field2, value2, field3, value3, field4, value4);

for y = 1:length(classes)
    class = num2str(cell2mat(classes(y)));
    fprintf('%d/%d\n', y, length(classes));
    load(['done/' class]);
    randomIndexes = randi([1 length(encoded)], n, 1);
    start = (y-1)*n+1;
    stop = y*n;
    validationSet(start:stop) = encoded(randomIndexes);
    encoded(randomIndexes) = [];
    save(['done/' class], 'encoded');
    clear encoded
end

<<<<<<< HEAD
permutation = randperm(length(validationSet));
shuffledValidationSet = validationSet(permutation);
=======
>>>>>>> ae9dd03f6aced89ed60d1f9ff15778d846068647
end

