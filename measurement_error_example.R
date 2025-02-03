# Adapted from original code in https://github.com/ercrema/capuzzo_crema_2024
# Load Relevant R Packages ----
library(rcarbon)
library(nimbleCarbon)
library(coda)
library(here)

# Simulate Regression Data ----
set.seed(12332) #Random seed
true.alpha  <- 2700 #True Intercept
true.beta  <- 1/3.7 #True Slope
true.sigma <- 70 #True Error
n <- 100 #Sample Size
d <- runif(n=n,min=0,max=1000) |> round()
calendar.dates <- rnorm(n=n,mean=true.alpha - true.beta*d,sd=true.sigma) |> round()

# #Optional plot regression on calendar dates
par(mfrow=c(1,3))
plot(d,calendar.dates,xlim=c(0,1000),ylim=rev(range(calendar.dates)),pch=20,xlab='x',ylab='Calendar Dates (no measurement error)')
abline(a=true.alpha,b=-true.beta,lty=2,lwd=2,col='red')
abline(lm(calendar.dates~d),col='blue')

c14ages <- uncalibrate(calendar.dates)[,4] #back-calibrate calendar date in 14C age
c14ages.error <- rep(30,n) #assign errors
median.calibrated <- calibrate(c14ages,c14ages.error) |> medCal() #calibrate and compute median calibrated dates

# #Optional plot regression on median calibrated dates
# plot(d,median.calibrated,xlim=c(0,1000),ylim=rev(range(median.calibrated)),pch=20)
# abline(a=true.alpha,b=-true.beta,lty=2,lwd=2,col='red')
# abline(lm(median.calibrated~d),col='blue')

# Run regression analysis on calendar dates ----
fitcal  <- lm(calendar.dates~d,data=data.frame(d=d,calendar.dates=calendar.dates))


# Run regression analyses on median calibrated dates ----
fitmed <- lm(median.calibrated~d,data=data.frame(d=d,median.calibrated=median.calibrated))
confint(fitmed)


# Run Bayesian regression analyses on 14C dates ----
# Prepare data list:
dat <- list()
dat$cra <- c14ages
dat$cra.error <- c14ages.error
# Prepare constant list:
constants <- list()
constants$d <- d
data(intcal20)
constants$calBP <- intcal20$CalBP
constants$C14BP  <- intcal20$C14Age
constants$C14err <- intcal20$C14Age.sigma
constants$n <- n
# Prepare initialisation values
inits <- list()
inits$theta <- median.calibrated
inits$alpha <- 3000
inits$beta <- 1/2
inits$sigma <- 50

# Regression model in nimble
model <- nimbleCode({
	for (i in 1:n)
	{
		mu[i]  <- alpha +  beta * d[i]
		theta[i] ~ dnorm(mean=mu[i],sd=sigma)
		c14age[i] <- interpLin(z=theta[i],x=calBP[],y=C14BP[]);
		sigmaCurve[i] <- interpLin(z=theta[i],x=calBP[],y=C14err[]);
		sigmaDate[i] <- (cra.error[i]^2+sigmaCurve[i]^2)^(1/2);
		cra[i] ~ dnorm(mean=c14age[i],sd=sigmaDate[i])
	}
	alpha ~ dunif(1000,5000)
	beta ~ dnorm(0,1)
	sigma ~ dexp(0.1)
})

# Run MCMC
out  <- nimbleMCMC(code=model,constants=constants,inits=inits,data=dat,nchains=4,niter=100000,nburnin=50000,samplesAsCodaMCMC=TRUE,monitors=c('theta','alpha','beta','sigma'))

# Check Convergence in MCMC
rhats <- coda::gelman.diag(out)
which(rhats[[1]][,1]>1.01) #Only theta, can be ignored as calibrated 14C dates are not normally distributed

# Extract Posterior
posterior <- do.call(rbind.data.frame,out)

# Compute HPD interval
HPDinterval(as.mcmc(posterior[,'alpha']))
HPDinterval(as.mcmc(posterior[,'beta']))

# Extract Mean Posterior for Theta
theta.median <- apply(posterior[,grep('theta',colnames(posterior))],2,median)

# Make a data.frame for plotting the results ----
pred <- data.frame(d=-100:1200)

# Regression on True Calendar Dates:
pred$true  <- predict(fitcal,newdata=pred)
pred$true.lo  <- predict(fitcal,newdata=pred,interval='confidence')[,2]
pred$true.hi  <- predict(fitcal,newdata=pred,interval='confidence')[,3]

