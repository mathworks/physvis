classdef CoreTests < matlab.unittest.TestCase
    
% © Copyright 2017 The MathWorks, Inc.

    properties
        Canvas
        CoreObject
    end
    methods(TestClassSetup)
    end
    methods(TestMethodSetup)
        function createCoreObject(testCase)
            % SETUP
            testCase.CoreObject = CoreStub();
        end
    end
    methods(TestMethodTeardown)
        function deleteCoreObject(testCase)
            if(isvalid(testCase.CoreObject))
                delete(testCase.CoreObject)
            end
        end
        function closeOpenCanvases(~)
            registry = physvis.CanvasRegistry;
            while(getNextCanvasNum(registry) > 1)
                delete(getActiveCanvas(registry))
            end
            delete(getActiveCanvas(registry))
        end
    end
    methods(TestClassTeardown)
%         function removeImportedPackage(~)
%             importedPackages = import;
%             if(ismember('physvis.*', importedPackages))
%                 clear('physvis.*')
%             else
%                 warning('Package: ''physvis.*'' was not imported properly.')
%             end
%         end
    end
    methods(Test)
        % test main window
        function testCore_EmptyConstructor(testCase)
            % Verify
            testCase.verifyTrue(isvalid(testCase.CoreObject));
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        %                   Test class properties
        %
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Check not empty
        function testCore_Properties_PositionNotEmpty(testCase)
            % Verify
            testCase.verifyNotEmpty(testCase.CoreObject.Position, 'Position should never be empty.');
        end
        function testCore_Properties_XNotEmpty(testCase)
            % Verify
            testCase.verifyNotEmpty(testCase.CoreObject.X, 'X should never be empty.');
        end
        function testCore_Properties_YNotEmpty(testCase)
            % Verify
            testCase.verifyNotEmpty(testCase.CoreObject.Y, 'Y should never be empty.');
            % Cleanup
        end
        function testCore_Properties_ZNotEmpty(testCase)
            % Verify
            testCase.verifyNotEmpty(testCase.CoreObject.Z, 'Z should never be empty.');
        end
        function testCore_Properties_VisibleNotEmpty(testCase)
            % Verify
            testCase.verifyNotEmpty(testCase.CoreObject.Visible, 'Visible should never be empty.');
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Check Set
        function testCore_Properties_Position_Set_3D(testCase)
            % Exercise
            originalPosition = testCase.CoreObject.Position;
            diffPosition_Expected = [1,1,1];
            testCase.CoreObject.Position = originalPosition + diffPosition_Expected;
            diffPosition_Actual = testCase.CoreObject.Position - originalPosition;
            % Verify
            testCase.verifyEqual(diffPosition_Actual, diffPosition_Expected, 'Position was not set correctly.');
        end
        function testCore_Properties_Position_Set_2D(testCase)
            % Exercise
            originalPosition = testCase.CoreObject.Position;
            diffPosition_Expected = [1, 1, originalPosition(3)];
            newPosition = originalPosition + diffPosition_Expected;
            testCase.CoreObject.Position = newPosition(1:2);
            diffPosition_Actual = testCase.CoreObject.Position - originalPosition;
            % Verify
            testCase.verifyEqual(diffPosition_Actual, diffPosition_Expected, 'Position was not set correctly.');
        end
        function testCore_Properties_Visible_Set_On(testCase)
            % Exercise
            testCase.CoreObject.Visible = 'on';
            % Verify
            testCase.verifyMatches(testCase.CoreObject.Visible, 'on', 'Visible property was not set to ''on'' correctly.');
        end
        function testCore_Properties_Visible_Set_Off(testCase)
            % Exercise
            testCase.CoreObject.Visible = 'off';
            % Verify
            testCase.verifyMatches(testCase.CoreObject.Visible, 'off', 'Visible property was not set to ''off'' correctly.');
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Check Get
        function testCore_Properties_X_Get(testCase)
            testCase.CoreObject.Position = [1, 0, 0];
            x = testCase.CoreObject.X;
            testCase.verifyEqual(x, 1, 'X property was not stored or retrieved correctly.');
        end
        function testCore_Properties_Y_Get(testCase)
            testCase.CoreObject.Position = [0, 1, 0];
            y = testCase.CoreObject.Y;
            testCase.verifyEqual(y, 1, 'Y property was not stored or retrieved correctly.');
        end
        function testCore_Properties_Z_Get(testCase)
            testCase.CoreObject.Position = [0, 0, 1];
            z = testCase.CoreObject.Z;
            testCase.verifyEqual(z, 1, 'Z property was not stored or retrieved correctly.');
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Check subsasgn && subsref
        %{
        function testCore_Properties_CreateDynamic(testCase)
            % Setup
            publicProperties = properties(testCase.CoreObject);
            uniquePropertyNames = matlab.lang.makeUniqueStrings([publicProperties; 'foo']);
            dynamicProperty = uniquePropertyNames{end};
            dynamicPropertyValue = 1;
            % Exercise
            testCase.CoreObject.(dynamicProperty) = dynamicPropertyValue;
            % Verify
            testCase.verifyTrue(ismember(dynamicProperty, properties(testCase.CoreObject)), 'Dynamic property was not created.')
        end
        %}
        %{
        function testCore_Properties_SetDynamic(testCase)
            % Setup
            publicProperties = properties(testCase.CoreObject);
            uniquePropertyNames = matlab.lang.makeUniqueStrings([publicProperties; 'foo']);
            dynamicProperty = uniquePropertyNames{end};
            dynamicPropertyValue = 1;
            % Exercise
            testCase.CoreObject.(dynamicProperty) = dynamicPropertyValue;
            % Verify
            testCase.verifyEqual(testCase.CoreObject.(dynamicProperty), dynamicPropertyValue, 'Dynamic property was not set correctly.')
        end
        %}
        %{
        function testCore_Properties_SetDynamic_Cell(testCase)
            % Setup
            publicProperties = properties(testCase.CoreObject);
            uniquePropertyNames = matlab.lang.makeUniqueStrings([publicProperties; 'foo']);
            dynamicProperty = uniquePropertyNames{end};
            dynamicPropertyValue = {'foo', 'bar'};
            testCase.CoreObject.(dynamicProperty) = dynamicPropertyValue;
            % Exercise
            testCase.CoreObject.(dynamicProperty){1} = 'notFoo';
            % Verify
            testCase.verifyMatches(testCase.CoreObject.(dynamicProperty){1}, 'notFoo', 'Dynamic property was not set correctly.')
        end
        %}
        %{
        function testCore_Properties_SetDynamic_Array(testCase)
            % Setup
            publicProperties = properties(testCase.CoreObject);
            uniquePropertyNames = matlab.lang.makeUniqueStrings([publicProperties; 'foo']);
            dynamicProperty = uniquePropertyNames{end};
            dynamicPropertyValue = 1:10;
            testCase.CoreObject.(dynamicProperty) = dynamicPropertyValue;
            % Exercise
            testCase.CoreObject.(dynamicProperty)(1) = -1;
            % Verify
            testCase.verifyEqual(testCase.CoreObject.(dynamicProperty)(1), -1, 'Dynamic property was not set correctly.')
        end
        %}
        %{
        function testCore_Properties_Dynamic_ObjectArray(testCase)
            % Setup
            testCase.CoreObject(4) = CoreStub;
            publicProperties = properties(testCase.CoreObject);
            uniquePropertyNames = matlab.lang.makeUniqueStrings([publicProperties; 'foo']);
            dynamicProperty = uniquePropertyNames{end};
            dynamicPropertyValue = 1;
            linearIndices = 1:2:4;
            inverseLinearIndices = 2:2:4;
            % Exercise
            testCase.CoreObject(linearIndices).(dynamicProperty) = dynamicPropertyValue;
            % Verify
            testCase.verifyTrue(all([testCase.CoreObject(linearIndices).(dynamicProperty)] == dynamicPropertyValue), 'Dynamic property was not set correctly.')
            testCase.verifyTrue(~any(isprop(testCase.CoreObject(inverseLinearIndices), dynamicProperty)), 'Dynamic property was created for the non-indexed array object.')
        end
        %}
        %{
        function testCore_Properties_Dynamic_ObjectArray_LogicalIndexing(testCase)
            % Setup
            testCase.CoreObject(4) = CoreStub;
            publicProperties = properties(testCase.CoreObject);
            uniquePropertyNames = matlab.lang.makeUniqueStrings([publicProperties; 'foo']);
            dynamicProperty = uniquePropertyNames{end};
            dynamicPropertyValue = 1;
            logicalIndices = [true, false, true, false];
            % Exercise
            testCase.CoreObject(logicalIndices).(dynamicProperty) = dynamicPropertyValue;
            % Verify
            testCase.verifyTrue(all([testCase.CoreObject(logicalIndices).(dynamicProperty)] == dynamicPropertyValue), 'Dynamic property was not set correctly.')
            testCase.verifyTrue(~any(isprop(testCase.CoreObject(~logicalIndices), dynamicProperty)), 'Dynamic property was created for the non-indexed array object.')
        end
        %}
        %{
        function testCore_Properties_BuiltIn_ObjectArray(testCase)
            % Setup
            testCase.CoreObject(4) = CoreStub;
            for objIdx = 1:numel(testCase.CoreObject)
                testCase.CoreObject(objIdx).Visible = 'on';
            end
            linearIndices = 1:2:4;
            inverseLinearIndices = 2:2:4;
            % Exercise
            testCase.CoreObject(linearIndices).Visible = 'off';
            % Verify
            testCase.verifyTrue(all(ismember({testCase.CoreObject(linearIndices).Visible}, 'off')), 'Property was not set correctly.')
            testCase.verifyTrue(~any(ismember({testCase.CoreObject(inverseLinearIndices).Visible}, 'off')), 'Property was changed for one or more non-indexed array object(s).')
        end
        %}
        %{
        function testCore_Properties_BuiltIn_ObjectArray_LogicalIndexing(testCase)
            % Setup
            testCase.CoreObject(4) = CoreStub;
            for objIdx = 1:numel(testCase.CoreObject)
                testCase.CoreObject(objIdx).Visible = 'on';
            end
            logicalIndices = [true, false, true, false];
            % Exercise
            testCase.CoreObject(logicalIndices).Visible = 'off';
            % Verify
            testCase.verifyTrue(all(ismember({testCase.CoreObject(logicalIndices).Visible}, 'off')), 'Property was not set correctly.')
            testCase.verifyTrue(~any(ismember({testCase.CoreObject(~logicalIndices).Visible}, 'off')), 'Property was changed for one or more non-indexed array object(s).')
        end
        %}
        %{
        function testCore_Properties_BuiltIn_ObjectArray_Batch(testCase)
            % Setup
            testCase.CoreObject(4) = CoreStub;
            for objIdx = 1:numel(testCase.CoreObject)
                testCase.CoreObject.Visible = 'on';
            end
            % Exercise
            testCase.CoreObject.Visible = 'off';
            % Verify
            testCase.verifyTrue(all(ismember({testCase.CoreObject.Visible}, 'off')), 'Property was not set correctly.')
        end
        %}
        %{
        function testCore_Properties_BuiltIn_ObjectArray_CreateElement(testCase)
            % Setup
            numObjs = 4;
            testCase.CoreObject(numObjs) = CoreStub;
            for objIdx = 1:numel(testCase.CoreObject)
                testCase.CoreObject.Visible = 'on';
            end
            % Exercise
            testCase.CoreObject(numObjs+1).Visible = 'off';
            % Verify
            testCase.verifyTrue(strcmp(testCase.CoreObject(numObjs+1).Visible, 'off'), 'Array was not extended or the property was not set correctly.')
        end
        %}
        %{
        function testCore_Properties_Dynamic_ObjectArray_Heterogeneous(testCase)
            % Setup
            numObjs = 4;
            testCase.CoreObject(numObjs) = CoreStub;
            publicProperties = properties(testCase.CoreObject);
            uniquePropertyNames = matlab.lang.makeUniqueStrings([publicProperties; 'foo']);
            dynamicProperty = uniquePropertyNames{end};
            dynamicPropertyValue = 1;
            % Exercise
            testCase.CoreObject(1).(dynamicProperty) = dynamicPropertyValue;
            % Verify
            testCase.verifyEqual(testCase.CoreObject(1).(dynamicProperty), dynamicPropertyValue, 'Dynamic property was not set correctly.')
            testCase.verifyTrue(isequaln([testCase.CoreObject.(dynamicProperty)], [dynamicPropertyValue, NaN(1, numObjs - 1)]), 'Dynamic property was not set correctly.')
        end
        %}
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Negative Tests
        function testCore_Properties_X_Set(testCase)
            % Exercise
            ME = [];
            try
                testCase.CoreObject.X = 1;
            catch ME
            end
            % Verify
            testCase.assumeNotEmpty(ME, 'The X property was set without an error.')
            testCase.verifyMatches(ME.identifier, 'MATLAB:class:SetProhibited', 'Unexpected error thrown') % [class(testCase.CoreObject), ':SetProhibitedNotReadOnly']
        end
        function testCore_Properties_Y_Set(testCase)
            % Exercise
            ME = [];
            try
                testCase.CoreObject.Y = 1;
            catch ME
            end
            % Verify
            testCase.assumeNotEmpty(ME, 'The Y property was set without an error.')
            testCase.verifyMatches(ME.identifier, 'MATLAB:class:SetProhibited', 'Unexpected error thrown') % [class(testCase.CoreObject), ':SetProhibitedNotReadOnly']
        end
        function testCore_Properties_Z_Set(testCase)
            % Exercise
            ME = [];
            try
                testCase.CoreObject.Z = 1;
            catch ME
            end
            % Verify
            testCase.assumeNotEmpty(ME, 'The Z property was set without an error.')
            testCase.verifyMatches(ME.identifier, 'MATLAB:class:SetProhibited', 'Unexpected error thrown') % [class(testCase.CoreObject), ':SetProhibitedNotReadOnly']
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        %                   Test class constructor
        %
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        function testCore_Constructor_Empty(testCase)
            % Exercise
            testCase.CoreObject = physvis.Core();
            % Verify
            testCase.verifyTrue(isa(testCase.CoreObject, 'physvis.Core'), 'An empty constructor failed to instantiate an object.')
        end
        function testCore_Constructor_Set_Position(testCase)
            % Setup
            positionValue = [1, 2, 3];
            % Exercise
            testCase.CoreObject = physvis.Core('Position', positionValue);
            % Verify
            testCase.verifyTrue(isa(testCase.CoreObject, 'physvis.Core') && isequal(testCase.CoreObject.Position, positionValue), 'Constructor failed to instantiate an object and set its Position.')
        end
        % Negative Tests
        function testCore_Constructor_Odd_Inputs(testCase)
            % Exercise
            ME = [];
            try
                testCase.CoreObject = physvis.Core('X');
            catch ME
            end
            % Verify
            testCase.assumeNotEmpty(ME, 'The Core object was created without an error.')
            testCase.verifyMatches(ME.identifier, 'Core:InvalidNumberOfArgs', 'Unexpected error thrown')
        end
%             % Verify
%             testCase.verifyMatches(get(dialogHandle, 'Name'), 'App at Latest Version', 'App not reinstalled as expected.')
%             testCase.verifyFalse(logical(status), 'An update was found.');
%             testCase.assumeNotEmpty(dialogHandle, 'No dialog was returned.')
%             testCase.assumeTrue(logical(status), sprintf('resources dir was not created:\n%s', message));
%             testCase.assumeNumElements(matVarsBefore, 1, '.mat file had more or less than one variable in it.');
%             testCase.assumeMatches(matVarsBefore{:}, 'notFoo', 'AppData .mat file was not created successfully.');
%             testCase.verifyFalse(foo, 'AppData was not correctly found and/or the variable ''foo'' was not correctly loaded.');
%             testCase.verifyEqual(exist(appDataMat,'file'), 2, 'AppData .mat file was not created.')
    end
end
