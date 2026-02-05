function [outFile] = audioSlicer(inFile, fs, BPM, sliceSize)
% Inputs:
%   inFile: Source audio signal to be processed
%   fs: inFile sample rate
%   BPM: BPM of input audio signal
%   SliceSize: Size of slice: 
        % 0 = 1/32 note
        % 1 = 1/16 note
        % 2 = 1/8 note
        % 3 = 1/4 note
        % 4 = 1/2 note
        % 5 = 1 bar
        % 6 = 2 bars
        % 7 = 4 bars
% Outputs:
%   outFile: Spliced audio signal
tic

mono = 0;
stereo = 0;

if (size(inFile, 2) == 1)
    mono = 1;
    stereo = 0;

elseif (size(inFile, 2) == 2)
    mono = 0;
    stereo = 1;
else
    mono = 0;
    stereo = 0;
end


switch sliceSize
    case 0 % 1/32 note
        sliceSamples = fs * (7.5 / BPM);
    case 1 % 1/16 note
        sliceSamples = fs * (15 / BPM);
    case 2 % 1/8 note
        sliceSamples = fs * (30 / BPM);
    case 3 % 1/4 note
        sliceSamples = fs * (60 / BPM);
    case 4 % 1/2 note
        sliceSamples = fs * (120 / BPM);
    case 5 % 1 bar
        sliceSamples = fs * (240 / BPM);
    case 6 % 2 bars
        sliceSamples = fs * (480 / BPM);
    case 7 % 4 bar
        sliceSamples = fs * (960 / BPM);
    otherwise % default to quarter
        sliceSamples = fs * (60 / BPM);
end

sliceSamplesInt = round(sliceSamples);

if (mono)
    fprintf(['Processing mono file', '\n']);
    outFile = zeros(length(inFile),1);
    numSlices = floor((length(inFile) - sliceSamplesInt) / sliceSamples) + 1;
    arrayOfSlices = zeros(sliceSamplesInt, numSlices);
    
    startIndex = 1.0;
    i = 1;
    
    fadeTime = 0.001;
    fadeSamples = floor(fadeTime * fs);
    fadeSamples = min(fadeSamples, floor(sliceSamplesInt/2));
    fadeVal = 0;
    fadeIncr = 1/(fadeSamples);
    
    % loop through input file and put into slices
    while (startIndex + sliceSamplesInt - 1) <= length(inFile)

        % the slice of samples we need to interpolate from out inFile
        t = startIndex + (0:sliceSamplesInt-1);
    
        % retrieve the interpolated slice
        localSlice = interp1(1:length(inFile), inFile, t, 'linear', 0);
    
        % apply fade to slice
        for k = 1:fadeSamples
            localSlice(k) = localSlice(k) * fadeVal;
            localSlice(end-fadeSamples+k) = ...
                localSlice(end-fadeSamples+k) * (1 - fadeVal);
            fadeVal = fadeVal + fadeIncr;
        end
        fadeVal = 0;
    
        % store slice
        arrayOfSlices(:, i) = localSlice(:);
    
        % advance position with fractional samples
        startIndex = startIndex + sliceSamples;
        i = i + 1;

    end
    
    % create numSlices random numbers with no repeats
    randNums = randperm(numSlices);
    
    i = 1;
    for k=1:length(randNums)
        % use the random numbers to pick slices from our data
        outFile(i:i+sliceSamplesInt-1) = arrayOfSlices(:, randNums(k));
        % increment our position in the output file
        i = i + sliceSamplesInt;
    end
elseif (stereo)

    fprintf(['Processing stereo file', '\n']);

    outFileL = zeros(length(inFile(:,1)), 1);
    outFileR = zeros(length(inFile(:,2)), 1);
    
    numSlices = floor((length(inFile(:,1)) - sliceSamplesInt) / sliceSamples) + 1;
    
    arrayOfSlicesL = zeros(sliceSamplesInt, numSlices);
    arrayOfSlicesR = zeros(sliceSamplesInt, numSlices);
    
    startIndex = 1.0;
    i = 1;
    
    fadeTime = 0.001;
    fadeSamples = floor(fadeTime * fs);
    fadeSamples = min(fadeSamples, floor(sliceSamples/2));
    fadeVal = 0;
    fadeIncr = 1 / fadeSamples;
    
    N = length(inFile(:,1));
    
    % loop through input file and put into slices
    while (startIndex + sliceSamplesInt - 1) <= N
    
        % the slice of samples we need to interpolate from out inFile
        t = startIndex + (0:sliceSamplesInt-1);

        % retrieve the interpolated slices
        localSliceL = interp1(1:N, inFile(:,1), t, 'linear', 0);
        localSliceR = interp1(1:N, inFile(:,2), t, 'linear', 0);
    
        % apply fades
        for k = 1:fadeSamples
            localSliceL(k) = localSliceL(k) * fadeVal;
            localSliceR(k) = localSliceR(k) * fadeVal;
    
            localSliceL(end-fadeSamples+k) = ...
                localSliceL(end-fadeSamples+k) * (1 - fadeVal);
            localSliceR(end-fadeSamples+k) = ...
                localSliceR(end-fadeSamples+k) * (1 - fadeVal);
    
            fadeVal = fadeVal + fadeIncr;
        end
        fadeVal = 0;
    
        % store slices
        arrayOfSlicesL(:, i) = localSliceL(:);
        arrayOfSlicesR(:, i) = localSliceR(:);
    
        % advance position with fractional samples
        startIndex = startIndex + sliceSamples;
        i = i + 1;
    
    end
    
    % randomize slice order
    randNums = randperm(numSlices);
    
    i = 1;
    for k = 1:length(randNums)
    
        outFileL(i:i+sliceSamplesInt-1) = arrayOfSlicesL(:, randNums(k));
        outFileR(i:i+sliceSamplesInt-1) = arrayOfSlicesR(:, randNums(k));
    
        i = i + sliceSamplesInt;
    end
    
    outFile(:,1) = outFileL;
    outFile(:,2) = outFileR;

else
    fprintf(['Unsupported number of channels!', '\n']);
end

fprintf(['Processing done', '\n']);
toc

end