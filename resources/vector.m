classdef vector < matlab.mixin.SetGetExactNames
%VECTOR 3-vectors in space.

% © Copyright 2017 The MathWorks, Inc.
% Author: James Kristoff

    properties
        x
        y
        z
    end
    properties(Dependent, Access=private)
        data
    end
    methods
        function obj = vector(x, y, z)
            if(nargin < 3)
                z = 0;
            end
            if(nargin < 2)
                y = 0;
            end
            if(nargin < 1)
                x = 0;
            end
            obj.x = x;
            obj.y = y;
            obj.z = z;
        end
        function value = get.data(obj)
            value = [obj.x; obj.y; obj.z];
        end
        function set.data(obj, value)
            obj.x = value(1, :);
            obj.y = value(2, :);
            obj.z = value(3, :);
        end
        %------------------------------------------------------------------
        % Overloaded methods
        function varargout = subsref(obj,S)
            switch S(1).type
                case '.'
                    if length(S) == 1
                        % Implement obj.PropertyName
                        varargout = {obj.(S.subs)};
                    elseif length(S) == 2 && strcmp(S(2).type,'()')
                        % Implement obj.PropertyName(indices)
                        varargout = {obj.(S(1).subs)(S(2).subs{:})};
                    else
                        varargout = {builtin('subsref', obj, S)};
                    end
                case '()'
                    if length(S) == 1
                        % Implement obj(indices)
                        if(numel(obj) == 1)
                            varargout = {obj.data(S.subs{:})};
                        else
                            varargout = {obj(S.subs{:}).data};
                        end
                    else
                        % Use built-in for any other expression
                        varargout = {builtin('subsref', obj, S)};
                    end
                case '{}'
                    % Use built-in for any other expression
                    varargout = {builtin('subsref', obj, S)};
                otherwise
                    error('Not a valid indexing expression')
            end
        end
%         function value = subsref(obj, S)
%             if((numel(S) >= 1) && strcmp(S(end).type, '()'))
%                 value = obj.data(S(end).subs{:});
%             else
%                 value = builtin('subsref', obj, S);
%             end
%         end
        function e = end(obj, ind, nind)
            % END Overloaded end for x objects
            if(~isequal(ind, nind))
                e = size(obj.data, ind) * size(obj.data, nind);
            else
                e = size(obj.data, ind);
            end
        end
        function out = mrdivide(obj, B)

            if(isa(B, 'vector'))
                divideData = B.data;
            elseif(isnumeric(B))
                divideData = B;
            else
                error('Undefined operator ''./'' for input arguments of type ''%s''\n', class(B))
            end
            try
                obj.data = obj.data/divideData;
            catch ME
                throwAsCaller(ME)
            end
            out = obj.data;
        end
        function out = rdivide(obj, B)

            if(isa(B, 'vector'))
                divideData = B.data;
            elseif(isnumeric(B))
                divideData = B;
            else
                error('Undefined operator ''./'' for input arguments of type ''%s''\n', class(B))
            end
            try
                obj.data = obj.data./divideData;
            catch ME
                throwAsCaller(ME)
            end
            out = obj.data;
        end
        function out = plus(obj, B)

            if(isa(B, 'vector'))
                addData = B.data;
            elseif(isnumeric(B))
                addData = B;
            else
                error('Undefined operator ''+'' for input arguments of type ''%s''\n', class(B))
            end
            try
                obj.data = obj.data + addData;
            catch ME
                throwAsCaller(ME)
            end
            out = obj.data;
        end
    end
end