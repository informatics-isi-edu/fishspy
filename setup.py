
#
# Copyright 2015 University of Southern California
# Distributed under the (new) BSD License. See LICENSE.txt for more info.
#

from distutils.core import setup

setup(
    name="fishspy",
    description="zebrafish video analysis",
    version="0.1-prerelease",
    scripts=[
        "bin/fishspy-analyze-movie",
        "bin/fishspy-plot-results",
        "bin/fishspy_worker"
    ],
    requires=["numpy", "scipy"],
    maintainer_email="support@misd.isi.edu",
    license='(new) BSD',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Science/Research',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Operating System :: POSIX',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2.7',
    ])
