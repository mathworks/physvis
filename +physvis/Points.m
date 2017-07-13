classdef Points < physvis.Shape2D
%POINTS A series of visual points in space.
%   POINTS creates a point in 3D space that has no data and adds it to a
%   CANVAS. Add points to the series in a loop to create an animation.
%   
%   Use APPEND to add more points.
% 
%   p = POINTS('Position',[x y z]) creates a series of points with initial
%   data points defined by x, y, and z. Specify x, y, and z as scalars, not
%   vectors.
% 
%   p = POINTS(...,Name,Value) specifies point properties using one or more
%   Name,Value pair arguments. For example, 'Color','r' sets the point
%   series color to red. Use this option with any of the input argument
%   combinations in the previous syntaxes.
% 
%   Example: 
%   t = linspace(0,4*pi);
% 
%   x = cos(t);
%   y = sin(t);
%   z = t;
% 
%   p = physvis.Points('Position',[x(1) y(1) z(1)],'Retain',length(t));
% 
%   for k = 1 : length(t)
%       append(p, [x(k) y(k) z(k)]);
%   end
% 
%   See also CURVE

% © Copyright 2017 The MathWorks, Inc.
% Author: James Kristoff

    properties
        Radius = 0.125; % Radius of the Points
        Retain = 10; % Number of points retained in a trail
    end
    properties(Access = private)
        OriginalCameraPos % Original camera position
        camPosListener % Camera position listener
        figPosListener % Figure position listener
    end
    properties(Access = private, Constant)
        MaxRetain = 1000; % Maximum value of points to retain
    end
    methods
        function obj = Points(varargin)
            % Points constructor

            createPoints(obj)
            % Parse inputs
            parseInputs(obj, varargin{:})
            % Create Listeners
            obj.OriginalCameraPos = obj.Canvas.Axes.CameraPosition;
            metaInfo = metaclass(obj.Canvas.Axes);
            metaProps = metaInfo.PropertyList(ismember({metaInfo.PropertyList.Name}, 'CameraPosition'));
            obj.camPosListener = event.proplistener(obj.Canvas.Axes, metaProps,'PostSet',@obj.updateRadius);
            obj.figPosListener = event.listener(obj.Canvas.Figure, 'SizeChanged', @obj.updateRadius);
        end
        function set.Radius(obj, value)
            validateattributes(value, {'numeric'}, {'positive'})
            obj.Radius = value;
            updateRadius(obj)
        end
        function set.Retain(obj, value)
            validateattributes(value, {'numeric'}, {'positive', '<=', obj.MaxRetain})
            obj.Retain = value;
            createTrailPoints(obj)
        end
        function append(obj, newPosition)
            % Append values to the trail

            obj.Position = [newPosition; obj.Position(1:end-1, :)];
            updateTrail(obj)
        end
    end
    methods(Access = private)
        function createPoints(obj)
            % Create an animatedLine object to represent the Points object
            obj.graphicObject = animatedline( ...
                'Parent', obj.hgTransformObject, ...
                'Visible', obj.Visible, ...
                'LineStyle', 'none', ...
                'Marker', 'o', ...
                'Color', obj.Color, ...
                'MarkerFaceColor', obj.Color, ...
                'MaximumNumPoints', obj.Retain);
        end
        function pointsValue = data2points(obj, dataValue)
            % convert value in the units of the axes to the 'points' unit.
            % Value is assumed to be located at the camera's target

            hAxis = obj.Canvas.Axes;
            currentUnits = hAxis.Units;
            hAxis.Units='Points';
            clean.units = onCleanup(@()set(obj.Canvas.Axes, 'Units', currentUnits));
            axPos = hAxis.Position;
            pba = hAxis.PlotBoxAspectRatio;
            axPos = [axPos(3), pba(1)/pba(2)*axPos(4)];
            [~, minAxisIdx] = min(axPos);

            cameraPos = (obj.Canvas.Axes.CameraPosition - obj.Canvas.Axes.CameraTarget);
            viewDiameter = norm(cameraPos)*2/sqrt(3);
            conversionRatio = axPos(minAxisIdx)/viewDiameter;

            pointsValue = dataValue .* conversionRatio;
        end
        function updateRadius(obj, varargin)
            % Update the radius
            pointsValue = data2points(obj, obj.Radius);
            setGraphicsProperty(obj, 'MarkerSize', pointsValue)
        end
        function createTrailPoints(obj)
            % Create trail points
            obj.Position = ones(obj.Retain, 3).*obj.Position(1, :);
            if(isvalid(obj.graphicObject) && ~isa(obj.graphicObject, 'matlab.graphics.GraphicsPlaceholder'))
                set(obj.graphicObject, 'MaximumNumPoints', obj.Retain);
                [x,y,z] = getpoints(obj.graphicObject);
                obj.Position(1:numel(x), 1) = x;
                obj.Position(1:numel(y), 2) = y;
                obj.Position(1:numel(z), 3) = z;
            end
        end
        function updateTrail(obj, varargin)
            % Update the trail
            
            % return if the Canvas is empty or invalid
            if(isempty(obj.Canvas) || ~isvalid(obj.Canvas))
                return
            end
            addpoints(obj.graphicObject, ...
                obj.Position(1, 1), ...
                obj.Position(1, 2), ...
                obj.Position(1, 3))
        end
    end
    methods(Access=protected)
        function setGraphicsProperty(obj, prop, value)
            switch prop
                case 'Color'
                    if(~isempty(obj.graphicObject) && ~isa(obj.graphicObject, 'matlab.graphics.GraphicsPlaceholder') && isvalid(obj.graphicObject))
                        obj.graphicObject.Color = obj.Color;
                        obj.graphicObject.MarkerFaceColor = obj.Color;
                    end
                otherwise
                    setGraphicsProperty@physvis.Core(obj, prop, value);
            end
        end
    end
end