# Fishspy: Fish video analysis using numpy

[Fishspy](http://github.com/informatics-isi-edu/fishspy) is a batch
image analysis tool that processes movies of zebrafish. Fishspy is
being developed to support research involving live Zebrafish
undergoing behavior and memory tests.

## Status

Fishspy is experimental software that is subject to frequent changes in
direction depending on the needs of the authors.

## Analysis Method

To process whole movies rapidly, Fishspy uses a fast heuristic
depdendent on the setup where the fish is in a fixed orientation and
silhouetted:

1. Gaussian blur the movie to remove noise.
2. Find the 2 percentile darkest pixels in every vertical column of
   the movie frame.
3. Find the vertical centroid (center-of-mass of 1-bit mask image)
   for darkest pixels in every vertical column.
4. Consider the centroid as an approximate track of the fish's midline
   from head to tail.
5. Find the mean midline over certain horizontal intervals as a proxy
   for tail position.
6. Analyze time-series position to detect levels of tail activity.

At the same time, the global illumination average for each frame is
computed and used to identify phases of the experiment protocol
without relying on movie frame timecodes. Future versions of this tool
may start consuming timecodes as well.

### Performance and Scalability

The current tool can process a VGA resolution video at approximately
50 FPS with detailed results written to HDF5 as described below. With
that detailed HDF5 output disabled, processing speed exceeds 100
FPS. Both of these figures exceed the capture rate of 20 FPS.

The tool is written to process movies in a streaming fashion and
therefore has no intrinsic limit to the length of the movie. Due to
the use of MPEG-4 compression, the storage footprint for movies is
quite small, e.g. a 2.75 hour movie requires less than 90 MB of disk
space.

This analysis is largely sequential on a single CPU core, though
multiple movies can be trivially analyzed in parallel to increase
throughput.

## Using Fishspy

Fishspy is part of an experimental pipeline:

1. A zebrafish is fixed in the experiment apparatus such that it can
   move its tail but not otherwise swim out of frame.
2. A movie is captured while the light level and other environment is
   manipulated.
3. The movie is analyzed with `fishspy-analyze-movie` to produce a
   time-series dataset quantifying the fish's tail movements and
   ambient light levels.
4. The extracted time-series data is plotted with
   `fishspy-plot-results` to produce a compact rectangular heatmap
   representation of fish tail movements for each trial.

### Prerequisites

Fishspy is developed primarily on Linux with Python 2.7. It has
several requirements:

- [Numpy](http://www.numpy.org) numerical library to process
N-dimensional data.
- [Scipy](http://www.scipy.org) image processing library.
- [FFMPEG](http://www.ffmpeg.org) video encoding and decoding utility.

### Installation

0. Install all third-party prerequisites.
1. Check out the development code from GitHub for Fishspy
2. Install with `python setup.py install`.

### Capturing Movies

Fishspy assumes a movie has already been captured. It has been tested
with movies having the following characteristics:

1. The camera is looking down at a dorsal view of the fish.
2. The fish occupies the full frame horizontally with its anterior
   near the left edge of the movie frame and its tail tip near or
   beyond the right edge of the frame.
3. The movie captures at 20 FPS or so.
4. The movie is encoded with MPEG4 and decodes to an RGB image with
   the fish silhouetted against a light background in the first (red)
   channel. The other channels are ignored in the analysis.

### Analyzing Movies

1. Obtain a movie, e.g. `fish-movie.m4v`.
2. Launch the analysis `fishspy-analyze-movie fish-movie.m4v`
3. See the outputs, currently written to fixed names in the current
  working directory:
  - `movie_events.csv`: Rows with quantitative and qualitative
     measures for movie frames where fish activity was detected. This
     file is usually small enough to read with naive CSV readers.
  - `movie_frame_measures.csv`: One row per frame with quantitative
     measures. This file is quite long, e.g. 72K rows per hour.

### Plotting Results

1. Start with the two analysis outputs from the previous step.
2. Plot the results `fishspy-plot-results movie_events.csv movie_frame_measures.csv`
  - The first argument must be the movie events CSV file.
  - The second argument must be the frame measures CSV file.
  - Optional environment parameters `FISHSPY_US_CS_RATIO` and
    `FISHSPY_TRIAL_COUNTS` modify plotting behavior slightly by adding
    a magenta-colored unconditioned stimulus marker.
3. See the output, currently written to a fixed name in the current
   working directory:
  - `movie_plot.png`
  
The 2D plot represents time proceeding from top-left corner to
bottom-right corner:

- The time-series is split and resynchronized at each conditioned
  stimulus activation event, represented by the left-most vertical
  blue line.
- The _leading_ activity immediately before each conditioned stimulus
  period is shown preceding this left-most blue line.
- The right-most blue line represents the conditioned stimulus
  deactivation event for each trial. This boundary may appear ragged
  as each trial may have a different measured conditioned stimulus
  duration (as detected in the movie).
- Each horizontal stripe of 5 lines represents the five measures from
  `movie_frame_measures.csv`, which are displacement measurements at
  different sections of the fish tail.
- The total plot width is limited to the _median_ inter-trial
  period. This affects the plotting of _trailing_ activity following
  each stimulus period (at the edges of the plot):
  - Shorter trailing periods are padded
  - Longer trailing periods are truncated
- Intensity of the green plot represents absolute value of tail
  displacement on a frame-by-frame basis. This channel is
  range-compressed using the square root function.
- Temporary loss of tracking is depicted in red. This may happen
  briefly during rapid tail movements due to motion blur in the
  movie. A long period of red indicates persistent loss of tracking,
  usually due to the fish leaving the imaging stage or some
  debris obscuring view of the fish.

### Environment Parameters

Environment variables can be set to modify the behavior of the
`fishspy-analyze-movie` script.

- `DEBUG_MOVIE=true`: Enable output of `movie_debug.m4v` which
  includes each input frame with some additional markup illustrating
  the analysis.
- `FISHSPY_HDF5=true`: Enable output of `movie_frame_measures.hdf5`
  which includes more detailed positional information for each frame
  as a vector of mid-line positions for every vertical column of the
  movie.
- `FISHSPY_US_CS_RATIO=0.2`: For plotting, set ratio between
  unconditioned and conditioned stimulus periods, e.g. default `0.2`
  means 20 percent.
- `FISHSPY_TRIAL_COUNTS=H,L,T,R`: For plotting, set number of trials
  for each phase of experiment. Count _H_ is number of habituation
  rounds, _L_ is number of learning rounds, _T_ is number of testing
  rounds, and _R_ is number of retraining rounds. Specify `0` for any
  phase that is skipped.
- `FISHSPY_INVALID_BINS=0,0,...,1`: For plotting, specify a list of
  validity flags for frame-measurement bins. The comma-separated list
  should have the same number of elements as the number of bins in the
  `frame_measures.csv` file. It will be extended with `0` values if it
  is too short, or truncated if it is too long. Each `0` says to
  consider the bin to contain valid data, while `1` means to ignore
  that bin for plotting. This can be used, for example, to ignore the
  final bin if the tip of the tail loses tracking too often and fills
  the plot with red marks.

## Help and Contact

Please direct questions and comments to the [project issue
tracker](https://github.com/informatics-isi-edu/fishspy/issues) at
GitHub.

## License

Fishspy is made available as open source under the (new) BSD
License. Please see the [LICENSE
file](https://github.com/informatics-isi-edu/fishspy/blob/master/LICENSE)
for more information.

## About Us

Fishspy is developed as a collaboratioon between the
[Informatics group](http://www.isi.edu/research_groups/informatics/home)
of the [Information Sciences Institute](http://www.isi.edu), the
[Molecular and Computational Biology](https://dornsife.usc.edu/bisc/mcb/)
section, and the
[Translational Imaging Center](http://bioimaging.usc.edu) at the
[University of Southern California](http://www.usc.edu).

* Andrey Andreev
* Karl Czajkowski
* William P. Dempsey
* Thai V. Truong

