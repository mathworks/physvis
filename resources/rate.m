function rate(desiredRate)
%RATE control the frame rate of animations in a CANVAS object.

% © Copyright 2017 The MathWorks, Inc.

persistent startTime
persistent thread
persistent lastDraw

if(isempty(startTime))
    startTime = tic;
    lastDraw = startTime;
    thread = java.lang.Thread;
end

drawNeeded = toc(lastDraw) - 1/desiredRate > 0;
if(drawNeeded)
    drawnow('limitrate')
    lastDraw = tic;
end

desiredTime = 1/desiredRate;
elapsedTime = toc(startTime);
pauseNeeded = desiredTime - elapsedTime;
if(pauseNeeded > 0.001)
    thread.sleep(pauseNeeded*1000);
end
startTime = tic;
end