classdef Colors <  matlab.mixin.SetGet
%COLORS basic colors.
    
% © Copyright 2017 The MathWorks, Inc.
    
    properties(Constant)
        red     = [001,000,000]
        orange  = [255,165,000]./255
        yellow  = [001,001,000]
        green   = [000,001,000]
        blue    = [000,000,001]
        b       = Colors.blue
        indigo  = [075,000,130]./255
        violet  = [238,130,238]./255
        white   = [001,001,001]
        black   = [000,000,000]
        k       = Colors.black
        cyan    = [000,001,001];
        magenta = [001,000,001];
    end
    
    methods(Static)
        function rgb = rand()
            allColors = properties(Colors);
            allColors(ismember(allColors, 'black')) = [];
            propLengths = cellfun(@numel, allColors);
            uniqueColors = allColors(propLengths > 1);
            colorIdx = randi(numel(uniqueColors), 1);
            color = uniqueColors{colorIdx};
            rgb = Colors.(color);
        end
        function value = validateColor(value)
            
            if(ischar(value))
                value = Colors.str2rgb(value);
            end
            
            validateattributes(value, {'double', 'single', 'uint8'}, {'numel', 3})
            if isa(value, 'uint8')
                value = double(value)./255;
            end
            validateattributes(value, {'double', 'single'}, {'>=', 0, '<=', 1})
        end
        function rgb = str2rgb(colorStr)
            rgb = get(Colors, colorStr);
        end
    end
end
