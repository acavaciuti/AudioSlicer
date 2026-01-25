clear all
close all

[inFile, fs] = audioread("Cornish.wav");
inFileL = inFile(:, 1);

BPM = 120;
sliceSize = 3;
[output] = soundSplicer(inFileL, fs, BPM, sliceSize);




audiowrite("output.wav", output, fs);
