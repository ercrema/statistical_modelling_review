male.nogoods  <- 1340-909
male.goods <- 909
female.nogoods <- 696-313
female.goods <- 313

x <- cbind(c(male.nogoods,male.goods),c(female.nogoods,female.goods))
chisq.test(x)
