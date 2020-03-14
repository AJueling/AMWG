# CESM's AMWG analysis package for IMAU's simulations

The cshell scripts are adapted to be used for analyzing the CESM simulations performed by the IMAU ocean group and stored on the file system of Surfsara's Cartesius HPC.

Need to make sure there is write access to the test_path_climo/diag folders.

## lines to be adjusted:
- [107ff.]  set location of files
- [126f.]   whether to compare to obs or other simulation 
- [140ff.]  if comparison with other simulations set these paths

## cases
- HIGH vs. LOW: 1/10 degree (CESM 1.04) vs. 1 degree (CESM 1.12) simulations
- "RCP":  RCP8.5 like (GHG only) forcing,  years (2070-2099)-(2000-2029)
- "CTRL_vs_OBS": compare year 2000 control constant forcing (years 200-229 (500-529) for HIGH (LOW)) to observations
