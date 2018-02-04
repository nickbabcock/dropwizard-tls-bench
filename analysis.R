library(tidyverse)
library(readr)

df <- read_csv("tlsbench2.csv")

g <- df %>%
  mutate(`jce provider` = ifelse(is.na(`jce provider`), "Default", `jce provider`)) %>%
  group_by(`app type`, `endpoint type`, `jce provider`, payload) %>%
  summarize(reqs = max(`req/s`)) %>%
  ungroup() %>%
  group_by(`app type`, `endpoint type`, payload) %>%
  mutate(diff = reqs - min(reqs), ratio = (reqs / min(reqs)) - 1) %>%
  ungroup() %>%
  filter(`jce provider` == "Conscrypt", `endpoint type` != "servlet-nonblocking")

ggplot(g, aes(payload, ratio, colour = `endpoint type`)) +
  geom_line(stat = 'identity') +
  facet_grid(`app type` ~ .) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Dropwizard TLS Performance Improvements using Conscrypt",
       subtitle = "Percentage increase in echo server requests served vs default JCE provider") +
  ylab("Percentage improvement") +
  xlab("Bytes echoed back (log10)") +
  scale_x_log10(breaks = c(1, 10, 100, 1000, 10000, 100000), labels = scales::comma)
