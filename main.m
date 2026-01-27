clear all
close all

[inFile, fs] = audioread("Cornish.wav");
inFileL = inFile(:, 1);

BPM = 130;
sliceSize = 7;
[output] = audioSlicer(inFileL, fs, BPM, sliceSize);

audiowrite("output.wav", output, fs);
