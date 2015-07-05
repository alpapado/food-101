function [ encoded] = encodeDataset(datasetPath, superpixelsPath, classes)
%encodeDataset Calculates surfs and lab values and fisher encodes them, for
%the entire dataset

field1 = 'features'; value1 = zeros(8576, 1);
field2 = 'classLabel'; value2 = '';
field3 = 'classIndex'; value3 = 0;
field4 = 'image'; value4 = '';

numClasses = length(classes);
j = 0;

for c = 1:numClasses
    classLabel = num2str(cell2mat(classes(c)));
    fprintf('Current class = %s \n', classLabel);
%     imagesPath = [datasetPath classLabel '/'];
%     classIndex = c;
    encoded = [];
    spPath = [superpixelsPath classLabel '/']; 
    allSuperpixels = dir([superpixelsPath classLabel '/*.mat']);

    for i = 1:length(allSuperpixels)
        % Load previously computed superpixels into variable segments
%         fprintf('Encoding %s %d/%d\n', classLabel, i, size(allSuperpixels,1));
        sp = load([spPath allSuperpixels(i).name]);
        
        % Also load image to which the superpixels correspond
%         imageName = [imagesPath allSuperpixels(i).name(1:end-4) '.jpg'];
        
        try 
            segments = sp.segments;
        catch
            segments = sp.seg;
        end
        
        % For every superpixels in the image call extractSuperpixelFeatures
        numSuperpixels = max(max(segments));
        for s = 1:numSuperpixels;
%             try
%                 features = extractSuperpixelFeatures( imageName, segments, s);
%                 temp = struct(field1, value1, field2, value2, field3, value3, field4, value4);
%                 temp.features = features;
%                 temp.classLabel = classLabel;
%                 temp.classIndex = classIndex;
%                 temp.image = imageName;
%                 encoded = [encoded; temp];
%             catch ME
% %                 msgString = getReport(ME);
% %                 disp(msgString);
%             end
            j = j + 1;
        end

    end

%     save(classLabel, 'encoded');
end
j
end

