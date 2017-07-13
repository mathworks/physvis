classdef Curve < physvis.Shape2D
%CURVE Curves in space.
%   CURVE creates a curve in 3D space that has no data and adds it to a
%   CANVAS. Add points to the curve in a loop to create an animation.
%   
%   Use APPEND to add more points.
% 
%   c = CURVE('Position',[x y z]) creates a curve with initial data
%   points defined by x, y, and z. Specify x, y, and z as scalars, not
%   vectors.
% 
%   c = CURVE(...,Name,Value) specifies curve properties using one or more
%   Name,Value pair arguments. For example, 'Color','r' sets the curve
%   color to red. Use this option with any of the input argument
%   combinations in the previous syntaxes.
% 
%   Example: 
%   t = linspace(0,4*pi);
% 
%   x = cos(t);
%   y = sin(t);
%   z = t;
% 
%   c = physvis.Curve('Position',[x(1) y(1) z(1)],'Retain',length(t));
% 
%   for k = 1 : length(t)
%       append(c, [x(k) y(k) z(k)]);
%   end
% 
%   See also POINTS

% © Copyright 2017 The MathWorks, Inc.
% Author: James Kristoff

    properties
        Radius = 0.01; % Radius of the curve's thickness
        Retain = 10; % Number of points retained in a trail
    end
    properties(Access = private)
        XData % x-coordinate data
        YData % y-coordinate data
        ZData % z-coordinate data
    end
    properties(Access = private, Constant)
        NumSides = 6; % Number of sides of the polygonal transverse cut of the curve
        MaxRetain = 1000; % Maximum value of points to retain
    end
    methods
        function obj = Curve(varargin)
            % Curve constructor

            createCurve(obj)
            % Parse inputs
            parseInputs(obj, varargin{:})
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
            if(size(obj.Position, 1) < 2)
                return
            end
            % Calulate new Curve points
            [trailXHead, trailYHead, trailZHead] = obj.tubecoords(obj.Position(1:2, :), obj.Radius, obj.NumSides);
            % update trail points
            if(~isempty(trailXHead))
                obj.XData = [trailXHead(2, :); obj.XData(1:end-1, :)];
                obj.YData = [trailYHead(2, :); obj.YData(1:end-1, :)];
                obj.ZData = [trailZHead(2, :); obj.ZData(1:end-1, :)];
                updateTrail(obj)
            end
        end
    end
    methods(Access = private)
        function createCurve(obj)

            createTrailPoints(obj)
            obj.graphicObject = surf(obj.XData, obj.YData, obj.ZData, ...
                'Parent', obj.hgTransformObject, ...
                'Visible', obj.Visible, ...
                'EdgeColor', 'none', ...
                'FaceColor', obj.Color, ...
                'FaceLighting', 'gouraud', ...
                'DiffuseStrength', 0.6, ...
                'SpecularExponent', 50, ...
                'SpecularStrength', 0.001, ...
                'AmbientStrength', 0.5, ...
                'LineStyle', 'none', ...
                'PickableParts', 'none', ...
                'Clipping', 'off', ...
                'HitTest', 'off', ...
                'Interruptible', 'off', ...
                'MeshStyle', 'column');
        end
        function updateRadius(obj)
            % Calulate new Curve points
            [trailXHead, trailYHead, trailZHead] = obj.tubecoords(obj.Position, obj.Radius, obj.NumSides);
            % update trail points
            if(~isempty(trailXHead))
                trailLength = size(trailXHead, 1);
                obj.XData(1:trailLength, :) = trailXHead;
                obj.YData(1:trailLength, :) = trailYHead;
                obj.ZData(1:trailLength, :) = trailZHead;
                updateTrail(obj);
            end
        end
        function createTrailPoints(obj)
            
            if(obj.Retain <= size(obj.Position, 1))
                posIdx = 1:obj.Retain;
            else
                posIdx = 1:size(obj.Position, 1);
            end
            obj.Position = [obj.Position(posIdx, :); NaN(obj.Retain-size(obj.Position, 1), 3)];

            if(obj.Retain <= size(obj.XData, 1))
                dataIdx = 1:obj.XData;
            else
                dataIdx = 1:size(obj.XData, 1);
            end
            toAdd = NaN(obj.Retain-size(obj.XData, 1), obj.NumSides+1);
            obj.XData = [obj.XData(dataIdx, :); toAdd];
            obj.YData = [obj.YData(dataIdx, :); toAdd];
            obj.ZData = [obj.ZData(dataIdx, :); toAdd];
            updateTrail(obj)
        end
        function updateTrail(obj, varargin)
            % return if the Canvas is empty
            if(isempty(obj.Canvas))
                return
            end
            if(~isvalid(obj.graphicObject) || isa(obj.graphicObject, 'matlab.graphics.GraphicsPlaceholder'))
                return
            end
                set(obj.graphicObject, ...
                'XData', obj.XData, ...
                'YData', obj.YData, ...
                'ZData', obj.ZData);
        end
    end
    methods(Access=private, Static)
        function [x,y,z]=tubecoords(verts, radius, n)
            
            d1 = diff(verts);
            zindex = find(~any(d1,2));
            verts(zindex,:) = [];
            
            if size(verts,1)<2
                x = []; y = []; z = [];
                return;
            end
            
            d1 = diff(verts);
            
            numverts = size(verts,1);
            unitnormals = zeros(numverts,3);
            
            % Radius of the tube.
            if length(radius)==1
                radius = repmat(radius, [numverts,1]);
            else
                radius(zindex) = [];
            end
            
            d1(end+1,:) = d1(end,:);
            
            x10 = verts(:,1)';
            x20 = verts(:,2)';
            x30 = verts(:,3)';
            x11 = d1(:,1)';
            x21 = d1(:,2)';
            x31 = d1(:,3)';
            
            a = verts(2,:) - verts(1,:);
            b = [0 0 1];
            c0 = NaN(1, 3);
            c = physvis.Curve.crossSimple(a,b,c0);
            if ~any(c)
                b = [1 0 0];
                c = physvis.Curve.crossSimple(a,b,c0);
            end
            b = physvis.Curve.crossSimple(c,a,c0);
            normb = norm(b); if normb~=0, b = b/norm(b); end
            %b = b*R(1);
            
            unitnormals(1,:) = b;
            
            for j = 1:numverts-1
                
                a = verts(j+1,:)-verts(j,:);
                c = physvis.Curve.crossSimple(a,b,c0);
                b = physvis.Curve.crossSimple(c,a,c0);
                normb = norm(b); if normb~=0, b = b/norm(b); end
                %  b = b*R(j);
                unitnormals(j+1,:) = b;
                
            end
            
            unitnormal1 = unitnormals(:,1)';
            unitnormal2 = unitnormals(:,2)';
            unitnormal3 = unitnormals(:,3)';
            
            speed = sqrt(x11.^2 + x21.^2 + x31.^2);
            
            % And the binormal vector ( B = T x N )
            binormal1 = (x21.*unitnormal3 - x31.*unitnormal2) ./ speed;
            binormal2 = (x31.*unitnormal1 - x11.*unitnormal3) ./ speed;
            binormal3 = (x11.*unitnormal2 - x21.*unitnormal1) ./ speed;
            
            % s is the coordinate along the circular cross-sections of the tube:
            s = (0:n)';
            s = (2*pi/n)*s;
            
            % Finally, the parametric surface.
            % Each of x1, x2, x3 is an (m+1)x(n+1) matrix.
            % Rows represent coordinates along the tube.  Columns represent coordinates
            % sgcfin each (circular) cross-section of the tube.
            
            xa1 = ones(n+1,1)*x10;
            xb1 = (cos(s)*unitnormal1 + sin(s)*binormal1);
            xa2 = ones(n+1,1)*x20;
            xb2 = (cos(s)*unitnormal2 + sin(s)*binormal2);
            xa3 = ones(n+1,1)*x30;
            xb3 = (cos(s)*unitnormal3 + sin(s)*binormal3);
            
            radius = repmat(radius(:)',[n+1,1]);
            x1 = xa1 + radius.*xb1;
            x2 = xa2 + radius.*xb2;
            x3 = xa3 + radius.*xb3;
            %x1 = xa1 + xb1;
            %x2 = xa2 + xb2;
            %x3 = xa3 + xb3;
            
            x = x1';
            y = x2';
            z = x3';
            
            %nx = unitnormal1;
            %ny = unitnormal2;
            %nz = unitnormal3;
        end
        
        % simple cross product
        function c=crossSimple(a,b,c)
            c(1) = b(3)*a(2) - b(2)*a(3);
            c(2) = b(1)*a(3) - b(3)*a(1);
            c(3) = b(2)*a(1) - b(1)*a(2);
        end
        
    end
    methods(Access=protected)
        function setGraphicsProperty(obj, prop, value)
            switch prop
                case 'Alpha'
                    if(~isempty(obj.graphicObject) && ~isa(obj.graphicObject, 'matlab.graphics.GraphicsPlaceholder') && isvalid(obj.graphicObject))
                        set(obj.graphicObject, 'FaceAlpha', obj.opacity);
                    end
                case 'Color'
                    if(numel(obj.Color) == 3 && ~isempty(obj.graphicObject) && ~isa(obj.graphicObject, 'matlab.graphics.GraphicsPlaceholder') && isvalid(obj.graphicObject))
                        set(obj.graphicObject, 'FaceColor', obj.Color);
                    end
                otherwise
                    setGraphicsProperty@physvis.Core(obj, prop, value);
            end
        end
    end
end