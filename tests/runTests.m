function runTests(varargin)

% © Copyright 2017 The MathWorks, Inc.

if(nargin > 0)
    testsToRun = varargin{1};
else
    testsToRun = '';
end

% get the directory that holds this function
rootPath = fileparts(mfilename('fullpath'));
% cd into a temp directory
if(ispc)
    oldFolder = cd('C:/Temp');
elseif(ismac || isunix)
    oldFolder = cd('/tmp');
else
    error('Only supported on Windows, Mac, and Linux.')
end
cleanup.location = onCleanup(@()cd(oldFolder));

testPaths = fullfile({rootPath, [rootPath, filesep, 'tests']});

% first add all tests to the path
originalPath = addpath(testPaths{:});
cleanup.path = onCleanup(@()path(originalPath));
% run all tests
coreTests = CoreTests;
if(isempty(testsToRun))
    results = coreTests.run();
else
    results = coreTests.run(testsToRun);
end
% check if tests passed
if(any([results.Failed]))
    if(verLessThan('matlab', '8.4'))
        failedTestNames = {results([results.Failed]).Name};
    else
        failedTestNames = results.table.Name(results.table.Failed == true);
    end
    failedTests = sprintf('\t%s\n', failedTestNames{:});
    fprintf('The following tests FAILED:\n%s', failedTests)
else
    disp('All tests PASSED.')
end
sphereTests = physvisTest;
if(isempty(testsToRun))
    results = sphereTests.run();
else
    results = sphereTests.run(testsToRun);
end
% check if tests passed
if(any([results.Failed]))
    if(verLessThan('matlab', '8.4'))
        failedTestNames = {results([results.Failed]).Name};
    else
        failedTestNames = results.table.Name(results.table.Failed == true);
    end
    failedTests = sprintf('\t%s\n', failedTestNames{:});
    fprintf('The following tests FAILED:\n%s', failedTests)
else
    disp('All tests PASSED.')
end
end