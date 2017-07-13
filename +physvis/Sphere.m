classdef Sphere < physvis.Shape3D
%SPHERE Spheres in 3D space.
%   s = SPHERE() generates three 32-by-32 matrices so that SURF(X,Y,Z)
%   produces a unit sphere centered at the origin.
% 
%   p = SPHERE(...,Name,Value) specifies properties using one or more
%   Name,Value pair arguments. For example, 'Color','r' sets the sphere
%   color to red.
%
%   See also BOX

% © Copyright 2017 The MathWorks, Inc.
% Author: James Kristoff

    properties
        Radius = 1; % radius of the sphere
    end
    methods
        function obj = Sphere(varargin)
            % Sphere constructor
            
            % Create defaults
            edgesPerCircumference = 32;
            [X, Y, Z] = sphere(edgesPerCircumference - 1);
            obj.graphicObject = surf(X, Y, Z, ...
                'FaceColor', obj.Color, ...
                'FaceLighting', 'gouraud', ...
                'DiffuseStrength', 0.6, ...
                'SpecularExponent', 50, ...
                'SpecularStrength', 0.001, ...
                'AmbientStrength', 0.5, ...
                'LineStyle', 'none', ...
                'Parent', obj.hgTransformObject);
            % do this to initialize trail radius
            obj.Radius = obj.Radius;
            % Parse inputs
            parseInputs(obj, varargin{:})
        end
        function set.Radius(obj, value)
            validateattributes(value, {'numeric'}, {'positive'})
            scale(obj, value/obj.Radius);
            obj.Radius = value;
            obj.TrailRadius = value.*0.25;
        end
    end
end