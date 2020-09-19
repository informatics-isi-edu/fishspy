# Miscellaneous Matlab functions

## Contents

### Scripts

These scripts are used to organize data from TFC behavioral experiments. Each of these files contains a function that was created and tested in Matlab 2019a. These are mainly Matlab scripts used to analyze Tail Flick Conditioning (TFC) from the [synapse data management system](synapse.isrd.isi.edu), which is where the raw data and resulting Graphpad files can be viewed.

1. organizeTrials.m is a Matlab function that outputs excel files with flick ratios for habituation, training, and testing rounds that occur during TFC protocol (see Methods). This script should be used in conjunction with fishspy-plot-results in [fishspy](https://github.com/informatics-isi-edu/fishspy).
2. APV_Trials.m is a Matlab function that outputs excel files with flick ratios for testing rounds for +APV treated (or -APV control) fish. This script should be used in conjunction with fishspy-plot-results in [fishspy](https://github.com/informatics-isi-edu/fishspy).
3. extinctionTrials.m is a Matlab function that outputs excel files with flick ratios for testing rounds during extinction experiments. This script should be used in conjunction with fishspy-plot-results in [fishspy](https://github.com/informatics-isi-edu/fishspy).
4. memoryRetentionTrials.m is a Matlab function that outputs excel files with flick ratios for two blocks of testing, (i) after training, as usual, and (ii) after an 85 minute rest. This script should be used in conjunction with fishspy-plot-results in [fishspy](https://github.com/informatics-isi-edu/fishspy).
5. zebrafishSizeOrganization.m is a Matlab function that outputs excel files with numbers of learners, nonlearners, and partial learners after TFC at two distinct size ranges: (i) between 4.0 and 4.5 and (ii) between 4.6 and 5.0. This script should be used in conjunction with fishspy-plot-cohort in [fishspy](https://github.com/informatics-isi-edu/fishspy).
6. zebrafishInjStatus.m is a Matlab function that outputs excel files with numbers of learners, nonlearners, and partial learners after TFC, separating fish into two categories: injected versus uninjected. The function also outputs the flick ratios for testing rounds. This script should be used in conjunction with fishspy-plot-cohort in [fishspy](https://github.com/informatics-isi-edu/fishspy).