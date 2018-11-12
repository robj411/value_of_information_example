# value_of_information_example

To run the example using the saved samples, save 'evppi_example_5000_samples.Rds' and run
install.packages('mgcv')

Run the script 'master_script.R'. It will load the saved samples. Then, it will compute and plot EVPPI.

###############################################

To run the example generating new samples, save the files 'constants.Rds' and 'pollution_model_functions.R'.

Run
install.packages('mgcv')
install.packages('distr')
install.packages('tensorA')

Run the script 'master_script.R'.

This will load constants.Rds and pollution_model_functions.R. Then it will generate new samples from the model.

Finally, EVPPI will be computed and plotted.

###############################################

Details of the constants and the indices used in the pollution model are below.


## CONST contains:
# N : population numbers by age and gender
# TT : time travelled by age, mode, scenario and gender
# TTT : time travelled by age, mode, scenario and gender
# U : background burden of disease by age, outcome, disease, gender
# H : air-pollution dose--response look-up table, by disease and pm value

## INDICES ##
# age
# 1 18-29
# 2 30-44
# 3 45-59
# 4 60-69
# 5 70-79
# 6 80+
# gender
# 1 m
# 2 f
# burden outcome
# 1 death
# 2 DALY
# 3 YLD
# 4 YLL
# scenario
# 1 SP 2012 (baseline)
# 2 expanded centre
# 3 peripheral belt
# 4 London 2012
# 5 California
# 6 SP 2040
# mode (travel_modes)
# 1 walk
# 2 cycle
# 3 bus
# 4 car/taxi
# 5 motorbike
# 6 metro & train
# (all_modes)
# 7 LGV
# 8 HGV
# 9 other motor vehicle
# diseases 
# 1 stroke
# 2 IHD
# 3 other cardio/circulatory
# 4 T2D
# 5 colon cancer
# 6 breast cancer
# 7 dementia and alzheimer's
# 8 depression
# 9 all-cause mortality woodcock
# 10 pedestrian injury
# 11 cyclist injury
# 12 mc injury
# 13 car, van, bus, truck injury
# 14 other road injury
# 15 other transport injury
# 16 lung cancer
# 17 COPD

