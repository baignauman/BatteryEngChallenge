# BatteryEngChallenge

Procedure:

1). To predict the discharge capacity of the given storage system, the no. of discharge cycles vs the battery capacity is evaluated. The co-relation between capacity and temperature is ignored since it is almost constant throughout the dataset.
Moreover Rint also does not qualify as a good candidate since it is not monotonically increasing over the cyclic aging of the system.

2). An exponential polynomial fitting is tested. Results are presented as pdf.
3). Since prediction of capacity is the target function, a fitting neural network is selected and tested against the data. One hidden layer is selected for faster evaluation time. Results are presented as pdf.

Software Platform:
Matlab is used as a platform of choice. The Matlab m-script is provided with the results. Matlab version R2020b is used for writing the script. The machnine / deep learning toolbox is required for proper execution of the script.
