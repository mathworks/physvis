for ballIdx = 1000:-1:1
    
% © Copyright 2017 The MathWorks, Inc.

    ball(ballIdx) = physvis.Sphere( ...
        'Radius', 0.2, 'HasTrail', false, 'Retain', 10, ...
        'Position', rand(1,3).*2-1, 'Alpha', rand(1));
end
