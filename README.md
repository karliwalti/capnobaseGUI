# README CAPNOBASE GUI

## Purpose
the CapnoBase GUI is a collection of matlab scripts to browse physiological time series and their annotations. 
It can also be used to create new annotations.

Currently two interfaces are available:


1. CapnoBase GUI Signal Evaluation: Tool 'StartGUI'
2. CapnoBase GUI Signal Browser: 'browseSignalsGUI2'

The evaluation tool is for importing, setting meta data, labels for inspiration and expiration, End Tidal CO2 and InspCO2, Volume capnograms, and rate trends, events, and signal quality.

The signal browser is a simplified version which displays two signals in one window. In addition it permits the visualisation of respiratory and cardiac cycles with cursers. 


## About
This tools has been developed 2009-2011 by Walter Karlen at the University of British Columbia.
It has been shared in 2023 under a open-source under a creative commons licence.
It accompanies a number of datasets (including benchmarks) with capnometric physiological signals recorded during general anesthesia. 
It includes capnometry, and photoplethysmography. 
This data is available at www.capnobase.org under a different licence. 

## Publications
If you using this tool, consider citing 

## Licence
This software comes with an MIT license. See LICENSE file

## Installation

### Requirements

1. Matlab. Not free. Available from Mathworks Inc.
2. A capnobase (www.capnobase.org) dataset (or prepare your own)

### Setup

1. You need to install matlab. 
2. Checkout git and browse to the root folder
3. Rename the 'settings.m.template' to 'settings.m'
4. Configure the parameters in 'settings.m'
- configure data folder. by default it is in the root folder

### Get started
1. run 'StartGUI.m' or 'browseSignalsGUI2.m' in Matlab

## Folders
data: default folder for datasets
utils: helperscripts useful for data handling
settings: temporary storage folder (cache)


## Contributing
Pull requests and bug fixes are highly welcome!

Please report issues and questions using the issue tracker.

## Know issues:

1. Warning: The EraseMode property is no longer supported and will error in a future release. 

