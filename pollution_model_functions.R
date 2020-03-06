
get_parameters <- function(){
  
  parameters <- list()
  for(param_name in c('x1','x2','alpha','beta','gamma','tau'))
    parameters[[param_name]] <- rep(0,nSamples)
  
  ## POLLUTION VARIABLES ##
  parameters$x1[1:nSamples] <- rlnorm(nSamples,2.665364, 0.3234522) # background pollution level
  parameters$x2 <- rbeta(nSamples,5.795375, 8.947712) # proportion of pollution attributed to cars
  
  ## POLLUTION AND HEALTH VARIABLES ##
  suppressWarnings({
  parameters$alpha[1:nSamples] <- strokeDR$alpha
  parameters$beta[1:nSamples] <- strokeDR$beta
  parameters$gamma[1:nSamples] <- strokeDR$gamma
  parameters$tmrel[1:nSamples] <- strokeDR$tmrel
  })
  
  return(parameters)
}

dose_response <- function(pm,alpha,beta,gamma,tmrel){
  1 + alpha * ( 1 - exp(- beta * ( pmax(pm - tmrel,0) )^gamma ) )
}

pollution_calculation <- function(parameters,j){
  
  ## PARAMETER VALUES
  parameter_samples <- c()
  for(i in 1:length(parameters)) {
    assign(names(parameters)[i],parameters[[i]][j])
    parameter_samples[i] <- get(names(parameters)[i])
  }
  
  ## POLLUTION CALCULATION
  scenario_pm <- x1*(x2*scenario_travel_ratio+1-x2)
  
  ## HEALTH-IMPACT CALCULATIONS
  RR_realisation <- dose_response(scenario_pm,alpha,beta,gamma,tmrel) 
  
  ## BURDEN-OF-DISEASE CALCULATIONS
  # relative risk relative to baseline scenario
  relative_RR <- RR_realisation/RR_realisation[1]
  # burden of disease = burden of disease in baseline scaled by relative risk ratio
  scenario_burden <- relative_RR*background_burden
  
  return(list(parameter_samples=parameter_samples,scenario_burden=scenario_burden))
}


