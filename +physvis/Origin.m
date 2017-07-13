classdef Origin < physvis.Sphere
%ORIGIN Visual guide to orient the viewer at the camera target of a Canvas.
%   See also CANVAS
    
% © Copyright 2017 The MathWorks, Inc.
% Author: James Kristoff
    
methods
    function obj = Origin(varargin)
        % Read in the texture map and apply it to the origin's surface
        im = imread('resources\origin.png');
        obj.graphicObject.FaceColor = 'texturemap';
        obj.graphicObject.CData = im;
        % Customize the transparency of the origin
        obj.Alpha = 1;
        imBw = mean(im, 3) > 0;
        obj.graphicObject.FaceAlpha = 'texturemap';
        obj.graphicObject.AlphaData = imBw;
        % Rotate the origin by 90 degrees to align with the texture map
        obj.Transform = obj.hgTransformObject.Matrix * makehgtform('xrotate', pi/2);

        parseInputs(obj, varargin{:})
    end
end
end