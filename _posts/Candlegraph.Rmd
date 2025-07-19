---
title: "Candlegraph"
output: html_document
---

First, we'll load in our libraries. I'm using `library(here)` on the advice of Jenny Bryan from her [Project-oriented workflow](https://www.tidyverse.org/blog/2017/12/workflow-vs-script/) post on Tidyverse. This is just to organize my project into a folder in order to keep it self-contained and portable.

```{r message=FALSE}
# loading libraries
library(readr)
library(dplyr)
library(tidyverse)
library(here)
```

Next, we'll load in the data. This comes from 4 tabs of a Google Sheets file on which I've recorded my candle research. Variables include things such as the price and weight of a candle, as well as how long it burned.

```{r message=FALSE}
# loading data
brands <- read_csv("brands.csv")
burn_times <- read_csv("burn_times.csv")
materials <- read_csv("materials.csv")
purchases <- read_csv("purchases.csv")
```

Now that we've got our data, let's do something with it! Using the %\>% pipe character from the `dplyr` library, let's find the mean time that I let each candle burn for during a session.

```{r}
mean_session_times <- burn_times %>%
  group_by(candle_id) %>%
  summarize(mean = mean(session_time))
mean_session_times
```

Interestingly, it seems that the amount of time I let a candle burn for during each session trended upward over time, though it didn't always increase from one candle to the next. Let's use a bar graph to visualize the data. I'm using the `ggplot2` library to create the visual.

```{r}
viz <- ggplot(mean_session_times,aes(fill=as.factor(candle_id),x=candle_id,y=mean)) + geom_bar(stat = "identity", ,col="brown")
viz + labs(title="Average Session Times",subtitle="Data from Candlegraph",caption="The graph shows that I became less careful about keeping burn times down as time went on.",x="Candle ID",y="Hours",fill="Candle ID")
```

While the above graph is a good start, it doesn't tell us the candle names, just their IDs. This is because `burn_times.csv` and the `burn_times` data frame that was created from it do not have those names listed. But our `purchases` data frame does. Both frames contain the common column `candle_id`, which allows us to associate the `candle_id` with the candle name (`scent_name`) using an inner join.

```{r}
scents <- burn_times %>%
  inner_join(purchases)
scents
```

Now we have the ID of the candle and its associated name (listed as `scent_name`) in our data frame. For our purposes, we only need the `candle_id`, `session_time`, and `scent_name columns`, so let's update `scents` to include only those three column names, using the `select` function.

```{r}
scents <- scents %>%
  select(candle_id,session_time,scent_name)
scents
```

Now that we have the `session_time` linked to the `scent_name`, we can find the average (mean) time per session for each scent.

```{r}
mean_session_times <- scents %>%
  group_by(candle_id) %>%
  mutate(mean = mean(session_time)) %>%
  slice(1)
mean_session_times
```

That seems a little more readable. Let's use this new variable to create a bar chart similar to the one above. Note that I'm removing the text for the scent names on the x-axis, as it got a little crowded. Instead, we can use the legend on the right to tell us which bar represents which candle.

```{r}
viz <- ggplot(mean_session_times,aes(fill=scent_name,x=scent_name,y=mean)) + geom_bar(stat = "identity", ,col="brown") + theme(axis.text.x = element_blank())
viz + labs(title="Average Session Times",subtitle="Data from Candlegraph",x="Scent Name",y="Hours",fill="Scent Name")
```

That's much better! However, because we are labeling by the `scent_name` rather than the `candle_id`, the list is now in alphabetical instead of numerical order. To preserve the numerical order, we can use the `dplyr` library. (I discovered this trick from [Reorder a variable with ggplot2](https://r-graph-gallery.com/267-reorder-a-variable-in-ggplot2.html).)

```{r}
viz <- mean_session_times %>%
  arrange(mean) %>%
  mutate(scent_name=factor(scent_name,levels=scent_name)) %>%
  ggplot(aes(fill=scent_name,x=scent_name,y=mean)) + geom_bar(stat = "identity", ,col="brown") + theme(axis.text.x = element_blank())
viz + labs(title="Average Session Times",subtitle="Data from Candlegraph",x="Scent Name",y="Hours",fill="Scent Name")
```

Now the mean burn time for each session is listed in order of `candle_id`, and you can easily see the progession.

Thanks for reading!