# Regression on Median Calibrated Dates:
pred$m  <- predict(fitmed,newdata=pred)
pred$m.lo95  <- predict(fitmed,newdata=pred,interval='confidence')[,2]
pred$m.hi95  <- predict(fitmed,newdata=pred,interval='confidence')[,3]

# Bayesian Regression on 14C Dates:
predmatrix <- matrix(NA,nrow=nrow(posterior),ncol=length(-100:1200))
for (i in 1:nrow(posterior))
{
	predmatrix[i,]  <- posterior$alpha[i] + posterior$beta[i] * c(-100:1200)
}
pred$b <- apply(predmatrix,2,mean)
pred$b.lo95 <- apply(predmatrix,2,function(x){HPDinterval(mcmc(x))[1]})
pred$b.hi95 <- apply(predmatrix,2,function(x){HPDinterval(mcmc(x))[2]})

# Extract values for violin plot ----
cl <- calibrate(c14ages,c14ages.error,calMatrix=TRUE,timeRange=c(3000,2000))
caldd <- vector('list',length=100)
sc  <- 1000
for (i in 1:100)
{
	xx  <- c(d[i] + cl$calmatrix[,i]*sc,d[i] - rev(cl$calmatrix[,i])*sc)
	yy  <- c(3000:2000,2000:3000)
	caldd[[i]] <- data.frame(xx=xx,yy=yy)
}





# Plot Results ----
pdf(here('figures','figure_measurementerror.pdf',height=3.5,width=9)
par(mfrow=c(1,3),mar=c(4,4,2,1))
par(lend=2)
plot(d,calendar.dates,xlim=c(0,1000),ylim=c(2850,2100),pch=19,ylab='BP',xlab='x',col=adjustcolor('black',0.6))
abline(a=true.alpha,b=-true.beta,lty=2,lwd=2)
polygon(x=c(pred$d,rev(pred$d)),y=c(pred$true.hi,rev(pred$true.lo)),border=NA,col=adjustcolor('firebrick',0.3))
lines(pred$d,pred$true,lwd=2,col='firebrick')
legend(x=20,y=2100,legend=c('Calendar Date','True Relationship','Regression on Calendar Date'),pch=c(19,NA,NA),lwd=c(NA,1,8),col=c('black','black','firebrick'),bty='n',cex=0.9,lty=c(NA,2,1))

plot(NA,xlim=c(0,1000),ylim=c(2850,2100),ylab='BP',xlab='x')
for(i in 1:100)
{
	polygon(caldd[[i]]$xx,caldd[[i]]$yy,border=NA,col=adjustcolor('lightblue',1))
}

for (i in 1:length(calendar.dates))
{
	lines(x=c(d[i],d[i]),y=c(calendar.dates[i],median.calibrated[i]),lty=3,col='black')
}

points(d,calendar.dates,pch=20)
points(d,median.calibrated,pch=4)
legend(x=20,y=2100,legend=c('Calendar Date','Median Calibrated Date','Calibrated Distribution'),pch=c(19,4,NA),lwd=c(NA,NA,8),col=c('black','black','lightblue'),bty='n',cex=0.9)

/home/erc62/gitrepos/statistical_modelling_review/generative_inference/frequencies.pdf
/home/erc62/gitrepos/statistical_modelling_review/generative_inference/generative_inference_example.R
/home/erc62/gitrepos/statistical_modelling_review/generative_inference/priorposterior.pdf
/home/erc62/gitrepos/statistical_modelling_review/generative_inference/schematic.png
/home/erc62/gitrepos/statistical_modelling_review/generative_inference/schematic.svg
plot(NA,xlim=c(0,1000),ylim=c(2850,2100),pch=19,ylab='BP',xlab='x')
abline(a=true.alpha,b=-true.beta,lty=2,lwd=2)
lines(pred$d,pred$m,lwd=2,col='darkorange')
polygon(x=c(pred$d,rev(pred$d)),y=c(pred$m.lo95,rev(pred$m.hi95)),border=NA,col=adjustcolor('darkorange',0.3))
lines(pred$d,pred$b,lwd=2,col='darkgreen')
polygon(x=c(pred$d,rev(pred$d)),y=c(pred$b.lo95,rev(pred$b.hi95)),border=NA,col=adjustcolor('darkgreen',0.3))
legend(x=20,y=2100,legend=c('True Relationship','Regression on Median Date','Bayesian EIV Model'),lwd=c(1,8,8),col=c('black','darkorange','darkgreen'),bty='n',cex=0.9,lty=c(2,1,1))

dev.off()
