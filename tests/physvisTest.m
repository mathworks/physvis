classdef physvisTest < matlab.unittest.TestCase

% © Copyright 2017 The MathWorks, Inc.

    properties
        Canvas
    end
    methods(TestClassSetup)
    end
    methods(TestMethodSetup)
    end
    methods(TestMethodTeardown)
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
        function testSphere_EmptyConstructor(testCase)
            % SETUP
            import physvis.*
            % Exercise
            sphereDefaultObject = Sphere();
            % Verify
            testCase.verifyTrue(isvalid(sphereDefaultObject));
            % Cleanup
        end
        function testCurve_EmptyConstructor(testCase)
            % SETUP
            import physvis.*
            % Exercise
            curveDefaultObject = Curve();
            % Verify
            testCase.verifyTrue(isvalid(curveDefaultObject));
            % Cleanup
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Test class properties
        % Sphere
        function testSphere_Properties_PositionNotEmpty(testCase)
            % SETUP
            import physvis.*
            sphereDefaultObject = Sphere();
            % Exercise
            % Verify
            testCase.verifyNotEmpty(sphereDefaultObject.Position, 'Position should never be empty.');
            % Cleanup
        end
        function testSphere_Properties_XNotEmpty(testCase)
            % SETUP
            import physvis.*
            sphereDefaultObject = Sphere();
            % Exercise
            % Verify
            testCase.verifyNotEmpty(sphereDefaultObject.X, 'X should never be empty.');
            % Cleanup
        end
        function testSphere_Properties_YNotEmpty(testCase)
            % SETUP
            import physvis.*
            sphereDefaultObject = Sphere();
            % Exercise
            % Verify
            testCase.verifyNotEmpty(sphereDefaultObject.Y, 'Y should never be empty.');
            % Cleanup
        end
        function testSphere_Properties_ZNotEmpty(testCase)
            % SETUP
            import physvis.*
            sphereDefaultObject = Sphere();
            % Exercise
            % Verify
            testCase.verifyNotEmpty(sphereDefaultObject.Z, 'Z should never be empty.');
            % Cleanup
        end
        % Shape2d
        % Shape3d
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
