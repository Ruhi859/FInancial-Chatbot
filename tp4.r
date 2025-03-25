# setwd("C:/Users/Ruhi/Downloads/hsl")  # Set the directory where the file is located
# print(list.files())  # List all files in the directory to ensure the CSV file is present
# data <- read.csv("scatter_plot_data.csv")  # Load the file
# head(data)  # Preview the data to ensure it loaded correctly
# 
# unique(data$Symbol)
# 


library(ggplot2)
library(plotly)
library(scales)

# Set working directory to the folder containing the dataset
setwd("C:/Users/Ruhi/Downloads/hsl")
print(list.files())  # List files to ensure the dataset is present

# Load the dataset
data <- read.csv("scatter_plot_data.csv")
head(data)  # Preview data to ensure it loaded correctly

# Clean dataset columns
data$Symbol <- trimws(toupper(data$Symbol))
data$Company.Name <- trimws(toupper(data$Company.Name))

# Validate dataset columns
if (!all(c("Symbol", "Share.Volume", "Percentage.Change", "Company.Name", "Industry") %in% colnames(data))) {
  stop("The required columns ('Symbol', 'Share.Volume', 'Percentage.Change', 'Company.Name', 'Industry') are missing from the dataset.")
}

# Add a sequential Index column to the dataset
data$Index <- seq_len(nrow(data))  # Sequential numbers from 1 to the number of rows

# Remove rows with missing or invalid values
data <- na.omit(data)  # Remove rows with NA values
data <- data[data$Percentage.Change >= -100 & data$Percentage.Change <= 100, ]  # Adjust range as needed

# Filter top industries to optimize performance
top_industries <- names(sort(table(data$Industry), decreasing = TRUE)[1:8])  # Select top 8 industries
data <- data[data$Industry %in% top_industries, ]

# Function to create a static scatter plot for the full dataset
create_static_scatter_plot <- function(data) {
  ggplot(data, aes(x = Share.Volume, y = Percentage.Change, color = Industry)) +
    geom_point(alpha = 0.7, size = 2) +
    geom_smooth(method = "lm", color = "red", se = FALSE) +
    labs(
      title = "Static Scatter Plot: Share Volume vs Percentage Change",
      subtitle = "Static visualization for all stocks",
      x = "Share Volume (log scale)",
      y = "Percentage Change",
      color = "Industry"
    ) +
    scale_x_continuous(trans = "log10", breaks = scales::log_breaks(n = 5), labels = scales::comma) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
      plot.subtitle = element_text(hjust = 0.5, size = 12, face = "italic"),
      legend.position = "right"
    )
}

# Function to create an interactive scatter plot for the full dataset
create_interactive_scatter_plot <- function(data) {
  ggplot(data, aes(x = Share.Volume, y = Percentage.Change, color = Industry, text = paste(
    "Symbol: ", Symbol, "<br>",
    "Share Volume: ", scales::comma(Share.Volume), "<br>",
    "Percentage Change: ", Percentage.Change, "<br>",
    "Industry: ", Industry
  ))) +
    geom_point(alpha = 0.7, size = 2) +
    geom_smooth(method = "lm", color = "red", se = FALSE) +
    labs(
      title = "Interactive Scatter Plot: Share Volume vs Percentage Change",
      subtitle = "Hover over points to see details",
      x = "Share Volume (log scale)",
      y = "Percentage Change",
      color = "Industry"
    ) +
    scale_x_continuous(trans = "log10", breaks = scales::log_breaks(n = 5), labels = scales::comma) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
      plot.subtitle = element_text(hjust = 0.5, size = 12, face = "italic"),
      legend.position = "right"
    )
}

# Function to create a segregated line chart for the dataset
create_line_chart <- function(data) {
  ggplot(data, aes(x = Index, y = Percentage.Change, group = Industry, color = Industry)) +
    geom_line(linewidth = 1) +  # Thinner lines for cleaner visuals
    geom_point(size = 2, alpha = 0.6) +  # Semi-transparent points
    facet_wrap(~ Industry, scales = "free_y", ncol = 2) +  # Limit to 2 columns for better rendering
    scale_color_manual(values = scales::hue_pal()(length(unique(data$Industry)))) +  # Dynamic color palette
    labs(
      title = "Line Chart: Percentage Change Across Industries",
      subtitle = "Trends observed over a sequential index",
      x = "Index (Sequential Order)",
      y = "Percentage Change",
      color = "Industry"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
      plot.subtitle = element_text(hjust = 0.5, size = 16, face = "italic"),
      legend.position = "top",  # Move legend to the top
      panel.grid.major = element_line(color = "gray90"),
      panel.grid.minor = element_blank()
    )
}

# Generate and display static scatter plot for the entire dataset
cat("Generating static scatter plot for the entire dataset...\n")
static_scatter_plot <- create_static_scatter_plot(data)
print(static_scatter_plot)

# Generate and display interactive scatter plot for the entire dataset
cat("Generating interactive scatter plot for the entire dataset...\n")
interactive_scatter_plot <- create_interactive_scatter_plot(data)
interactive_scatter_plot <- ggplotly(interactive_scatter_plot, tooltip = c("text"))
interactive_scatter_plot

# Generate and display segregated line chart for the dataset
cat("Generating segregated line chart for percentage change trends...\n")
line_chart <- create_line_chart(data)
print(line_chart)
