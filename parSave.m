function parSave( fname, trainingSet)
%parSave Save from inside a parfor loop
save( fname, 'trainingSet');
end

