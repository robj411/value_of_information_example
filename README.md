# Value of information

Value of information (VOI) is a measure of how much one uncertain variable tells you about another uncertain variable. Usually, we're interested in how much an uncertain input tells us about an uncertain output, so that we can anticipate how useful it would be to us to learn more about that input, particularly if there are many inputs we might consider learning about.

The attached example computes the expected value of perfect partial information (EVPPI), that is, the value of learning a single parameter perfectly. In this example there are three parameters, and we can compare their values.

Other VOI metrics include the expected value of perfect information (EVPI), which is the value of learning all parameters perfectly, and the expected value of sample information (EVSI), which is the value of collecting data that informs knowledge of one parameter or more. Therefore, we have that EVSI &le; EVPPI &le; EVPI.

# This example

The attached example uses a simplified, idealised health-impact model taken from the "integrated transport and health" suite of models. It consists of a single demographic group, who are female and aged 45 to 59. We have a value for that group's disability-adjusted life years (DALYs) due to stroke events, which is a measure of their health burden. Their stroke-DALY health burden is 18,530.

Additionally, we have an estimate of the background level of PM2.5, a class of pollutants with diameter less than 2.5 micrometers with associations to chronic diseases; we have an estimate of the proportion of PM2.5 that is attributable to car use; we have an estimate of the dose--response relationship between PM2.5 and incidence of stroke; and we have two scenarios, one in which car use decreases, and one in which car use increases. We use a model to predict what the health burden will be in the different scenarios, and we use EVPPI to understand which uncertainties in our model drive the uncertainty in the estimated health burden.

![parameters](https://github.com/robj411/value_of_information_example/blob/master/parameters.png)


# Results

The distibutions of expected health burdens in terms of DALYs are

![outcomes](https://github.com/robj411/value_of_information_example/blob/master/outcomes.png)

and the parameters that we could most usefully learn to increase precision in our estimates for the two scenarios are

![voi](https://github.com/robj411/value_of_information_example/blob/master/voi.png)

So, learning the background PM2.5 concentration better would increase precision for our estimate under a car decrease scenario. Learning the car fraction of background PM2.5 concentration better would increase precision for our estimate under a car increase scenario.

