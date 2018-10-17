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

get_parameters <- function(){
  
  parameters <- list()
  
  ## POLLUTION VARIABLES ##
  parameters$eta <- Lnorm(3, 1) # background pollution level
  parameters$zeta <- Beta(2, 3) # proportion of pollution attributed to traffic
  
  ## POLLUTION AND HEALTH VARIABLES ##
  parameters$xi5 <- Lnorm(0,0.5) # chronic obstructive pulmonary disease
  parameters$xi3 <- Lnorm(0,0.5) # ischemic heart disease
  parameters$xi4 <- Lnorm(0,0.5) # lung cancer
  parameters$xi2 <- Lnorm(0,0.5) # stroke
  
  # ventilation rates for walking and cycling
  parameters$lambda1 <- Lnorm(1,1)
  parameters$lambda2 <- Lnorm(2,0.4)
  
  # allocation of traffic pollution to modes
  parameters$alpha1 <- Gammad(shape=32,scale=1) # buses
  parameters$alpha2 <- Gammad(shape=8,scale=1) # cars
  parameters$alpha3 <- Gammad(shape=4,scale=1) # motorbikes
  parameters$alpha4 <- Gammad(shape=56,scale=1) # goods vehicles
  
  parameters$lambda3 <- Dirac(0.5)
  parameters$lambda4 <- Dirac(0.5)
  parameters$lambda5 <- Dirac(1)
  parameters$lambda6 <- Dirac(0.5)
  
  return(parameters)
}

interp <- function(V,HH){
  lower <- sapply(V,function(x)max(1,min(floor(x),dim(HH)[1])))
  upper <- sapply(V,function(x)min(ceiling(x),dim(HH)[1]))
  out <- HH[lower,] + (HH[upper,] - HH[lower,])*(V - lower)
  return(out)
}

pollution_calculation <- function(const,parameters,seed){
  ## INDEX TRANSLATIONS
  set.seed(seed)
  disease_all_in_pm <- c(1,2,16,17)
  
  all_modes_to_travel <- 1:6
  all_modes_to_active <- 1:2
  
  lambda_indices <- 1:6
  
  ## CONSTANTS
  
  for(i in 1:length(const)) assign(names(const)[i],const[[i]])
  
  ## PARAMETER VALUES ##
  parameter_samples <- c()
  for(i in 1:length(parameters)) {
    assign(names(parameters)[i],r(parameters[[i]])(1))
    parameter_samples[i] <- get(names(parameters)[i])
  }
  
  # proportion of traffic pollution attributable to each mode
  alpha <- c(alpha1,alpha2,alpha3,alpha4)
  alpha <- alpha/sum(alpha)
  parameter_samples[which(names(parameters)%in%c("alpha1","alpha2","alpha3","alpha4"))] <- alpha
  P <- to.tensor(c(0,0,alpha),dims=c(travel_modes=6),ndimnames=list(dimnames(TTT)[[2]]))
  # ventilation rate
  lambda <- to.tensor(1+c(lambda1,lambda2,lambda3,lambda4,lambda5,lambda6),dims=c(travel_modes=6),ndimnames=list(dimnames(TTT)[[2]]))
  # disease relative risks
  xi <- to.tensor(c(xi2,xi3,xi4,xi5),dims=c(disease_pm=4),ndimnames=list(dimnames(H)[[1]]))
  
  ## total population travel = average travel per person time population numbers
  A <- TT*N
  Atil <- margin.tensor(A,i=c('age','gender'))/dim(A)['age']/dim(A)['gender']
  Ahat <- Atil/Atil[[scenario=1]]
  Atil[is.nan(Atil)] <- 1
  Ahat[is.nan(Ahat)] <- 1
  A[is.nan(A)] <- 1
  
  Ptil <- P*Ahat[[all_modes=~travel_modes,travel_modes=all_modes_to_travel]]
  Phat <- margin.tensor(Ptil,i='travel_modes') # marginalise over travel mode
  
  Pbar <- eta*(zeta*Phat+1-zeta)
  
  V <- lambda
  Vtilnotmet <- V*TTT
  Vtilnotmet <- margin.tensor(Vtilnotmet,i='travel_modes')##!! marginalise over modes. should be 1:5 (6=tube)
  Vhat <- (Vtilnotmet + 1440 - margin.tensor(TTT,i='travel_modes'))/1440
  Vche <- Vhat*Pbar
  
  Htil <- 1+(H-1)*xi
  HH <- matrix(Htil,ncol=4,byrow=T)
  
  Hhat <- apply(Vche,c(2,3),interp,HH=HH)
  Hhat <- as.tensor(Hhat,dims=c(age=6,disease_pm=4,scenario=6,gender=2))
  dimnames(Hhat) <- list(dimnames(U)[[1]],dimnames(H)[[1]],dimnames(TT)[[3]],dimnames(U)[[4]])
  Hche <- Hhat/Hhat[[scenario=1]]
  Util <- Hche*U[[disease=~disease_pm,disease_pm=disease_all_in_pm]]
  return(list(parameter_samples=parameter_samples,Util=Util,Pbar=Pbar,V=V,Hche=Hche,U=U[[disease=~disease_pm,disease_pm=disease_all_in_pm]]))
}


