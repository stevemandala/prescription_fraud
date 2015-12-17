## Get population over States
URL <- "http://simple.wikipedia.org/wiki/List_of_U.S._states_by_population"
Lines <- readLines(URL, encoding = "UTF-8")
states.lines <- grep(pattern = "<td align=\"left\"><span class=\"flagicon\"><img alt=\"\" src=", Lines, value = T)[1:50]
states.lineNum <- grep(pattern = "<td align=\"left\"><span class=\"flagicon\"><img alt=\"\" src=", Lines)[1:50]
pop.lineNum <- states.lineNum + 1
pop.lines <- Lines[pop.lineNum]
pop <- gsub(pattern = "(.+)>(.+)</td>", replace = "\\2", pop.lines)
states <- gsub(pattern = "(.*)title=(.+)</a></td>", replace = "\\2", states.lines)
states <- sub(pattern = "(.+)>(.+)", replace = "\\2", states)
states.pop <- data.frame(States = states, pop = pop)

## convert pop from string with "," to integer
states.pop$pop <- lapply(states.pop[,"pop"], FUN = function(x) {gsub(pattern = ",", replace = "", x)})
states.pop$pop <- as.integer(states.pop$pop)