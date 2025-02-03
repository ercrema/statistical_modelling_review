library(parallel)
library(doSNOW)
library(coda)
library(here)
# Generate Observed Data ----
N <- 500
mu <- 0.007
tsteps <- 10000
set.seed(123)


unbiased.learning <- function(N,mu,timesteps,raw=TRUE)
{
	pop <- 1:N
	variants.recorder <- N

	for (i in 1:tsteps)
	{
		pop2  <- sample(pop,replace=T)
		i <- which(runif(N)<mu)
		if(length(i)>1)
		{
			new.variants  <- (variants.recorder+1):(variants.recorder+length(i))
			pop2[i]  <-  new.variants
			variants.recorder  <- max(new.variants)
		}
		pop <- pop2
	}
	obs.cnts  <- table(pop)
	names(obs.cnts) <- NULL
	obs.freq  <- obs.cnts/N
	obs.div <- 1-sum(c(obs.freq^2))
	if (raw==TRUE)
	{
		return(list(obs.cnts=obs.cnts,obs.freq=obs.freq,obs.div=obs.div))
	}
	if (raw==FALSE)
	{
		return(obs.div)
	}
}

res.obs <- unbiased.learning(N=N,mu=mu,timesteps=10000)

# Generative Inference ----
cl  <- makeCluster(25)
registerDoSNOW(cl)
library(progress)

nsim <- 1000000
tol  <- 0.00001
pb <- progress_bar$new(total=nsim)
progress <- function(n){pb$tick()}
opts  <-list(progress=progress) 
# mu.prior  <- runif(nsim,min=0,max=1)
mu.prior  <- rexp(nsim,rate=10)

res.div <- foreach(i=1:nsim,.combine=c,.options.snow=opts) %dopar%
{
	N <- 500
	mu <- mu.prior[i]
	tsteps <- 10000
	set.seed(i)
	res <- 	unbiased.learning(N=N,mu=mu,timesteps=tsteps,raw=FALSE)
	res
}

stopCluster(cl)

d  <- (obs.div-res.div)^2
d.top.index  <- which(d <= tol)
posterior <- mu.prior[d.top.index]
# HPDinterval(mcmc(posterior),0.9)


# Make Figures ----

# Observed Frequecies and Sample of Good and Bad Fits
pdf(here('figures','figure3_frequencies.pdf'),width=3,height=8,useDingbats=T)
examples.i <- c(678,111,d.top.index[5],567,99958)
par(mfrow=c(6,1),mar=c(2,3,2,2))

barplot(sort(res.obs$obs.cnts,decreasing=T),border=NA,col='lightblue',las=2,cex.names=0.9,width=1,xlim=c(0,36),ylim=c(0,115),space=0.1)
legend('right',legend=c(paste0('N=',500),TeX(paste0('$\\mu=?$')),paste0('Diversity=',res.obs$obs.div)),bty='n')

for (j in 1:length(examples.i))
{
	i  <- examples.i[j]
	set.seed(i)
	candidate <- unbiased.learning(N=N,mu=mu.prior[i],timesteps=10000)
	barplot(sort(candidate$obs.cnts,decreasing=T),border=NA,col='firebrick',las=2,cex.names=0.9,xlim=c(0,36),ylim=c(0,115),space=0.1)
	if (length(candidate$obs.cnts)>length(res.obs$obs.cnts))
	{
		arrows(x0=34.5,x1=37,y0=109,y1=109,length=0.05)
		text(x=27,y=109,labels=paste0(length(candidate$obs.cnts)-length(res.obs$obs.cnts),' further variants'),cex=0.8)
	}
	legend('right',legend=c(paste0('N=',N),
				   TeX(paste0('$\\mu=',mu.prior[i],'$')),
				   paste0('Diversity=',candidate$obs.div),
				   TeX(paste0('$\\epsilon=',d[i],'$'))),
	bty='n')
}
dev.off()


pdf(here('figures','figure3_priorposterior.pdf'),width=8,height=4)
par(mfrow=c(1,2))
mu.seq <- seq(0,1,length.out=10000)
dens.prior <- dexp(mu.seq,rate=10)
plot(mu.seq,dens.prior,xlab=TeX(r'($\mu$)'),type='l',ylab='Probability Density',main='Prior',lwd=1.5)
polygon(x=c(mu.seq,rev(mu.seq)),y=c(dens.prior,rep(0,10000)),border=NA,col='lightblue')
dens.posterior  <- density(posterior,n=5000,from=0,to=1)
# plot(dens.posterior,xlab=TeX(r'($\mu$)'),type='l',ylab='Probability Density',main='Posterior')
plot(dens.posterior,xlab=TeX(r'($\mu$)'),type='l',ylab='Probability Density',main='Posterior',xlim=c(0,0.05))
i  <- which(dens.posterior$x >= HPDinterval(mcmc(posterior))[1] & dens.posterior$x <= HPDinterval(mcmc(posterior))[2])
polygon(c(dens.posterior$x[i],rev(dens.posterior$x[i])),c(dens.posterior$y[i],rep(0,length(i))),border=NA,col=adjustcolor('firebrick',0.5))
dev.off()





