clear all
close all

[inFile, fs] = audioread("input.wav");

BPM = 120;
% For sliceSize:
% 0 = 1/32 note
% 1 = 1/16 note
% 2 = 1/8 note
% 3 = 1/4 note
% 4 = 1/2 note
% 5 = 1 bar
% 6 = 2 bars
sliceSize = 3;

[output] = audioSlicer(inFile, fs, BPM, sliceSize);

audiowrite("output.wav", output, fs);
