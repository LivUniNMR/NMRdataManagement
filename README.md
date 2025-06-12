# NMRdataManagement
Script for scraping Bruker NMR dataset information 

Simple shell script written by Rudi Grosman and adapted by Marie Phelan for scraping experiment information from Bruker formatted datasets
Caveats – works for linux (probably mac too) looking for info per dataset (so lots of experiments in one file)

Usage 
dataCheck.sh -e -f ./{MyNMRdataset} > output.tsv

This will export a tab separated volume containing the following fields in tab separated columns:

dataFolder {absolute path to NMR data at time of acquisition}
Field {Spectrometer field strength}
ExperimentNo {experiment number of the spectrum i.e. integer number name for spectra}
TimeStamp {date/time of the acquisition}
Title {free text stored in the title file of the experiment}
Holder {autosampler position}
Barcode {barcode recorded from NMR QR coded cap by autosampler - if available}
PulseProgram {pulseprogram used to acquire the data}
Temperature {temperature set in the VTU}
RG {receiver gain set for the acquisition}
NS {number of scans acquired}
Overflow {indicates if ADC overflowed during acquisition}
Overflow # {indicates number of scans in which ACD overflow occurred}

Each row will report on a different Bruker experiment in the dataset folder.
