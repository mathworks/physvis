classdef Canvas < matlab.mixin.SetGetExactNames
%CANVAS Interactive figure windows.
%   Pan while holding down the left mouse button.
%   Rotate while holding down the right mouse button.
%   Zoom with the mouse wheel.
%
%   See also CANVASREGISTRY ORIGIN
    
% © Copyright 2017 The MathWorks, Inc.
% Author: James Kristoff

    properties
        Visible = 'on'; % Figure visibility
    end
    properties(GetAccess = ?physvis.Core, SetAccess = private)
        Figure
        Axes
        Light
    end
    properties(Access = private)
        ViewMode = ViewEditType.None;
        MousePosition
        OrbitPhi = 0;
        CanvasRegistry = physvis.CanvasRegistry;
        Origin
    end
    methods
        function obj = Canvas(varargin)
            % Constructor
            
            parseInputs(obj, varargin{:})
            setActiveCanvas(obj.CanvasRegistry, obj);
            initializeFigure(obj)
            initializeAxes(obj)
            initializeLight(obj)
            obj.Origin = physvis.Origin('Radius', 0.1, 'Position', obj.Axes.CameraTarget);
        end
        function delete(obj)
            if(~isempty(obj.Figure) && isvalid(obj.Figure))
                delete(obj.Figure)
            end
            unregister(obj.CanvasRegistry, obj);
        end
        function set.Visible(obj, value)
            % Check that the provided value is valid
            try
                p = inputParser;
                validationFcn = @(x) ischar(x) && ismember(x, {'on', 'off'});
                addRequired(p,'Visible', validationFcn)
                parse(p, value)
            catch ME_cause
                if(strcmp(ME_cause.identifier, 'MATLAB:InputParser:ArgumentFailedValidation'))
                    ME = MException('PHYSVIS:Canvas:BadVisibleValue', ...
                        'While setting property ''Visible'' of class ''physvis.Canvas'':\nValue must be specified as the string ''on'' or ''off''');
                    throwAsCaller(ME)
                else
                    rethrow(ME_cause)
                end
            end

            updateFigureProperty(obj, 'Visible', value)
            obj.Visible = value;
        end
    end
    methods(Access = private)
        % Callbacks
        function deleteInstance(obj, ~, ~)
            if(isvalid(obj))
                % delete the object
                delete(obj);
            end
        end
        function mouseClick(obj, Figure, eventData)
            obj.MousePosition = Figure.CurrentPoint;
            setActiveCanvas(obj.CanvasRegistry, obj);
            switch Figure.SelectionType
                case 'normal'
                    % do nothing on a left mouse-click
                    obj.ViewMode = ViewEditType.Pan;
                case 'extend'
                    obj.ViewMode = ViewEditType.Zoom;
                case 'alt'
                    obj.ViewMode = ViewEditType.Orbit;
                case 'open'
                    % do nothing on a double-click
                otherwise
                    warning('Unexpected selection type found: %s.\n', Figure.SelectionType)
            end
            status = strcmp(eventData.EventName, 'WindowMousePress');
            if(~status)
                obj.ViewMode = ViewEditType.None;
            end
        end
        function mouseMove(obj, Figure, ~)
            curPoint = Figure.CurrentPoint;
            figPosition = Figure.Position;
            if(isempty(obj.MousePosition))
                obj.MousePosition = curPoint;
            end
            posDiff = curPoint - obj.MousePosition;
            obj.MousePosition = curPoint;
            percentMove = (1 - (figPosition(3:4) - posDiff)./figPosition(3:4));
            switch obj.ViewMode
                case ViewEditType.None
                case ViewEditType.Orbit
                    angularDiff = -percentMove.*90;
                    if(abs(obj.OrbitPhi + angularDiff(2)) > 90)
                        angularDiff(2) = 0;
                    else
                        obj.OrbitPhi = obj.OrbitPhi + angularDiff(2);
                    end
                    camorbit(obj.Axes, angularDiff(1), angularDiff(2), 'data', 'y')
                case ViewEditType.Zoom
                    cameraPos = (obj.Axes.CameraPosition - obj.Axes.CameraTarget);
                    zoomFactor = sign(percentMove(2))*1+percentMove(2)*2;
                    if(zoomFactor < 0)
                        zoomFactor = 1/abs(zoomFactor);
                    end
                    if(zoomFactor > 0)
                        dPos = cameraPos * (1/zoomFactor) + obj.Axes.CameraTarget;
                        campos(obj.Axes, dPos)
                    end
                case ViewEditType.Pan
                    dPos = -percentMove.*2;
                    camdolly(obj.Axes, dPos(1), dPos(2), 0)
                    obj.Origin.Position = obj.Axes.CameraTarget;
            end
        end
        function mouseScroll(obj, ~, eventData)
            cameraPos = (obj.Axes.CameraPosition - obj.Axes.CameraTarget);
            zoomFactor = 1 + sign(eventData.VerticalScrollCount)*eventData.VerticalScrollAmount/20;
            campos(obj.Axes, cameraPos * zoomFactor + obj.Axes.CameraTarget)
        end
        % Helper Functions
        function initializeFigure(obj)
            obj.Figure = figure( ...
                'Color', 'k', ...
                'Units', 'points', ...
                'Renderer', 'opengl', ...
                'Visible', obj.Visible, ...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'NumberTitle', 'off', ...
                'Name', sprintf('Canvas %i', getNextCanvasNum(obj.CanvasRegistry)), ...
                'HandleVisibility', 'callback', ...
                'Interruptible', 'on', ...
                'WindowButtonDownFcn', @obj.mouseClick, ...
                'WindowButtonUpFcn', @obj.mouseClick, ...
                'WindowButtonMotionFcn', @obj.mouseMove, ...
                'WindowScrollWheelFcn', @obj.mouseScroll, ...
                'SizeChangedFcn', @(src, ~)notify(src, 'SizeChanged'), ...
                'CloseRequestFcn', @obj.deleteInstance);
        end
        function initializeAxes(obj)
            if(~isempty(obj.Figure) && isvalid(obj.Figure))
                obj.Axes = axes(obj.Figure, ...
                    'Color', 'none', ...
                    'XLim', [-4 4], ...
                    'YLim', [-4 4], ...
                    'ZLim', [-4 4], ...
                    'XColor', 'none', ...
                    'YColor', 'none', ...
                    'ZColor', 'none', ...
                    'XTick', [], ...
                    'YTick', [], ...
                    'ZTick', [], ...
                    'XTickLabel', '', ...
                    'YTickLabel', '', ...
                    'ZTickLabel', '', ...
                    'Position', [0, 0, 1, 1], ...
                    'DataAspectRatioMode', 'manual', ...
                    'DataAspectRatio', [1, 1, 1], ...
                    'PlotBoxAspectRatioMode', 'manual', ...
                    'PlotBoxAspectRatio', [1, 1, 1], ...
                    'Projection', 'perspective', ...
                    'Clipping', 'off', ...
                    'NextPlot', 'replace', ...
                    'CameraUpVector', [0,1,0], ...
                    'CameraPosition', [0, 0, 12], ...
                    'CameraViewAngle', 60, ...
                    'HandleVisibility', 'callback');
            end
        end
        function initializeLight(obj)
            if(~isempty(obj.Axes) && isvalid(obj.Axes))
                obj.Light = light(obj.Axes);
                camlight(obj.Light, 'left');
            end
        end
        function updateFigureProperty(obj, prop, value)
            if(~isempty(obj.Figure) && isvalid(obj.Figure))
                set(obj.Figure, prop, value);
            end
        end
        function parseInputs(obj, varargin)
            params = varargin(1:2:end);
            values = varargin(2:2:end);
            for paramIdx = 1:numel(params)
                switch params{paramIdx}
                    case 'Visible'
                        obj.Visible = values{paramIdx};
                    otherwise
                        error('Unsupported parameter ''%s''./n', params{paramIdx})
                end
            end
        end
    end
end