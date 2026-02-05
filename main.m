clear all
close all

[inFile, fs] = audioread("input.wav");
inFileL = inFile(:, 1);

BPM = 130;
sliceSize = 1;
[output] = audioSlicer(inFile, fs, BPM, sliceSize);

audiowrite("output.wav", output, fs);
