# https://cran.r-project.org/web/packages/tidyjson/vignettes/introduction-to-tidyjson.html
# https://www.rdocumentation.org/packages/tidyjson/versions/0.3.2

library(dplyr)
library(tidyjson)

#' * JSON example (simple) *
# Define a simple people JSON collection
people <- c('{"age": 32, "name": {"first": "Bob",   "last": "Smith"}}',
            '{"age": 54, "name": {"first": "Susan", "last": "Doe"}}',
            '{"age": 18, "name": {"first": "Ann",   "last": "Jones"}}')

# Tidy the JSON data
people %>% spread_all

#' * JSON example (more complex, build in dataset) *
worldbank %>% spread_all

#' Some objects in worldbank are arrays, which are not handled by spread_all.
#' This example shows how to quickly summarize the top level structure of a 
#' JSON collection
worldbank %>% gather_object %>% json_types %>% count(name, type)

#' In order to capture the data in the majorsector_percent array, 
#' we can use enter_object to enter into that object, 
#' gather_array to stack the array and spread_all to capture the object items under the array.
worldbank %>%
  enter_object(majorsector_percent) %>%
  gather_array %>%
  spread_all %>%
  select(-document.id, -array.index)

