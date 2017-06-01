#
# Copyright 2017 University of Southern California
# Distributed under the GNU GPL 3.0 license. See LICENSE for more info.
#

""" Installation script for Synapse Upload
"""
import os
from setuptools import setup, find_packages

setup(
    name="synapse-upload",
    description="Synapse Upload Tools",
    url='https://github.com/informatics-isi-edu/fishspy/uploader',
    maintainer='USC Information Sciences Institute ISR Division',
    maintainer_email='misd-support@isi.edu',
    version="0.1.0",
    packages=find_packages(),
    package_data={'synapse-upload': ['conf/config.json']},
    data_files=[(os.path.expanduser(os.path.normpath(
                "~/.deriva/synapse/synapse-upload")), ['conf/config.json'])],
    entry_points={
        'console_scripts': [
            'synapse-upload = synapse_upload.upload:main'
        ]
    },
    requires=[
        'os',
        'sys',
        'logging',
        'deriva_common',
        'deriva_io'],
    license='Apache 2.0',
    classifiers=[
        'Intended Audience :: Science/Research',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: Apache Software License',
        "Operating System :: POSIX",
        "Operating System :: MacOS :: MacOS X",
        "Operating System :: Microsoft :: Windows",
        'Programming Language :: Python',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5'
    ]
)

