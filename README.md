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

