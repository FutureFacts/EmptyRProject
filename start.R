
######## Initialisation ########

# Libpath
.libPaths("C:/Rlibs")

# Close any open devices (if an error occurs while saving an image, a device may be left open)
for (d in dev.list()) { try(dev.off()); }; rm(d);
# Clear the Global Environment
rm(list = ls());
gc();
# Clear the console screen
cat("\014");


# Set system path to include the correct version of the Oracle Instant Client
# Sys.setenv("PATH" = paste0(Sys.getenv("PATH"), ";C:\\Program Files\\Oracle\\instantclient_12_1"));


# project functions
project_ensure_folder <- function(folderName) {
  ifelse(  !dir.exists(folderName)
         , dir.create(folderName, recursive = TRUE)
         , FALSE);
}


######## Parameters ########
# Sys.setenv(R_CONFIG_ACTIVE = "")
# Sys.setenv(R_CONFIG_ACTIVE = "acceptance")
# Sys.setenv(R_CONFIG_ACTIVE = "production")
# Sys.getenv("R_CONFIG_ACTIVE")

DTS <- as.POSIXlt(Sys.time(), "UTC");
install.packages("config")
library(config);
project_config   <- config::get(file = "config.yml", use_parent = FALSE);
rm(DTS);

if (dir.exists(project_config$folders$output)) {
  unlink(project_config$folders$output, recursive = TRUE)
}
for (folder in project_config$folders) {
  project_ensure_folder(folder);
}; rm(folder);


######## Logging ########
install.packages("logging")
library(logging);
basicConfig(level = project_config$logging$level);
addHandler(  writeToFile
           , file   = paste(project_config$folders$output, project_config$files$log, sep="/")
           , level  = project_config$logging$level
           , logger = '');
loginfo(paste0("Logging started at level:   ", project_config$logging$level));

loginfo(paste0("Current working directory:  ", getwd()));


######## Process all steps ########
source("Source/_ProcessAll.R");

# Exiting
loginfo("Finished")
