function [contourImg] = draw_contours(labels, img)
% function [contourImg] = draw_contours(labels, img)
%
% David Stutz <david.stutz@rwth-aachen.de>

    rows = size(img, 1);
    cols = size(img, 2);

    contourImg = img;
    for i = 1: rows
        for j = 1: cols
            label = labels(i, j);
            labelTop = 0;
            labelBottom = 0;
            labelLeft = 0;
            labelRight = 0;

            if i > 1
                labelTop = labels(i - 1, j);
            end;
            if j > 1
                labelLeft = labels(i, j - 1);
            end;
            if i < rows
                labelBottom = labels(i + 1, j);
            end;
            if j < cols
                labelRight = labels(i, j + 1);
            end;

            if labelTop ~= 0 && labelTop ~= label
                contourImg(i, j, 1) = 0;
                contourImg(i, j, 2) = 0;
                contourImg(i, j, 3) = 0;
            end;
            if labelLeft ~= 0 && labelLeft ~= label
                contourImg(i, j, 1) = 0;
                contourImg(i, j, 2) = 0;
                contourImg(i, j, 3) = 0;
            end;
            if labelBottom ~= 0 && labelBottom ~= label
                contourImg(i, j, 1) = 0;
                contourImg(i, j, 2) = 0;
                contourImg(i, j, 3) = 0;
            end;
            if labelRight ~= 0 && labelRight ~= label
                contourImg(i, j, 1) = 0;
                contourImg(i, j, 2) = 0;
                contourImg(i, j, 3) = 0;
            end;
        end;
    end;
end