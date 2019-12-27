library(tidyverse)
library(readr)
library(fs)
library(tidyboot)



import_metagol <- function(wave) {
  switch(wave, "1_5" = import_metagol_1_5(), "2" = import_metagol_2())
}
import_metagol_1_5 <- function() {
  read_csv("data/waves/1_5/metagol.csv",
           col_names = c("i_run", "i_N", "concept", "input", "correct",
                         "predicted", "accurate", "resolutions"),
           col_types = "iifcccli",
           na = c("null")) %>%
    mutate(accuracy = accurate*1) %>%
    select(-accurate)
}
import_metagol_2 <- function() {
  read_lines("data/waves/2/metagol.csv") %>%
    map(~ str_replace(.,
                      "^([^,]+), ([^,]+), ([^,]+), ([^\ ]+), ([^\ ]+), ([^\ ]+), ([^,]+), ([^,]+)(|, (.+))$",
                      "\\1,\\2,\\3,\"\\4\",\"\\5\",\"\\6\",\\7,\\8,\\10")) %>%
    str_c("\n") %>%
    read_csv(col_names = c("i_run", "i_N", "concept", "input", "correct", "predicted", "accurate", "time", "resolutions"),
             col_types = "iifcccldi",
             na = c("null","")) %>%
    mutate(accuracy = accurate * 1,
           concept = factor(concept, labels = concept_labels(2))) %>%
    select(-accurate)
}
import_enumeration <- function(wave) {
  read_csv(paste("data/waves/",wave,"/enumeration.csv", sep=""),
           col_names = c("i_run", "i_N", "concept", "input", "correct",
                         "predicted", "accuracy"),
           col_types = "iifccci",
           na = c("null", "NA")) %>%
    mutate(input = str_replace(input, coll("("), "["),
           correct = str_replace(correct, coll("("), "["),
           predicted = str_replace(predicted, coll("("), "[")) %>%
    mutate(input = str_replace(input, coll(")"), "]"),
           correct = str_replace(correct, coll(")"), "]"),
           predicted = str_replace(predicted, coll(")"), "]")) %>%
    mutate(concept = factor(concept, labels = concept_labels(wave)))
}
concept_labels <- function(wave) {
  n <- switch(as.character(wave), "1" = 20, "1_5" = 20, "2" = 55)
  seq(0, n) %>% str_pad(width=3, pad="0") %>% str_c("c",.,collapse=NULL)
}

import_robustfill <- function(wave) {
  read_lines(paste("data/waves/",wave,"/robustfill.txt", sep=""), skip=12) %>%
    map(~ str_replace(.,
                      "i_run: (.*), i_N: (.*), task ID: (.*), test input: .(.*),., test output: (.*), prediction: (.*), correct: (.*)",
                      "\\1,\\2,\\3,\"\\4\",\"\\5\",\"\\6\",\\7")) %>%
    str_c("\n") %>%
    read_csv(col_names = c("i_run", "i_N", "concept", "input", "correct", "predicted", "accurate"),
             na = c("None")) %>%
    mutate(accuracy = accurate * 1,
           concept = factor(robustfill_task(concept, wave))) %>%
    select(-accurate)
}

robustfill_task <- function(n, wave) {
  x <- if(wave == "2") {
         recode(n+1, 22, 55, 38, 0, 47, 39, 46, 32, 16, 27, 3, 28, 1, 37, 24,
                54, 31, 34, 25, 14, 6, 43, 17, 29, 2, 44, 9, 51, 50, 15, 48, 36,
                26, 33, 41, 11, 30, 7, 45, 21, 8, 49, 20, 40, 19, 35, 5, 4, 42,
                10, 18, 12, 53, 52, 13, 23)
  } else {
    recode(n+1, 7, 13, 15, 18, 20, 2, 3, 1, 12, 10, 17, 5, 0, 14, 6, 8, 19, 16,
           11, 9, 4)
  }
  x %>% str_pad(width=3, pad="0") %>% str_c("c", ., collapse=NULL)
}

import_fleet <- function(wave) {
    fs::dir_ls(paste("data/waves/",wave,"/fleet/out-1m", sep=""), glob = "*txt") %>%
      map(~ read_tsv(., comment="#", col_types = "ddccccdc", quoted_na=FALSE)) %>%
      bind_rows() %>%
      rename(accuracy = correct,
             predicted = output,
             correct = correct.output) %>%
      mutate(concept = factor(switch(as.character(wave),
                                     "1_5" = str_replace(concept, "data/(.*).txt", "\\1"),
                                     "2" = str_replace(concept, "data/c2-(.*).txt", "c\\1"))))
}

import_toolkit <- function() {
  names <- fs::dir_ls("toolkit/", glob = "*csv")
  names %>%
    map(~ toolkit_helper(.)) %>%
    bind_rows() %>%
    rename(i_N = n,
           predicted = prediction,
           correct = output) %>%
    mutate(concept = factor(str_sub(name, 9, 12)),
           i_run = as.double(str_sub(name, 14, 14))) %>%
    select(-name) %>%
    select(concept, i_N, i_run, accuracy, input, correct, predicted, everything())
}

toolkit_helper <- function(name) {
  read_csv(name, col_types = "dddccc") %>% mutate(name = name)
}

