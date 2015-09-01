function grid = spatialPyramid(levels, image, segments, validSegments)
%spatialPyramid Summary of this function goes here
%   Detailed explanation goes here
% [width, height, channels] = size(image);

[width, height, ~] = size(image);
level  = spatialPyramidGrid(width, height, levels);
totalCells = sum(4.^(0:levels-1));
grid(totalCells) = struct('spixelsToAverage', []);

i = 1;
for l = 1:levels
    cells = level(l).cell;
    levelCells = length(cells);
    
    for c = 1:levelCells
        cell = cells(c);
       
        % Points of image that fall inside the current cell
        xv = cell.xv;
        yv = cell.yv;

        % Make sure this works
        temp = unique(segments(min(xv):max(xv), min(yv):max(yv)));
        
        % Reject segments that were too small to be encoded
        indexOfInvalids = find(validSegments == 0);
        toKeep = ones(length(temp), 1);
        for t = 1:length(temp)
            if ismember(temp(t), indexOfInvalids-1)
                toKeep(t) = 0;
            end
        end

        grid(i).spixelsToAverage = temp(logical(toKeep));
        
        
        i = i + 1;
%        figure(1)
% 
%         plot(xv,yv) % polygon
%         axis equal
% 
%         hold on
%         plot(xq(in),yq(in),'r+') % points inside
%         plot(xq(~in),yq(~in),'bo') % points outside
%         hold off
%        size(in)
%        pause
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
