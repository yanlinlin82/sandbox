library(tidyverse)
library(ggplot2)
library(ggvenn)

# this function is from ggvenn package, so you can
# declare it by yourself, or use `ggvenn:::gen_circle` directly
gen_circle <- function(group, x_offset = 0, y_offset = 0, radius = 1,
                       radius_b = radius, theta_offset = 0, length.out = 100) {
  tibble(group = group,
         theta = seq(0, 2 * pi, length.out = length.out)) %>%
    mutate(x_raw = radius * cos(theta),
           y_raw = radius_b * sin(theta),
           x = x_offset + x_raw * cos(theta_offset) - y_raw * sin(theta_offset),
           y = y_offset + x_raw * sin(theta_offset) + y_raw * cos(theta_offset))
}

# we can create this function for text around circle
gen_circle_text <- function(text, group, x_offset = 0, y_offset = 0, radius = 1,
                            radius_b = radius, theta_offset = 0,
                            start_angle = 0, end_angle = 180) {
  n <- nchar(text)
  angles <- seq(from = start_angle, to = end_angle, length.out = (1 + n))[1:n]
  tibble(group = group,
         letter = strsplit(text, '')[[1]],
         x_raw = radius * cos(angles * pi / 180),
         y_raw = radius_b * sin(angles * pi / 180),
         x = x_offset + x_raw * cos(theta_offset) - y_raw * sin(theta_offset),
         y = y_offset + x_raw * sin(theta_offset) + y_raw * cos(theta_offset),
         text_angle = angles - 90)
}

# Create the plot for demo
g = ggplot() +
  geom_polygon(aes(x, y, fill = group),
               color = "darkgray", alpha = 0.5,
               data = rbind(
                 ggvenn:::gen_circle('A', 1, 1),
                 ggvenn:::gen_circle('B', 2.5, 1)
               )) +
  geom_text(aes(x, y, label = letter, angle = text_angle),
            color = "black", size = 5,
            data = rbind(
              gen_circle_text('Text for A group', 'A', 1, 1,
                              radius = 1.1, start_angle = 120, end_angle = 60),
              gen_circle_text('Text for B group', 'B', 2.5, 1,
                              radius = 1.1, start_angle = 120, end_angle = 60)
            )) +
  geom_text(aes(x, y, label = text),
            color = "black", size = 4,
            data = tribble(
              ~x, ~y, ~text,
              1, 1, 'AAA, FOO\nXYZ',
              2.5, 1, 'BBB, BAR\n123',
              1.75, 1, 'both'
            )) +
  coord_fixed() +
  theme_void() +
  theme(plot.margin = margin(1, 1, 1, 1, "cm"))
print(g)
ggsave(g, filename = "test-venn-20240109.png", bg = "white")
