classdef Shape2D < physvis.Core
%SHAPE2D Basic features of 2D visual objects.
    
% © Copyright 2017 The MathWorks, Inc.
% Author: James Kristoff

    properties
        Color % RGB color value
        Canvas % Canvas window
        Alpha = 1; % Transparency
    end
    properties(Dependent, GetAccess = public, SetAccess = private)
        Red   % red component of RGB color value
        Green % green component of RGB color value
        Blue  % blue component of RGB color value
    end
    properties(Access = private)
        CanvasRegistry = physvis.CanvasRegistry; % keep track of Canvas objects
    end
    methods
        function obj = Shape2D(varargin)
            obj.Color = Colors.rand();
            initializeCanvas(obj, varargin{:})
            % Parse inputs
            parseInputs(obj, varargin{:})
        end
        function set.Alpha(obj, value)
            
            % varify the value provided
            p = inputParser;
            validationFcn = @(x) (isnumeric(x) && numel(x) == 1 && x <= 1 && x >= 0);
            addRequired(p,'Alpha',validationFcn)
            parse(p, value)
            obj.Alpha = value;

            setGraphicsProperty(obj, 'Alpha', obj.Alpha)
        end
        function set.Color(obj, value)
            
            % varify the value provided
            value = Colors.validateColor(value);
            
            obj.Color = value;
            setGraphicsProperty(obj, 'Color', obj.Color)
        end
        function value = get.Red(obj)
            value = obj.Color(1);
        end
        function value = get.Green(obj)
            value = obj.Color(2);
        end
        function value = get.Blue(obj)
            value = obj.Color(3);
        end
        function set.Canvas(obj, value)
            if(isempty(value))
                return
            end
            if( ~isa(value, 'physvis.Canvas') )
                obj.error('InvalidCanvas', class(value) )
            end
            moveToNewCanvas(obj, value)
            obj.Canvas = value;
        end
    end
    methods(Access = protected)
        function moveToNewCanvas(obj, newCanvas)
            % Move to a new canvas
            setHgTransformProp(obj, 'Parent', newCanvas.Axes)
        end
        function initializeCanvas(obj, varargin)
            % Initialize a Canvas object
            params = varargin(1:2:end);
            if(isempty(params) || ~ismember('Canvas', params))
                activeCanvas = getActiveCanvas(obj.CanvasRegistry);
                if(~isempty(activeCanvas))
                    obj.Canvas = activeCanvas;
                else
                    obj.Canvas = physvis.Canvas('Visible', obj.Visible);
                end
            end
        end
        function setHgTransformProp(obj, prop, value)
            % Set hgTransform properties
            switch prop
                case 'Parent'
                    parent = obj.hgTransformObject.Parent;
                    if(isa(value, 'matlab.graphics.primitive.Transform') && ...
                            ~isequal(obj.hgTransformObject, value))
                        parent = value;
                    elseif(isa(value, 'physvis.Canvas'))
                        parent = value.Axes;
                    elseif(isa(value, 'matlab.graphics.axis.Axes'))
                        parent = value;
                    end
                    obj.hgTransformObject.Parent = parent;
                otherwise
                    setHgTransformProp@physvis.Core(obj, prop, value);
            end
        end
    end
end