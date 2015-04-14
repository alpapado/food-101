clc
clear

% Read class labels from file
fid = fopen('food-101/meta/classes.txt');
classes = textscan(fid, '%s', 'Delimiter', '\n');
classes = classes{1};

% Segment the dataset and save the results
base = 'food-101/';
images_path = 'food-101/images/';
targetPath = [base 'superpixels/'];
% segment_dataset(images_path, classes, superpixels_path);

for c=1:size(classes,1)
    currentClass = num2str(cell2mat(classes(c)));
    pathToSuperpixels = [targetPath currentClass];
    superpixels = dir([pathToSuperpixels '/*mat']);
    
    for i = 1:size(superpixels, 1)
        tmp = superpixels(i).name;
        saveLoc = [pathToSuperpixels '/' tmp];
        x = load(saveLoc);
        seg = x.segments;
        delete(saveLoc);
        save(saveLoc, 'seg');              
       
    end
end