classdef CoreStub < physvis.Core
    
% © Copyright 2017 The MathWorks, Inc.

    methods
%         function dynProps = getdynamicProperties(obj)
%             dynProps = obj.dynamicProperties;
%         end
        function hgTransformObject = getHgTransformObject(obj)
            hgTransformObject = obj.hgTransformObject;
        end
        function graphicObject = getGraphicObject(obj)
            graphicObject = obj.graphicObject;
        end
    end
end