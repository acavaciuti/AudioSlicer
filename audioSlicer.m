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

[numSamples, numChannels] = size(inFile); 
if numChannels ~= 1 && numChannels ~= 2 
    error('Unsupported number of channels!'); 
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


if (numChannels == 1)
    fprintf(['Processing mono file', '\n']);

    % output data
    outFile = zeros(length(inFile),1);

    % slice boundaries
    sliceStarts = 1 : sliceSamples : numSamples;
    numSlices = length(sliceStarts);
    slices = cell(numSlices, 1);
    
    startIndex = 1.0;
    
    % fade setup
    fadeTime = 0.001;
    fadeSamples = floor(fadeTime * fs);
    fadeVal = 0;
    fadeIncr = 1/(fadeSamples);
    
    % slice extraction
    for i = 1:numSlices

        startIndex = sliceStarts(i);
        endIndex   = startIndex + sliceSamples;

        if endIndex > numSamples + 1
            break;
        end

        % Build time vector covering [start, end)
        t = startIndex : 1 : (endIndex - 1);

        % retrieve the interpolated slice
        localSlice = interp1(1:numSamples, inFile, t, 'linear', 0);
    
        % apply fade to slice
        for k = 1:fadeSamples
            localSlice(k) = localSlice(k) * fadeVal;
            localSlice(end-fadeSamples+k) = ...
                localSlice(end-fadeSamples+k) * (1 - fadeVal);
            fadeVal = fadeVal + fadeIncr;
        end
        fadeVal = 0;
    
        % store slice
        slices{i} = localSlice;

    end
    
    % create numSlices random numbers with no repeats
    randNums = randperm(numSlices);
    
    i = 1;
    for k=1:length(randNums)
        currentSlice = slices{randNums(k)};
        L = length(currentSlice);
        outFile(i:i+L-1) = currentSlice;
 
        i = i + L;  
    end
elseif (numChannels == 2)

    fprintf(['Processing stereo file', '\n']);

    % output data
    outFileL = zeros(length(inFile),1);
    outFileR = zeros(length(inFile),1);

    % slice boundaries
    sliceStarts = 1 : sliceSamples : numSamples;
    numSlices = length(sliceStarts);
    slicesL = cell(numSlices, 1);
    slicesR = cell(numSlices, 1);
    
    startIndex = 1.0;
    
    % fade setup
    fadeTime = 0.001;
    fadeSamples = floor(fadeTime * fs);
    fadeVal = 0;
    fadeIncr = 1/(fadeSamples);
    
    % slice extraction
    for i = 1:numSlices

        startIndex = sliceStarts(i);
        endIndex   = startIndex + sliceSamples;

        if endIndex > numSamples + 1
            break;
        end

        % Build time vector covering [start, end)
        t = startIndex : 1 : (endIndex - 1);

        % retrieve the interpolated slice
        localSliceL = interp1(1:numSamples, inFile(:,1), t, 'linear', 0);
        localSliceR = interp1(1:numSamples, inFile(:,2), t, 'linear', 0);
    
        % apply fade to slice
        for k = 1:fadeSamples
            localSliceL(k) = localSliceL(k) * fadeVal;
            localSliceL(end-fadeSamples+k) = ...
                localSliceL(end-fadeSamples+k) * (1 - fadeVal);

            localSliceR(k) = localSliceR(k) * fadeVal;
            localSliceR(end-fadeSamples+k) = ...
                localSliceR(end-fadeSamples+k) * (1 - fadeVal);

            fadeVal = fadeVal + fadeIncr;
        end
        fadeVal = 0;
    
        % store slice
        slicesL{i} = localSliceL;
        slicesR{i} = localSliceR;


    end
    
    % create numSlices random numbers with no repeats
    randNums = randperm(numSlices);
    
    i = 1;
    for k=1:length(randNums)
        currentSliceL = slicesL{randNums(k)};
        currentSliceR = slicesR{randNums(k)};
        L = length(currentSliceL);

        outFileL(i:i+L-1) = currentSliceL;
        outFileR(i:i+L-1) = currentSliceR;
 
        i = i + L;  
    end

    outFile(:,1) = outFileL;
    outFile(:,2) = outFileR;

else
    fprintf(['Unsupported number of channels!', '\n']);
end

fprintf(['Processing done', '\n']);
toc

end