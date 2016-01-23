function grid = spatialPyramid(levels, image, segments, badSegments)
%spatialPyramid Implements a spatial pyramid scheme
%   Returns an object that contains the points that
%   constitute the rectangles of the grid at the various levels of
%   resolution, as specified by levels.
%   A spatial pyramid is a collection of orderless feature histograms 
%   computed over cells defined by a multi-level recursive image 
%   decomposition. At level 0, the decomposition consists of just a single 
%   cell, and the representation is equivalent to a standard BoF. 
%   At level 1, the image is subdivided into four quadrants, yielding four 
%   feature histograms, and so on.

[width, height, ~] = size(image);
level = spatialPyramidGrid(width, height, levels);
totalCells = sum(4.^(0:levels-1));
grid(totalCells) = struct('spixelsToAverage', []);
spIndices = unique(segments);
i = 1;

for l = 1:levels
    cells = level(l).cell;
    levelCells = length(cells);
    
    for c = 1:levelCells
        cell = cells(c);

        % Points of image that fall inside the current cell
        xv = round(cell.xv);
        yv = round(cell.yv);

        % Make sure this works
        temp = unique(segments(min(xv):max(xv), min(yv):max(yv)));   
        ind = zeros(length(temp), 1);
        
        % Temp contains sp indices which are not always sequential
        % This converts them to sequentials i.e indices to the positions of
        % the vector that contains the sp indices
        for t = 1:length(temp)
            if ismember(find(spIndices == temp(t)), badSegments)
                continue;
            end
            ind(t) = find(spIndices == temp(t));
        end
        ind(ind==0) = [];
        grid(i).spixelsToAverage = ind;
        
        i = i + 1;
    end
end

end


function level = spatialPyramidGrid(width, height, levels)
    level(levels) = struct('cell', []);
    
    for l = 0:levels-1
        points(4^l) = struct('xv', [], 'yv', []);
        gridStepX = width / (2^l);
        gridStepY = height / (2^l);
        gridY = 1:gridStepY:height;
        gridX = 1:gridStepX:width;
        
        i = 1;
        for x = gridX
            for y = gridY
                
                incrx = gridStepX;
                incry = gridStepY;
                
                if x + incrx > width
                    incrx = incrx - 1;
                end
                
                if y + incry > height
                    incry = incry - 1;
                end
                
                p1 = [x y];
                p2 = [x+incrx y];
                p3 = [x, y+incry];
                p4 = [x+incrx, y+incry];
                cellPoints = [p1; p3; p4; p2];
                points(i).xv = cellPoints(:, 1);
                points(i).yv = cellPoints(:, 2);
                i = i + 1;
            end
        end

        level(l+1).cell = points;
    end
end
