library(here)
library(bigQueryR)
source(here('R/utils.R'))

auth_json <- here("AUTH/mcw-play-217608-68fe7c152472.json")

options(googleAuthR.scopes.selected =c("https://www.googleapis.com/auth/bigquery", "https://www.googleapis.com/auth/devstorage.full_control"))
Sys.setenv(BQ_AUTH_FILE = auth_json)
googleAuthR::gar_auth_service(json_file = auth_json, scope = getOption("googleAuthR.scopes.selected"))

bqr_global_project("mcw-play-217608")
bqr_global_dataset("AD_FORM_ANALIZY")

sql = "
#standardSQL
SELECT EID
, ct.contact_type
, Timestamp ts
, IFNULL(ReferrerType, 'NA') referrer_type
, g.country
, g.city
, dev.name device
, lvl1, lvl2, lvl3, KOD, REJESTRACJA
FROM AD_FORM_ANALIZY.FINAL_CLEAN_DATA t
LEFT JOIN AD_FORM_ANALIZY.contact_types ct ON ct.id = t.contact_type
LEFT JOIN AD_FORM_ANALIZY.dict_geolocations g ON t.city = CAST(g.cityId AS STRING)
LEFT JOIN AD_FORM_ANALIZY.dict_devices dev ON t.DeviceTypeId = dev.id
WHERE EID IS NOT NULL"

cat("Running the query\n")
job <- bqr_query_asynch(query = sql, destinationTableId = "DATA_READY", useLegacySql = FALSE, writeDisposition = 'WRITE_TRUNCATE')
cond <- TRUE
while(cond) {
  cond <- ifelse(bqr_get_job(job)$status$state != "DONE", T, F)
  job_progress(cond)
}

cat("Exporting query's results\n")
job_extract <- bqr_extract_data(tableId = "DATA_READY",
                                cloudStorageBucket = "ad-form-data",
                                filename = "coca-cola/R_PATHS/paths_data*.csv.gz",
                                compression = 'GZIP')
cond <- TRUE
while(cond) {
  cond <- ifelse(bqr_get_job(job_extract)$status$state != "DONE", T, F)
  job_progress(cond)
}
