library(mgcv); 

nSamples <- 1000
## use saved example, or compute anew
saved_example <- paste0('evppi_example_',nSamples,'_samples.Rds')
if(file.exists(saved_example)){
  
  example <- readRDS(saved_example)
  parameter_samples <- example$parameter_samples
  result <- example$result
  
}else{
  
  library(tensorA)
  library(distr)
  source('pollution_model_functions.R')
  
  ## VARIABLES ##
  parameters <- get_parameters()
  ## CONSTANTS ##
  const <- readRDS('constants.Rds')
  
  parameter_samples <- matrix(0,nrow=nSamples,ncol=length(parameters))
  result <- list()
  for(j in 1:nSamples){
    set.seed(j)
    pollution_return <- pollution_calculation(const,parameters)
    parameter_samples[j,] <- pollution_return$parameter_samples
    result[[j]] <- pollution_return$Util
  }
  saveRDS(list(parameter_samples=parameter_samples,result=result),saved_example)
  
}

## choose the 'best case' scenario, SP2040
scenario_index <- 6
## isolate alpha parameters to be evaluated together
alpha_parameters <- which(names(parameters)%in%c("alpha1","alpha2","alpha3","alpha4"))
## isolate variable parameters to evaluate EVPPI for
non_constant_parameters <- which(sapply(names(parameters)[-alpha_parameters],function(x)class(parameters[[x]])!='Dirac'))
## get outcome: sum over ages and genders for specific scenario and DALY outcome
y <- unlist(lapply(result,function(x) sum(x[[scenario=scenario_index,outcome=2]])))
## get outcome variance
vary <- var(y)
## evaluate EVPPI for each independent parameter
for(i in 1:length(non_constant_parameters)){
  x <- parameter_samples[,i];
  model <- gam(y~s(x)); 
  evppi[i] <- (vary-mean((y-model$fitted)^2))/vary*100;
}
## evaluate EVPPI for dependent parameters
x <- parameter_samples[,alpha_parameters];
model <- gam(y~te(x[,1],x[,2],x[,3],x[,4]));
evppi[i+1] <- (vary-mean((y-model$fitted)^2))/vary*100
print(c(scenario_index,evppi))
x11(); barplot(evppi,beside=T)
