# Load package
require(ggplot2)

## An example of how to visualize lm model
str(mtcars)

## Build model
model <- lm(disp ~ mpg, data = mtcars)

## plot with basic package
plot(disp ~ mpg, data = mtcars)
abline(model)

## plot with ggplot
ggplot(mtcars, aes(x = mpg, y = disp)) +
  geom_point() +
  stat_smooth(method = "lm")
