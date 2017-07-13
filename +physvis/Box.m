classdef Box < physvis.Shape3D
%BOX Boxes or cubes in 3D space.
%   b = BOX() creates a unit box in 3D space centered at the origin of a
%   CANVAS.
% 
%   b = BOX(...,Name,Value) specifies properties using one or more
%   Name,Value pair arguments. For example, 'Color','r' sets the box
%   color to red.
%
%   See also SPHERE

% © Copyright 2017 The MathWorks, Inc.
% Author: James Kristoff

    properties
        Length = 1; % measure along the foward axis in the Frenet frame
        Height = 1; % measure along the normal (up) axis in the Frenet frame
        Width  = 1; % measure along the binormal axis in the Frenet frame
    end
    properties(Dependent)
        Size % [length height width] values
    end
    methods
        function obj = Box(varargin)
            % Box constructor
            
            % Create defaults
            createBox(obj);
            % Parse inputs
            parseInputs(obj, varargin{:})
        end
        function set.Length(obj, value)
            validateattributes(value, {'numeric'}, {'positive'})

            updateVertices(obj, value./obj.Length, 1);
            obj.Length = value;
        end
        function set.Height(obj, value)
            validateattributes(value, {'numeric'}, {'positive'})

            updateVertices(obj, value./obj.Height, 2);
            obj.Height = value;
        end
        function set.Width(obj, value)
            validateattributes(value, {'numeric'}, {'positive'})

            updateVertices(obj, value./obj.Width, 3);
            obj.Width = value;
        end
        function set.Size(obj, value)
            obj.Length = value(1);
            obj.Height = value(2);
            obj.Width = value(3);
        end
        function sz = get.Size(obj)
            sz = [obj.Length, obj.Height, obj.Width];
        end
    end
    methods(Access=protected)
        function updateVertices(obj, scaleFactor, dim)
            % Scale the length of a given dimension
            verts = obj.graphicObject.Vertices;
            if(nargin < 3)
                dim = 1:size(verts, 2);
            end
            verts(:, dim) = verts(:, dim) .* scaleFactor;
            obj.graphicObject.Vertices = verts;
        end
        function createBox(obj)
            % Create the faces and vertices defining the underlying patch
            % object

            faces = [ ...
                1, 4, 2; ...
                3, 2, 4; ...
                5, 6, 8; ...
                7, 8, 6; ...
                1, 2, 5; ...
                6, 5, 2; ...
                3, 4, 7; ...
                8, 7, 4; ...
                1, 5, 4; ...
                8, 4, 5; ...
                2, 3, 6; ...
                7, 6, 3];
            
            vertices = [ ...
                0, 1, 0; ...
                1, 1, 0; ...
                1, 0, 0; ...
                0, 0, 0; ...
                0, 1, 1; ...
                1, 1, 1; ...
                1, 0, 1; ...
                0, 0, 1]-0.5;

            obj.graphicObject = patch( ...
                'Faces', faces, ...
                'Vertices', vertices, ...
                'FaceColor', 'w', ...
                'FaceLighting', 'gouraud', ...
                'DiffuseStrength', 0.6, ...
                'SpecularExponent', 50, ...
                'SpecularStrength', 0.001, ...
                'AmbientStrength', 0.5, ...
                'EdgeColor', 'none', ...
                'Parent', obj.hgTransformObject);
        end
    end
end