
get_parameters <- function(){
  
  parameters <- list()
  
  ## POLLUTION VARIABLES ##
  parameters$eta <- Lnorm(2.665364, 0.3234522) # background pollution level
  parameters$zeta <- Beta(5.795375, 8.947712) # proportion of pollution attributed to cars
  
  ## POLLUTION AND HEALTH VARIABLES ##
  parameters$xi <- Lnorm(0,0.25) # stroke
  
  return(parameters)
}

interp <- function(V,HdV){
  lower <- sapply(V,function(x)max(1,min(floor(x),dim(HdV)[1])))
  upper <- sapply(V,function(x)min(ceiling(x),dim(HdV)[1]))
  out <- HdV[lower,] + (HdV[upper,] - HdV[lower,])*(V - lower)
  return(out)
}

pollution_calculation <- function(const,parameters){
  
  ## CONSTANTS
  for(i in 1:length(const)) assign(names(const)[i],const[[i]])
  
  ## PARAMETER VALUES
  parameter_samples <- c()
  for(i in 1:length(parameters)) {
    assign(names(parameters)[i],r(parameters[[i]])(1))
    parameter_samples[i] <- get(names(parameters)[i])
  }
  
  ## POLLUTION CALCULATION
  scenario_pm <- eta*(zeta*scenario_travel_ratio+1-zeta)
  
  ## HEALTH-IMPACT CALCULATIONS
  # uncertainty in relative-risk dose--response curve
  RR_curve_sample <- 1+(RR-1)*xi
  # cast as matrix to apply interpolation
  RR_curve_sample_mat <- matrix(RR_curve_sample,ncol=1,byrow=T)
  # interpolate relative risk for each disease given pollution inhalation
  RR_realisation <- sapply(scenario_pm,interp,HdV=RR_curve_sample_mat) 
  
  
  ## BURDEN-OF-DISEASE CALCULATIONS
  # relative risk relative to baseline scenario
  relative_RR <- RR_realisation/RR_realisation[1]
  # burden of disease = burden of disease in baseline scaled by relative risk ratio
  scenario_burden <- relative_RR*background_burden
  
  return(list(parameter_samples=parameter_samples,scenario_burden=scenario_burden))
}


