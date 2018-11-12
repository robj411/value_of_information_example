
get_parameters <- function(){
  
  parameters <- list()
  
  ## POLLUTION VARIABLES ##
  parameters$eta <- Lnorm(3, 1) # background pollution level
  parameters$zeta <- Beta(2, 3) # proportion of pollution attributed to traffic
  
  ## POLLUTION AND HEALTH VARIABLES ##
  parameters$xi2 <- Lnorm(0,0.5) # stroke
  parameters$xi3 <- Lnorm(0,0.5) # ischemic heart disease
  parameters$xi4 <- Lnorm(0,0.5) # lung cancer
  parameters$xi5 <- Lnorm(0,0.5) # chronic obstructive pulmonary disease
  
  # ventilation rates 
  parameters$lambda1 <- Lnorm(1,1) # walking
  parameters$lambda2 <- Lnorm(2,0.4) # cycling
  # (0.5) # bus
  # (0.5) # car
  # (1) # motorbike
  # (0.5) # goods vehicle
  
  
  # allocation of traffic pollution to modes
  parameters$alpha1 <- Gammad(shape=32,scale=1) # buses
  parameters$alpha2 <- Gammad(shape=8,scale=1) # cars
  parameters$alpha3 <- Gammad(shape=4,scale=1) # motorbikes
  parameters$alpha4 <- Gammad(shape=56,scale=1) # goods vehicles
  
  return(parameters)
}

interp <- function(V,HdV){
  lower <- sapply(V,function(x)max(1,min(floor(x),dim(HdV)[1])))
  upper <- sapply(V,function(x)min(ceiling(x),dim(HdV)[1]))
  out <- HdV[lower,] + (HdV[upper,] - HdV[lower,])*(V - lower)
  return(out)
}

pollution_calculation <- function(const,parameters){
  
  ## INDEX TRANSLATIONS
  # which diseases we need from the global burden of disease dataset
  disease_all_in_pm <- c(1,2,16,17)
  
  # which of the modes are recorded in travel diary
  all_modes_to_travel <- 1:6
  # which of the modes are active transport
  all_modes_to_active <- 1:2
  
  ## CONSTANTS
  for(i in 1:length(const)) assign(names(const)[i],const[[i]])
  
  ## PARAMETER VALUES
  parameter_samples <- c()
  for(i in 1:length(parameters)) {
    assign(names(parameters)[i],r(parameters[[i]])(1))
    parameter_samples[i] <- get(names(parameters)[i])
  }
  
  ## PARAMETER GROUPINGS
  # proportion of traffic pollution attributable to each mode
  alpha <- c(alpha1,alpha2,alpha3,alpha4)
  alpha <- alpha/sum(alpha)
  parameter_samples[which(names(parameters)%in%c("alpha1","alpha2","alpha3","alpha4"))] <- alpha
  P <- to.tensor(c(0,0,alpha),dims=c(travel_modes=6),ndimnames=list(dimnames(TTT)[[2]]))
  # ventilation rates
  lambda <- to.tensor(c(lambda1,lambda2,lambda3,lambda4,lambda5,lambda6),dims=c(travel_modes=6),ndimnames=list(dimnames(TTT)[[2]]))
  # disease relative risks
  xi <- to.tensor(c(xi2,xi3,xi4,xi5),dims=c(disease_pm=4),ndimnames=list(dimnames(H)[[1]]))
  
  ## TRAVEL CALCULATIONS
  # total population travel = average travel per person time population numbers
  A <- TT*N
  A_tilde <- margin.tensor(A,i=c('age','gender'))/dim(A)['age']/dim(A)['gender']
  A_hat <- A_tilde/A_tilde[[scenario=1]]
  A_tilde[is.nan(A_tilde)] <- 1
  A_hat[is.nan(A_hat)] <- 1
  A[is.nan(A)] <- 1
  
  ## POLLUTION CALCULATIONS
  # pollution from individual modes = original pollution from mode * change in mode use
  P_tilde <- P*A_hat[[all_modes=~travel_modes,travel_modes=all_modes_to_travel]]
  # total pollution from traffic = sum over modes
  P_hat <- margin.tensor(P_tilde,i='travel_modes') 
  # total pollution = background pollution (eta(1-zeta)) plus new traffic pollution (eta*zeta*P_hat)
  P_bar <- eta*(zeta*P_hat+1-zeta)
  
  ## VENTILATION CALCULATIONS
  # ventilation rate = 1+lambda
  V <- 1+lambda
  # ventilation in travel = ventilation rate in mode * time spent in mode
  V_bar <- V*TTT
  # total ventilation = sum over modes
  V_tilde <- margin.tensor(V_bar,i='travel_modes')
  # overall ventilation = travel ventilation + non-travel ventilation
  V_hat <- (V_tilde + 1440 - margin.tensor(TTT,i='travel_modes'))/1440
  # pollution inhalation = overall ventilation * pollution level
  V_check <- V_hat*P_bar
  
  ## HEALTH-IMPACT CALCULATIONS
  # uncertainty in relative-risk dose--response curve
  Hd <- 1+(H-1)*xi
  # cast as matrix to apply interpolation
  HdV <- matrix(Hd,ncol=4,byrow=T)
  # interpolate relative risk for each disease given pollution inhalation
  H_hat <- apply(V_check,c(2,3),interp,HdV=HdV)
  H_hat <- as.tensor(H_hat,dims=c(age=6,disease_pm=4,scenario=6,gender=2))
  dimnames(H_hat) <- list(dimnames(U)[[1]],dimnames(H)[[1]],dimnames(TT)[[3]],dimnames(U)[[4]])
  
  ## BURDEN-OF-DISEASE CALCULATIONS
  # relative risk relative to baseline scenario
  H_check <- H_hat/H_hat[[scenario=1]]
  # burden of disease = burden of disease in baseline scaled by relative risk ratio
  U_tilde <- H_check*U[[disease=~disease_pm,disease_pm=disease_all_in_pm]]
  
  return(list(parameter_samples=parameter_samples,Util=U_tilde))
}


