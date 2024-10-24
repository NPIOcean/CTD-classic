https://gitlab.npolar.no/eds/other/oceanography-ctd/-/blob/main/workflow.md

Goals/ next steps:
- read in and binning RBR data onto same dethp bins as SBE CTD profiles -> use binned PAR profile for light index fit (Emeric)
- calcualte/ extract sensor values to compare with bottle samples (average +-2 m around individual btl depth)
- use teos-10 GSW package to derive potential density & N2 (https://teos-10.github.io/GSW-Python/density.html#density)
- look at CTD profiles and calcualte MLD based on different methods (compare with profile for QC)
- calibrate Chl-a sensor profiles based on bottle data using this recipy (https://data.npolar.no/dataset/b1504a66-9332-4f45-98ed-01450e1635f6):
    > Chlorophyll data were calibrated based on a linear fit of CTD fluorometer against bottle fluorescence measurements:
    >
    > First, the median value of dark counts at depth was determined based on measurements from 100 to 500 m depth.
    > A visual inspection confirmed that there were no offsets between profiles.
    > To calibrate the bottle Chl-a data to the bottle fluorescence measurements, we first only considered the bottle Chl-a value when the standard deviation of the bottle value divided by the fluorescence measurement was < 0.15, to avoid highly noisy parts of the fluorescence profile. Then we subtracted the offset value (1.0495) from the bottle fluorescence measurement, then we fit a linear regression with the bottle Chl-a measurement.

Products:
- Reference plots of individual CTD profile: T, S, sigma0, Chla; PAR (or attenuation coefficient, kd, deived as slope of the log fit of the profile)
- Temperature-Salinity diagram for identification of water masses
- depth integrated Chla values
- mixed layer depth (MLD)
- transect plot along fjord and at two cross sections, T, S, sigma0, Chla
