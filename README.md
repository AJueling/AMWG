# CESM's AMWG analysis package for IMAU's simulations

The cshell scripts are adapted to be used for analyzing the CESM simulations performed by the IMAU ocean group and stored on the file system of Surfsara's Cartesius HPC.

Need to make sure there is write access to the test_path_climo/diag folders.

## lines to be adjusted:
- [107ff.]  set location of files
- [126f.]   whether to compare to obs or other simulation 
- [140ff.]  if comparison with other simulations set these paths

## cases
- HIGH vs. LOW: 1/10 degree (CESM 1.04) vs. 1 degree (CESM 1.12) simulations
- CTRL vs. RCP: year 2000 constant control focring or RCP8.5 like (GHG only) forcing
