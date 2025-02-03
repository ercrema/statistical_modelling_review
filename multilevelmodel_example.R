library(RColorBrewer)
library(latex2exp)
library(brms)
library(here)

# Generate hypothethical samples
set.seed(123)
nsites  <- 20
samples.per.site  <- sample(5:20,replace=T,size=20)
# make site.id unusually large
samples.per.site[1]  <- 60
site.id  <- rep(1:nsites,samples.per.site)
n  <- length(site.id)
wealth  <- rnorm(n,mean=0,sd=1) # use standard Gaussian to represent wealth variability
mean.intercept  <- 10
sd.intercept  <- 2
mean.slope  <- 1.8
sd.slope  <- 1.2
sd.global  <- 1
intercepts  <- rnorm(nsites,mean=mean.intercept,sd=sd.intercept)
slopes  <- rnorm(nsites,mean=mean.slope,sd=sd.slope)
# make site.id as an abnormal case with large negative slope
slopes[1]  <- -2 

delta15N  <- rep(intercepts,samples.per.site) + rep(slopes,samples.per.site) * wealth + rnorm(n,mean=0,sd=sd.global)
d  <- data.frame(site.id=site.id,wealth=wealth,delta15N=delta15N)

# Analysis ----
library(brms)

# Standard Linear Regression
fit.std  <- lm(delta15N~ 1 + wealth,data=d)
# Bayesian multi-level model
fit.ml  <- brm(delta15N ~ 1 + wealth + (1 + wealth|site.id),data=d)

# Predictions
# standard regression
newdat  <- data.frame(wealth=seq(-4,4,length.out=100))
pred.std  <- predict(fit.std,newdata=newdat,interval='prediction')
# multilevel for each existing groups
newdat2 <- data.frame(site.id=rep(1:20,each=100),wealth=seq(-4,4,length.out=100))
pred.ml <- predict(fit.ml,newdata=newdat2)
# multilevel for hypothetical new group
newdat3  <- data.frame(site.id=99,wealth=seq(-4,4,length.out=100))
pred.newlevel  <- predict(fit.ml,newdata=newdat3,allow_new_levels=T,sample_new_levels='gaussian')


# Plot -----
cols <- brewer.pal('Set2',n=3) 

pdf(here('figures','figure1_multilevelmodel.pdf'),width=8,height=7)
par(mfrow=c(2,2),mar=c(5,4,1,1))
# a standard
plot(wealth,delta15N,xlab='Wealth Index',ylab=TeX(r'($\delta^{15} N$)'),pch=20,col='lightgrey')
polygon(x=c(newdat$wealth,rev(newdat$wealth)),y=c(pred.std[,2],rev(pred.std[,3])),border=NA,col=adjustcolor('firebrick',0.4))
lines(x=newdat$wealth,y=pred.std[,1],lwd=2,col='firebrick')
text(x=-2.3,y=17.5,label='a',bty='n',cex=1.5)


# panel b regresson lines under hierarchical model
plot(wealth,delta15N,xlab='Wealth Index',ylab=TeX(r'($\delta^{15} N$)'),pch=20,col='lightgrey')
sapply(1:nsites,function(x,y,z){lines(z$wealth[which(z$site.id==x)],y=y[which(z$site.id==x),1],lwd=1.2,col='firebrick')},y=pred.ml,z=newdat2)
text(x=-2.3,y=17.5,label='b',bty='n',cex=1.5)

# panel c highlight extreme cases
plot(wealth,delta15N,xlab='Wealth Index',ylab=TeX(r'($\delta^{15} N$)'),pch=20,col='lightgrey')

#site 16
site1 <- subset(d,site.id==1)
pred1 <- cbind.data.frame(subset(newdat2,site.id==1),pred.ml[which(newdat2$site.id==1),])
points(site1$wealth,site1$delta15N,pch=20,col=cols[1],cex=1.2)
polygon(c(pred1$wealth,rev(pred1$wealth)),c(pred1$Q2.5,rev(pred1$Q97.5)),border=NA,col=adjustcolor(cols[1],0.2))
lines(pred1$wealth,pred1$Estimate,lwd=1.5,col=cols[1])

site4 <- subset(d,site.id==4)
pred4 <- cbind.data.frame(subset(newdat2,site.id==4),pred.ml[which(newdat2$site.id==4),])
points(site4$wealth,site4$delta15N,pch=20,col=cols[2],cex=1.2)
polygon(c(pred4$wealth,rev(pred4$wealth)),c(pred4$Q2.5,rev(pred4$Q97.5)),border=NA,col=adjustcolor(cols[2],0.2))
lines(pred4$wealth,pred4$Estimate,lwd=1.5,col=cols[2])

site8 <- subset(d,site.id==8)
pred8 <- cbind.data.frame(subset(newdat2,site.id==8),pred.ml[which(newdat2$site.id==8),])
points(site8$wealth,site8$delta15N,pch=20,col=cols[3],cex=1.2)
polygon(c(pred8$wealth,rev(pred8$wealth)),c(pred8$Q2.5,rev(pred8$Q97.5)),border=NA,col=adjustcolor(cols[3],0.2))
lines(pred8$wealth,pred8$Estimate,lwd=1.5,col=cols[3])
text(x=-2.3,y=17.5,label='c',bty='n',cex=1.5)

#panel d --> out-of sample prediction
plot(wealth,delta15N,xlab='Wealth Index',ylab=TeX(r'($\delta^{15} N$)'),pch=20,col='lightgrey')
polygon(x=c(newdat3$wealth,rev(newdat3$wealth)),y=c(pred.newlevel[,3],rev(pred.newlevel[,4])),border=NA,col=adjustcolor('firebrick',0.4))
lines(x=newdat3$wealth,y=pred.newlevel[,1],lwd=2,col='firebrick')
text(x=-2.3,y=17.5,label='d',bty='n',cex=1.5)
dev.off()




