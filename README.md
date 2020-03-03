# Value of information

Value of information (VOI) is a measure of how much one uncertain variable tells you about another uncertain variable. Usually, we're interested in how much an uncertain input tells us about an uncertain output, so that we can anticipate how useful it would be to us to learn more about that input, particularly if there are many inputs we might consider learning about.

The attached example computes the expected value of perfect partial information (EVPPI). That is, the value of learning a single parameter perfectly. In this example, there are three parameters, and we compare their EVPPI values.

Other VOI metrics include the expected value of perfect information (EVPI), which is the value of learning all parameters perfectly, and the expected value of sample information (EVSI), which is the value of collecting data that informs knowledge of one parameter or more. Therefore, we have that EVSI &le; EVPPI &le; EVPI.

# This example

The attached example uses a simplified, idealised health-impact model taken from the "integrated transport and health" suite of models. It consists of a single demographic group, who are female and aged 45 to 59. We have a value for that group's disability-adjusted life years (DALYs) due to stroke events, which is a measure of their health burden. Their stroke-DALY health burden is 18,530. We're interested to predict the health burden in "scenarios" in which something about their environment changes.

We have an estimate of the background level of PM2.5, a class of pollutants with diameter less than 2.5 micrometers with associations to chronic diseases; we have an estimate of the proportion of PM2.5 that is attributable to car use; we have an estimate of the dose--response relationship between PM2.5 and incidence of stroke; and we have two scenarios, one in which car use decreases, and one in which car use increases. We use a model to predict what the health burden will be in the different scenarios, and we use EVPPI to understand which uncertainties in our model drive the uncertainty in the estimated health burden.

![parameters](https://github.com/robj411/value_of_information_example/blob/master/parameters.png)


# Results

The distributions of expected health burdens in terms of DALYs are

![outcomes](https://github.com/robj411/value_of_information_example/blob/master/outcomes.png)

and the parameters that we could most usefully learn to increase precision in our estimates for the two scenarios are

![voi](https://github.com/robj411/value_of_information_example/blob/master/voi.png)

So, learning the background PM2.5 concentration better would most increase precision for our estimate under a car decrease scenario. Learning the car fraction of background PM2.5 concentration better would most increase precision for our estimate under a car increase scenario.

<hr>
<hr>

# The details

The outcome, the number of DALYs, is a number y. We considered two scenarios, a decrease in car use (scenario 1) and an increase in car use (scenario 2), but let's consider for now that there is just one, for simplicity of notation, and let's call the change in travel D, so that if there were 1,000 km of travel in the baseline, there are 1,000\*D km of travel in the scenario. So, there is one outcome, y, and it is the number of DALYs in the scenario conditions.

There are three uncertain inputs, x1, x2 and x3. We define x1, the background PM2.5 concentration, to have a lognormal distribution with mean and variance parameters that we specify. We define x2, the fraction of PM2.5 attributable to cars, to have a Beta distribution with parameters alpha and beta that we specify. 

Then the PM2.5 concentration in the scenario is 

PM2.5 = x1 ( x2\*D + 1 - x2).

We define x3 slightly differently. Recall that x1 is the background concentration of PM2.5. There is some function, f(PM2.5), that maps the PM2.5 concentation onto a relative risk of disease -- here, stroke. This defines a dose--response relationship, where the dose is the PM2.5 and the response is relative risk of stroke. The risk is relative to a PM2.5 value of 0, so the relative risk at PM2.5=0 is 1. We could write

relative risk of stroke (RR) = f(PM2.5).

However, we have some uncertainty about the accuracy of the dose--response relationship. We capture this with our third parameter x3, which has a lognormal distribution centred on 1, and it reflects the range of values we think are plausible for this relationship. Now the relative risk is multiplied by some scalar:

RR = 1 + (x3-1)\*f(PM2.5).

We also need the relative risk for the baseline, RR0:

RR0 = 1 + (x3-1)\*f(x1).

This RR will be a relative increase or a relative decrease from the baseline RR, and this relationship is applied to the baseline burden of disease in order to estimate the burden of disease in the scenario:

y = 18,530 \* RR / RR0.




