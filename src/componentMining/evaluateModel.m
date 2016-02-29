 function [accuracy, precision, recall, fmeasure ] = evaluateModel(y, yh, verbose)
% This fucntion evaluates the performance of a classification model by 
% calculating the common performance measures: Accuracy, Sensitivity, 
% Specificity, Precision, Recall, F-Measure, G-mean.
% Input: ACTUAL = Column matrix with actual class labels of the training
%                 examples
%        PREDICTED = Column matrix with predicted class labels by the
%                    classification model
% Output: EVAL = Row matrix with all the performance measures

actual = y;
idx = (actual()==1);

p = length(actual(idx));
n = length(actual(~idx));
N = p + n;

tp = sum(actual(idx) == yh(idx));
tn = sum(actual(~idx) == yh(~idx));
fp = n-tn;
fn = p-tp;

accuracy = (tp + tn) / N;
precision = tp / (tp + fp);
recall = tp/p;
fmeasure = 2 * ((precision * recall) / (precision + recall));

if verbose
%     fprintf('true positives = %d\n', tp);
%     fprintf('true negatives = %d\n', tn);
%     fprintf('false positives = %d\n', fp);
%     fprintf('false negatives = %d\n', fn);
    fprintf('Accuracy = %f - Precision = %f - Recall = %f - FMeasure = %f\n', accuracy, precision, recall, fmeasure);
%     fprintf('Accuracy = %f\n', accuracy);
end

 end
