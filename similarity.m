function [ s ] = similarity( a, b )
%similarity Returns the similarity s, of a vector a in regards to a vector
%b
% Similarity of a to b is defined as how many elements of a also appear in
% b, divided by the number of elemnents in a.
lenA = length(a);
s = 0;

for i = 1:lenA
    if sum(b == a(i)) == 1
        s = s + 1;
    end 
end

s = s / lenA;

end

