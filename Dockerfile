FROM rocker/rstudio:4.4.1

# Copy the whole project folder
COPY . /home/rstudio/statistical_modelling_review

# Install dependency libraries
RUN  . /etc/environment \
 && chmod -R 777 /home/ \
 && apt-get update \
 && apt-get install -y libicu-dev libglpk-dev libxml2-dev pandoc make libssl-dev libgdal-dev gdal-bin libgeos-dev libproj-dev libsqlite3-dev libudunits2-dev libcurl4-openssl-dev --no-install-recommends \
 && R -q -e 'install.packages(c("here","coda","latex2exp","RColoBrewer","nimbleCarbon","nimble","rcarbon","brms","snow","progress","foreach","Rcpp",""))' 

# Notes on running an interactive session

### STEP 1 ###
# Run on the terminal:
# docker build -t statistical_modelling_review .

### STEP 2 ###
# Run on the terminal:
# docker run --rm -it -e ROOT=TRUE -e PASSWORD=rstudio -dp 8787:8787 statistical_modelling_review

### STEP 3 ###
# Go to http://localhost:8787/ with your browswe. USERID=rstudio, PASSWORD=rstudio
# Please not the default working directory is '/home/rstudio' so in order to execute the scripts you should run 'setwd('~/statistical_modelling_review')' first.

### STEP 4 ####
# Clean and delete containers. Run on the terminal:
# docker ps -aq | xargs docker stop | xargs docker rm

# Please note that the script will require about 120~150 hours for completion on a desktop machine.








