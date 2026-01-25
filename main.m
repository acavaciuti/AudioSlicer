clear all
close all

[inFile, fs] = audioread("pianoLoop.wav");
inFileL = inFile(:, 1);

BPM = 120;
sliceSize = 2;
[output] = soundSplicer(inFileL, fs, BPM, sliceSize);




audiowrite("output.wav", output, fs);
