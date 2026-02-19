# AudioSlicer
The audio slicer function takes an input .wav file of either mono or stereo channels, and splices it into slice sizes of your choosing, quantized to BPM. Then, the function uses randperm to put these slices into a random order. It then writes this to an output audio file. Use the main.m to run the audio slicer function; comments in main.m should be self explanitory for the audio slicer's arguments.

## Future Improvements / Features
There are a lot of things that could be done to improve the audio slicer:

- Allow for the slice size to change randomly as opposed to one slice size for the entire audio clip that is processed.
- Allow for a range, a min and max value, of the random slice that is chosen.
- Allow for the slice size to not be quantized to a BPM.
- Cross fade between the slices as opposed to the fade in and out.
- Improve the processing time of the function. The interp1 function in particular takes a lot of time.