import_all <- function(wave) {
  # map2(c(import_metagol, import_fleet, import_enumeration, import_robustfill, import_toolkit),
  #     c("metagol", "fleet", "enumeration", "robustfill", "toolkit"),
  map2(c(import_metagol, import_fleet, import_enumeration, import_robustfill),
       c("metagol", "fleet", "enumeration", "robustfill"),
       ~ prep(.x, .y, wave)) %>%
    bind_rows() %>%
    mutate(model = factor(model)) %>%
    select(model, everything()) %>%
    arrange(model, concept, i_N, i_run)
}

prep <- function(fn, name, wave) {
  fn(wave) %>%
    select(concept, i_N, i_run, accuracy, input, correct, predicted) %>%
    mutate(model=name)
}


bootstrap_all <- function(all) {
  all %>%
    group_by(model, concept, i_N) %>%
    tidyboot_mean(column = accuracy)
}

plot_lines_by_concept <- function(wave, bootstrap) {
  rank <- bootstrap %>%
    group_by(concept) %>%
    dplyr::summarize(rank = mean(mean)) %>%
    mutate(rank = rank(1/rank, ties.method="first")) %>%
    arrange(rank) %>%
    mutate(rank = factor(rank, labels=concept))
  bootstrap %>%
    left_join(rank) %>%
    ggplot(aes(x = i_N+1, y = mean, color=model)) +
    geom_ribbon(aes(x = i_N+1, ymax = ci_upper, ymin = ci_lower), alpha = 0.2, size = 0, fill = "#666666") +
    geom_line(size=0.25, position=position_jitter(height=0.02, width=0)) +
    facet_wrap(vars(rank),
               nrow = switch(as.character(wave), "1_5" = 7, "2" = 28),
               ncol = switch(as.character(wave), "1_5" = 3, "2" = 2)) +
    labs(x = "Prediction",
         y = "Mean Accuracy",
         title = "Wave 1.5 Performance") +
    theme(legend.position = "top",
          plot.title = element_text(hjust = 0.5)) +
    scale_x_continuous(breaks=c(0, 5, 10, 15, 20)) +
    scale_y_continuous(breaks=c(0, 0.5, 1.0)) +
    ggsave(paste0("data/waves/",wave,"/plot_lines_by_concept.pdf"),
           width = switch(as.character(wave), "1_5" = 16, "2" = 11),
           height = switch(as.character(wave), "1_5" = 7, "2" = 28))
}

plot_bar <- function(bootstrap) {
  rank <- bootstrap %>% group_by(concept) %>% dplyr::summarize(rank = mean(mean)) %>% mutate(rank = rank(1/rank)) %>% arrange(rank) %>% mutate(rank = factor(rank, labels=concept))
  bootstrap %>%
    left_join(rank) %>%
    filter(i_N %in% c(0,1,2,4,9,14,19)) %>%
    mutate(i_N = factor(i_N+1)) %>%
    arrange(desc(rank)) %>%
    ggplot(aes(x = model, group=i_N, y = mean, fill=model)) +
    geom_bar(position="dodge", stat="identity") +
    geom_errorbar(aes(x = model, ymax = ci_upper, ymin = ci_lower), width = 0.0, size=0.25, color = "#666666", position=position_dodge(width=0.9)) +
    facet_wrap(vars(rank), nrow = 7, ncol = 3) +
    labs(x = "Model",
         y = "Mean Accuracy",
         fill = "Model",
         title = "Wave 1.5 Performance") +
    theme(legend.position = "top",
          plot.title = element_text(hjust = 0.5)) +
    scale_y_continuous(breaks=c(0, 0.5, 1.0)) +
    ggsave("barplot.pdf", width=16, height=7)
}

plot_bar_by_data <- function(wave, bootstrap) {
  rank <- bootstrap %>% group_by(concept) %>% dplyr::summarize(rank = mean(mean)) %>% mutate(rank = rank(1/rank, ties.method="first")) %>% arrange(rank) %>% mutate(rank = factor(rank, labels=concept))
  bootstrap %>%
    left_join(rank) %>%
    filter(i_N %in% c(0,1,2,4,9,14,19)) %>%
    mutate(i_N = factor(i_N+1)) %>%
    # arrange(desc(rank)) %>%
    ggplot(aes(x = rank, y = mean, fill=model)) +
    geom_bar(position=position_dodge(width=0.7), width=0.6, stat="identity") +
    geom_errorbar(aes(x = concept, ymax = ci_upper, ymin = ci_lower), width = 0.0, size=0.25, color = "#666666", position=position_dodge(width=0.7)) +
    geom_point(aes(shape=model), position=position_dodge(width=0.7), size=1, color="#666666", fill="#666666")+
    facet_wrap(vars(i_N), nrow = 7, ncol = 1) +
    labs(x = "Concept",
         y = "Mean Accuracy",
         shape = "",
         fill = "",
         title = "Wave 1.5 Performance by Prediction No.") +
    theme(legend.position = "top",
          plot.title = element_text(hjust = 0.5)) +
    scale_y_continuous(breaks=c(0, 0.5, 1.0)) +
    ggsave(paste0("data/waves/",wave,"/plot_bar_by_data.pdf"),
         width = switch(as.character(wave), "1_5" = 16, "2" = 43),
         height = switch(as.character(wave), "1_5" = 7, "2" = 7))
}
