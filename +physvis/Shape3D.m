classdef Shape3D < physvis.Shape2D
%SHAPED3D Basic features of 3D visual objects.
    
% © Copyright 2017 The MathWorks, Inc.
% Author: James Kristoff

    properties
        Retain = 10; % Number of points retained in a trail
        HasTrail = false; % Whether or not the object has a trail
        TrailType = 'points'; % TrailType is either 'points' or 'curve'
        TrailRadius = 0.125; % Radius of the trail
    end
    properties(SetObservable)
        Axis = [1, 0, 0]; % Forward facing axis in the Frenet frame
        Up   = [0, 1, 0]; % Normal axis axis in the Frenet frame
    end
    properties(GetAccess = public, SetAccess = ?physvis.Core)
        TrailObject % The PHYSVIS shape (geometry) class used to make a trail
    end
    properties(Access = protected)
        PreviousAxis = [1, 0, 0]; % previous foward axis in the Frenet frame 
        PreviousUp = [0, 1, 0]; % previous normal axis in the Frenet frame
        SettingAxis = false; % whether or not the forward axis is being set
        SettingUp = false; % whether or not the Up axis is being set
    end
    properties(Access = private)
        posListener
        axisListener
        upListener
    end
    properties(Constant)
        % Property to optimize the updateOrientation function
        IdentityMatrix = eye(4);
    end
    
    methods
        function obj = Shape3D(varargin)
            % Shape3D constructor
            
            % create listeners
            obj.axisListener = addlistener(obj,'Axis','PreSet',@obj.setPreviousAxis);
            obj.upListener = addlistener(obj,'Up','PreSet',@obj.setPreviousUp);
            obj.posListener = addlistener(obj,'Position','PostSet',@obj.updateTrail);
            % set default values
            obj.Retain = 10;
            % Parse inputs
            parseInputs(obj, varargin{:})
        end
        function delete(obj)
            % Delete the trail object
            if(~isempty((obj.TrailObject)) && isvalid(obj.TrailObject))
                delete(obj.TrailObject);
            end
        end
        function set.Axis(obj, newAxis)
            obj.Axis = newAxis;
            updateOrientation(obj, 'Axis')
        end
        function set.Up(obj, newUp)
            obj.Up = newUp;
            updateOrientation(obj, 'Up')
        end
        function set.Retain(obj, value)
            obj.Retain = value;
            setTrailProperty(obj, 'Retain', obj.Retain)
        end
        function set.TrailType(obj, value)
            validateattributes(value, {'char'}, {'vector', 'nonempty'})
            % varify the value provided
            p = inputParser;
            validationFcn = @(x)ismember(x, {'curve', 'points'});
            addRequired(p, 'TrailType', validationFcn)
            parse(p, value)
            
            if(~strcmp(value, obj.TrailType))
                obj.TrailType = value;
                createTrail(obj);
            end
        end
        function set.HasTrail(obj, value)
            if(~(islogical(value) || isnumeric(value)))
                obj.error('invalidLogicalProperty', 'HasTrail')
            end
            if(~isscalar(value))
                obj.error('invalidScalarProperty', 'HasTrail')
            end
            previousTrailStatus = obj.HasTrail;
            obj.HasTrail = logical(value);
            if(logical(value) && (isempty(previousTrailStatus) || ~previousTrailStatus))
                createTrail(obj)
            end
            if(~logical(value) && (~isempty(previousTrailStatus) && previousTrailStatus))
                deleteTrail(obj)
            end
        end
        function set.TrailRadius(obj, value)
            obj.TrailRadius = value;
            setTrailProperty(obj, 'Radius', value)
        end
        function Rotate(obj, theta, axis, origin)
            %ROTATE rotate the 3D shape(s).
            %   Rotate(obj, theta, axis, origin) rotates the 3D shape(s) in
            %   obj by theta radians about the provided axis, around the
            %   specified origin.  If the origin is not provided, the
            %   position of the shape is used.
            if(nargin < 3)
                error('This function Requres at least an axis and an angle as inputs.')
            end
            rotationMatrix = arbitraryRotation_ThetaAxis(theta, axis);
            % Update the Axis and Up vectors for all the shapes
            tol = 1e-15;
            for shape = obj
                if(nargin < 4)
                    origin = shape.Position;
                end
                posDiff = shape.Position - origin;
                % If the specified origin is different from the shape's
                % position, then move the shape to the new position
                if(sum(abs(posDiff)) > tol)
                    newPosition = rotationMatrix*[posDiff, 1]';
                    shape.Position = origin + newPosition(1:3)';
                end
                % Rotate the shape's Axis vector
                tmpAxis = [shape.Axis, 1]*rotationMatrix;
                tmpAxis(4) = [];
                % If the Axis vector didn't move, update the Up vector
                if(sum(abs(tmpAxis - shape.Axis)) < tol)
                    % Rotate the shape's Up vector
                    tmpUp = [shape.Up, 1]*rotationMatrix;
                    tmpUp(4) = [];
                    % If the Up vector did not move, return
                    if(sum(abs(tmpUp - shape.Up)) < tol)
                        return
                    else
                        shape.Up = tmpUp;
                    end
                else
                    shape.Axis = tmpAxis;
                end
            end
        end
    end
    methods(Access = protected)
        function moveToNewCanvas(obj, newCanvas)
            moveToNewCanvas@physvis.Shape2D(obj, newCanvas)
            setTrailProperty(obj, 'Canvas', newCanvas)
        end
        function setGraphicsProperty(obj, prop, value)
            
            switch prop
                case 'Alpha'
                    if(~isempty(obj.graphicObject) && ~isa(obj.graphicObject, 'matlab.graphics.GraphicsPlaceholder') && isvalid(obj.graphicObject))
                        set(obj.graphicObject, 'FaceAlpha', obj.Alpha)
                    end
                case 'Color'
                    if(numel(obj.Color) == 3 && ~isempty(obj.graphicObject) && ~isa(obj.graphicObject, 'matlab.graphics.GraphicsPlaceholder') && isvalid(obj.graphicObject))
                        set(obj.graphicObject, 'FaceColor', obj.Color)
                    end
                    % only update the trail property if one exists
                    if(obj.HasTrail)
                        setTrailProperty(obj, 'Color', obj.Color)
                    end
                case 'Position'
                    if(isvalid(obj.hgTransformObject) && isprop(obj.hgTransformObject, 'Matrix'))
                        move(obj, value);
                    end
                otherwise
                    setGraphicsProperty@physvis.Core(obj, prop, value);
            end
        end
    end
    methods(Access = private)
        function updateOrientation(obj, whatToUpdate)
            if(~(obj.SettingAxis || obj.SettingUp))
                switch whatToUpdate
                    case 'Axis'
                        obj.SettingAxis = true;
                    case 'Up'
                        obj.SettingUp = true;
                    otherwise
                        error('Can only update ''Axis'', or ''Up'', not ''%s''.\n', whatToUpdate)
                end
            end
            if(obj.SettingAxis && strcmp(whatToUpdate, 'Axis'))
                rotationMatrix = arbitraryRotation(obj.Axis, obj.PreviousAxis);
                if(isequal(rotationMatrix, obj.IdentityMatrix))
                    obj.SettingAxis = false;
                    obj.SettingUp = false;
                    return
                end
                temp = [obj.Up, 1] * rotationMatrix;
                obj.Up = temp(1:3);
            elseif(obj.SettingUp && strcmp(whatToUpdate, 'Up'))
                rotationMatrix = arbitraryRotation(obj.Up, obj.PreviousUp);
                if(isequal(rotationMatrix, obj.IdentityMatrix))
                    obj.SettingAxis = false;
                    obj.SettingUp = false;
                    return
                end
                temp = [obj.Axis, 1] * rotationMatrix;
                obj.Axis = temp(1:3);
            else
                return
            end
            obj.Transform = transformMultiply(obj.Transform, rotationMatrix); % a*b
            obj.SettingAxis = false;
            obj.SettingUp = false;
        end
        function setTrailProperty(obj, prop, value)
            if(~isempty(obj.TrailObject) && isvalid(obj.TrailObject))
                obj.TrailObject.(prop) = value;
            end
        end
        function deleteTrail(obj)
            if(~isempty(obj.TrailObject) && isvalid(obj.TrailObject))
                delete(obj.TrailObject)
            end
        end
        function createTrail(obj)
            if(obj.HasTrail && ~isempty(obj.Canvas))
                switch obj.TrailType
                    case 'curve'
                        if(isempty(obj.TrailObject) || ~isa(obj.TrailObject, 'physvis.Curve') || ~isvalid(obj.TrailObject))
                            obj.TrailObject = physvis.Curve('Canvas', obj.Canvas, ...
                                'Position', obj.Position, ...
                                'Color', obj.Color, ...
                                'Retain', obj.Retain, ...
                                'Radius', obj.TrailRadius, ...
                                'Visible', obj.Visible);
                        end
                    case 'points'
                        if(isempty(obj.TrailObject) || ~isa(obj.TrailObject, 'physvis.Points') || ~isvalid(obj.TrailObject))
                            obj.TrailObject = physvis.Points('Canvas', obj.Canvas, ...
                                'Position', obj.Position, ...
                                'Color', obj.Color, ...
                                'Retain', obj.Retain, ...
                                'Radius', obj.TrailRadius, ...
                                'Visible', obj.Visible);
                        end
                end
            end
        end
        % Listener Callbacks
        function updateTrail(obj, ~, ~)
            if(~obj.HasTrail)
                return
            end
            append(obj.TrailObject, obj.Position);
        end
        function setPreviousAxis(obj, ~, ~)
            if(~isequal(obj.PreviousAxis, obj.Axis))
                obj.PreviousAxis = obj.Axis;
            end
        end
        function setPreviousUp(obj, ~, ~)
            if(~isequal(obj.PreviousUp, obj.Up))
                obj.PreviousUp = obj.Up;
            end
        end
    end
end