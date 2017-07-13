classdef CanvasRegistry < handle
%CANVASREGISTRY Registry to keep track of multiple CANVAS objects
%   See also CANVAS

% © Copyright 2017 The MathWorks, Inc.
% Author: James Kristoff

    methods(Access = {?physvis.Core, ?physvis.Canvas, ?matlab.unittest.TestCase})
        function obj = CanvasRegistry()
            % Constructor
        end
    end
    methods
        function ActiveCanvas = getActiveCanvas(obj)
            % Get the active Canvas
            ActiveCanvas = obj.modifyActiveCanvas('get');
        end
        function setActiveCanvas(obj, canvasObj)
            % Set the active Canvas
            obj.modifyActiveCanvas('set', canvasObj);
        end
        function CanvasNumber = getNextCanvasNum(obj)
            % Get the next Canvas number to refer to it
            CanvasNumber = obj.modifyActiveCanvas('getNextCanvasNum');
        end
        function unregister(obj, canvasObj)
            % Remove a Canvas from the registry
            obj.modifyActiveCanvas('unregister', canvasObj);
        end
    end
    methods(Static, Access=private)
        function varargout = modifyActiveCanvas(Command, Canvas)
            persistent activeCanvas
            persistent canvasList
            persistent numbersUsed
            persistent nextCanvasNumber
            switch Command
                case 'set'
                    if( ~isempty(Canvas) )
                        activeCanvas = Canvas;
                        if(isempty(canvasList))
                            canvasList = {};
                        end
                        if(~ismember(Canvas, [canvasList{:}]))
                            nextCanvasNumber = physvis.CanvasRegistry.calculateNextNum(numbersUsed);
                            canvasList{nextCanvasNumber} = Canvas;
                            numbersUsed(nextCanvasNumber) = nextCanvasNumber;
                        end
                    end
                case 'get'
                    if(nargout == 1)
                        if(isempty(activeCanvas))
                            activeCanvas = physvis.Canvas();
                        end
                        varargout{1} = activeCanvas;
                    end
                case 'unregister'
                    canvasIdx = cellfun(@(c)isequal(c, Canvas), canvasList);
                    canvasList{canvasIdx} = physvis.Canvas.empty();
                    numbersUsed(canvasIdx) = 0;
                    while(~isempty(numbersUsed) && numbersUsed(end) == 0)
                        numbersUsed(end) = [];
                        canvasList(end) = [];
                    end
                    if(isempty(canvasList))
                        canvasList = {};
                    end
                    nextCanvasNumber = physvis.CanvasRegistry.calculateNextNum(numbersUsed);
                    if(isequal(Canvas, activeCanvas))
                        if(isempty(canvasList))
                            currentCanvas = physvis.Canvas.empty();
                        else
                            currentCanvas = canvasList{end};
                        end
                        activeCanvas = currentCanvas;
                    end
                case 'reset'
                    activeCanvas = [];
                case 'getNextCanvasNum'
                    if(nargout == 1)
                        if(isempty(nextCanvasNumber))
                            nextCanvasNumber = physvis.CanvasRegistry.calculateNextNum(numbersUsed);
                        end
                        varargout{1} = nextCanvasNumber;
                    end
                otherwise
            end
        end
        function nextNum = calculateNextNum(numsUsed)
            availableNumsIdx = numsUsed < 1;
            if(any(availableNumsIdx))
                nextNum = find(availableNumsIdx, 1);
            else
                if(isempty(numsUsed))
                    nextNum = 1;
                else
                    nextNum = max(numsUsed)+1;
                end
            end
        end
    end
end
