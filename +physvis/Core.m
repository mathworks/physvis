classdef Core < handle
%CORE properties and functions for most objects in PHYSVIS Toolbox.

% © Copyright 2017 The MathWorks, Inc.
% Author: James Kristoff

    properties
        Visible = 'on'; % the visible state of the object's visual representation
        UserData = [];  % a property to be used for storing any custom data
    end
    properties(Dependent, GetAccess = public, SetAccess = private)
        X % X component of the (x,y,z) position
        Y % Y component of the (x,y,z) position
        Z % Z component of the (x,y,z) position
    end
    properties(SetObservable)
        Position = [0,0,0]; % Current position of the object
    end
    properties(Access = protected)
        Transform = eye(4); % transformation matrix
        hgTransformObject % hgTransform object
        graphicObject % the object's visual representation
    end
    properties(Access = private)
        CleanUp = [];
    end
    methods
        function obj = Core(varargin)
            % Creates a Core visual object with default properties

            warnStruct = warning('off', 'MATLAB:hg:DiceyTransformMatrix');
            obj.CleanUp = onCleanup(@()warning(warnStruct));
            % Initialize property defaults
            obj.hgTransformObject = hgtransform( ...
                'Parent', matlab.graphics.axis.Axes.empty());
            obj.graphicObject = matlab.graphics.GraphicsPlaceholder;
            % Parse inputs
            parseInputs(obj, varargin{:})
        end
        function delete(obj)
            % Delete the graphics object
            if(~isempty(obj.graphicObject) && isvalid(obj.graphicObject))
                delete(obj.graphicObject);
            end
            % Delete the hgTransform object
            if(~isempty(obj.hgTransformObject) && isvalid(obj.hgTransformObject))
                delete(obj.hgTransformObject);
            end
            if(~isempty(obj.CleanUp) && isvalid(obj.CleanUp))
                delete(obj.CleanUp);
            end
        end
        %------------------------------------------------------------------
        %   Setters and Getters
        function set.Visible(obj, value)
            % Set the Visible state of the graphic object
            
            % Check that the provided value's type and dimension
            validateattributes(value, {'char'}, {'scalartext'})
            % varify the value provided
            p = inputParser;
            validationFcn = @(x) ismember(x, {'on', 'off'});
            addRequired(p,'Visible', validationFcn)
            parse(p, value)

            obj.Visible = value;
            % Set the Visible property for the hgTransform object
            setHgTransformProp(obj, 'Visible', obj.Visible)
        end
        function set.graphicObject(obj, value)
            % verify the value is a valid MATLAB graphics object
            validateattributes(value, {'matlab.graphics.Graphics'}, {'scalar'})
            obj.graphicObject = value;
            % Move the graphics object into the hgTransform
            moveGraphicObjectToTransform(obj)
        end
        function set.Position(obj, value)
            % Set the Position of this object
            
            if( ~isnumeric(value) || ~any(size(value, 2) == [2, 3]))
                ME = error(obj, 'InvalidPositionSize');
                throwAsCaller(ME);
            end
            % if only 2 values were provided, assume the third dimension is
            % zero.
            if(size(value, 2) == 2)
                value(:, 3) = zeros(size(value, 1));
            end
            obj.Position = value;
            % set the Position property of the graphics object
            setGraphicsProperty(obj, 'Position', value)
        end
        function set.Transform(obj, value)
            
            obj.Transform = value;
            setTransformMatrix(obj);
        end
        function set.X(obj, value)
            obj.Position(:, 1) = value;
        end
        function set.Y(obj, value)
            obj.Position(:, 2) = value;
        end
        function set.Z(obj, value)
            obj.Position(:, 3) = value;
        end
        function value = get.X(obj)
            value = obj.Position(:, 1);
        end
        function value = get.Y(obj)
            value = obj.Position(:, 2);
        end
        function value = get.Z(obj)
            value = obj.Position(:, 3);
        end
        %------------------------------------------------------------------
        % Overloaded methods
        function ME = error(obj, messageID, varargin)
            % custom error function for physvis.Core objects
            ME = MException([regexprep(class(obj), '^([^\.]*\.)+', ''), ':', messageID], ...
                message(obj, messageID), varargin{:});
            if(nargout < 1)
                throwAsCaller(ME)
            end
        end
    end
    methods(Access = private)
        function moveGraphicObjectToTransform(obj)
            
            % Move the hgTransform to the graphics object's parent
            if(isprop(obj.graphicObject, 'Parent') && ...
                    ~isa(obj.graphicObject.Parent, 'matlab.graphics.GraphicsPlaceholder'))
                setHgTransformProp(obj, 'Parent', obj.graphicObject.Parent)
            end
            % Then set the Graphics Object's Parent to be the hgTransform
            setGraphicsProperty(obj, 'Parent', obj.hgTransformObject)
        end
    end
    methods(Static, Access = private)
        function resourcePath = resourcePath()
            % return the location of the 'resources' folder
            filePath = mfilename('fullpath');
            rootPath = fileparts(filePath);
            resourcePath = regexprep(rootPath, '\+[^$]*', 'resources');
        end
    end
    methods(Access = protected)
        function scale(obj, varargin)
            % Scales the hgtransform by the provided scaling factor(s)
            M = makehgtform('scale', varargin{:});
            obj.Transform = obj.Transform*M;
        end
        function move(obj, pos)
            % Moves the hgtransform to the provided position
            obj.Transform(1:3, 4) = pos(:);
        end
        function setTransformMatrix(obj)
            % Set hgTransform matrix
            obj.hgTransformObject.Matrix = obj.Transform;
        end
        function messageString = message(obj, messageId)
            % Returns the custom message associated with the given
            % messageId.  The messages are stored in an xml document, which
            % can be found in the 'resources' folder.
            resourcePath = physvis.Core.resourcePath();
            documentDom = xmlread(fullfile(resourcePath, 'messages.xml'));
            messageCatalog = documentDom.getDocumentElement;
            idNodes = messageCatalog.getElementsByTagName('id');
            ids = arrayfun(@(idx)char(idNodes.item(idx).getTextContent), 0:idNodes.getLength-1, 'UniformOutput', false)';
            stringNodes = messageCatalog.getElementsByTagName('string');
            if(any(ismember(ids, messageId)))
                itemIdx = find(ismember(ids, messageId))-1;
                messageString = char(stringNodes.item(itemIdx).getTextContent);
            else
                error(obj, 'IdNotFound', messageId); %#ok<CTPCT>
            end
        end
        function setHgTransformProp(obj, prop, value)
            % Set any properties of the hgtransform object.  This function
            % will likely be overridden by any subclasses for custom
            % behavior
            if(ismember(prop, properties(obj.hgTransformObject)) && ~isequal(value, obj.hgTransformObject))
                obj.hgTransformObject.(prop) = value;
            end
        end
        function setGraphicsProperty(obj, prop, value)
            % set any properties of the graphic object.  This function
            % will likely be overridden by any subclasses for custom
            % behavior
            if(isprop(obj.graphicObject, prop))
                obj.graphicObject.(prop) = value;
            end
        end
        function parseInputs(obj, varargin)
            % Parse inputs
            params = varargin(1:2:end);
            values = varargin(2:2:end);
            % Validate number of inputs
            if(numel(params) ~= numel(values))
                throwAsCaller(error(obj, 'InvalidNumberOfArgs'))
            end
            invalidPropsIdx = ~ismember(params, properties(obj));
            if(any(invalidPropsIdx))
                for prop = params(invalidPropsIdx)
                    throwAsCaller(error(obj, 'SetProhibitedNotReadOnly', prop{:}, class(obj))) %#ok<CTPCT>
                end
            end
            % assign values to validated params
            for paramIdx = 1:numel(params)
                obj.(params{paramIdx}) = values{paramIdx};
            end
        end
    end
end