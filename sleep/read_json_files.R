#' request new data -- sleep got wildly better last couple weeks of June. 

library(dplyr)
library(tidyjson)
library(jsonlite)
library(lubridate)
library(data.table)
library(readr)
library(ggplot2)


setwd("/Users/lissacallahan/Projects/garmin")

# # reads in as a list - no
# sleep_data1 <- 
#   read_json("./b1e56b55-0580-4fa7-9f0a-614fdcb4f8e5_1/DI_CONNECT/DI-Connect-Wellness/2021-03-25_2021-07-03_96859743_sleepData.json")

# # reads in as dataframe - YES
# sleep_data <- 
#   fromJSON("./b1e56b55-0580-4fa7-9f0a-614fdcb4f8e5_1/DI_CONNECT/DI-Connect-Wellness/2021-03-25_2021-07-03_96859743_sleepData.json", flatten=TRUE)


#' unpack into a df/tibble XXX already unpacked into a tibble with either `read_json` or `fromJSON`, 
#' but `fromJSON` puts into a usable, unnested format-- 1 row for each date, with column for all sleep data

# sleep_data %>% gather_object %>% json_types %>% count(name, type)
# sleep_data %>% spread_all

#' TODO expand cycles data to daily data (from cycles) and mark for phase and/or during/not during period.
#' then join with sleep data to explore those trends
cycles_data <- fromJSON("./b1e56b55-0580-4fa7-9f0a-614fdcb4f8e5_1/DI_CONNECT/DI-Connect-Wellness/96859743_MenstrualCycles.json", flatten = T)

files_list <- list.files(path = "./b1e56b55-0580-4fa7-9f0a-614fdcb4f8e5_1/DI_CONNECT/DI-Connect-Wellness", pattern = "sleepData", full.names = T)
list <- lapply(files_list, fromJSON, flatten=T)
sleep_data <- list %>% rbindlist(fill = TRUE, use.names = T)

# write_csv(sleep_data, "./sleep/sleep_data_flat_2021thr20240705.csv")

sleep <- sleep_data %>% 
  # fix dates/times
  mutate(
    # convert timezones from UTC to PST/PDT
    start = lubridate::with_tz(as_datetime(sleepStartTimestampGMT, tz = "GMT"), tzone = "America/Los_Angeles"),
    end = lubridate::with_tz(as_datetime(sleepEndTimestampGMT, tz = "GMT"), tzone = "America/Los_Angeles"),
    # correct for after-midnight bedtimes
    DATE = as_date(ifelse(as_date(start) == as_date(end), as_date(start-days(1)), as_date(start))))  %>% 
  mutate(deep_min = deepSleepSeconds/60,
         light_min = lightSleepSeconds/60,
         rem_min = remSleepSeconds/60,
         awake_min = awakeSleepSeconds/60) %>% 
  select(-c(retro, spo2SleepSummary.userProfilePk, spo2SleepSummary.deviceId, userNote,
            spo2SleepSummary.sleepMeasurementStartGMT, spo2SleepSummary.sleepMeasurementEndGMT,
            deepSleepSeconds, lightSleepSeconds, remSleepSeconds, awakeSleepSeconds))

colnames(sleep) <- gsub("\\.", "_", colnames(sleep))

write_csv(sleep, "./sleep/sleep_better_2021thr20240705.csv")

ggplot(sleep) + 
  #geom_line(aes(fill=sleepScores_overallScore)) +
  geom_line(aes(x=DATE, y=sleepScores_overallScore, colour = deep_min)) +
  scale_fill_continuous(type = "viridis")
  # scale_fill_distiller(palette = "Spectral")
  # scale_fill_gradientn( colors = topo.colors(6))
  
