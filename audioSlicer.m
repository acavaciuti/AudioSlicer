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

% TODO: Process mono or stereo input file.

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

sliceSamples = floor(sliceSamples);


outFile = zeros(length(inFile),1);
numSlices = floor(length(inFile) / sliceSamples);
arrayOfSlices = zeros(sliceSamples, numSlices);

startIndex = 1;
endIndex = sliceSamples;
samplesConsumed = 0;
i = 1;

fadeTime = 0.001;
fadeSamples = floor(fadeTime * fs);
fadeVal = 0;
fadeIncr = 1/(fadeSamples);

% loop through input file and put into slices
while samplesConsumed < length(inFile)

    localSlice = inFile(startIndex:endIndex);

    % apply a fade in and out to the captured slice
    for k=1:fadeSamples
        localSlice(k) = localSlice(k) * fadeVal;
        localSlice(end-fadeSamples+k) = localSlice(end-fadeSamples+k)*(1-fadeVal);
        fadeVal = fadeVal + fadeIncr;
    end
    % fade is done for this slice, reset fade val
    fadeVal = 0;

    % place the slice into our data array
    arrayOfSlices(:, i) = localSlice;

    % increment positional values
    startIndex = startIndex + sliceSamples;
    endIndex = endIndex + sliceSamples;
    samplesConsumed = samplesConsumed + sliceSamples;
    i = i + 1;

    % when we have data left that is not a full slice just end 
    if (endIndex >= length(inFile))
        break
    end    
end

% create numSlices random numbers with no repeats
randNums = randperm(numSlices, numSlices);

i = 1;
for k=1:length(randNums)
    % use the random numbers to pick slices from our data
    outFile(i:i+sliceSamples-1) = arrayOfSlices(:, randNums(k));
    % increment our position in the output file
    i = i + sliceSamples;
end
end