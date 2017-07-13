function test

% © Copyright 2017 The MathWorks, Inc.

q = physvis.Canvas;
w = physvis.Sphere('Position', [8,1], 'Color', uint8([18, 86, 0]), 'Canvas', q);
w2 = physvis.Sphere('Position', [0,1], 'Color', uint8([120, 120, 24]), 'Canvas', q);
for i = 1:1000
    if(pdist2(w.Position, w2.Position) < 2)
        dx = -0.1;
    elseif(pdist2(w.Position, w2.Position) > 4)
        dx = 0.1;
    end
    w2.Position(1) = w2.X+dx;
    rate(100)
end

end