import pandas as pd
import os

# Change directory (optional)
os.chdir(r'C:/Users/Ruhi/Downloads/hsl')
print("File will be saved in:", os.getcwd())

# Load the dataset
def load_dataset():
    try:
        data = pd.read_csv("nifty_500.csv")
        # Validate required columns
        required_columns = ['Percentage Change', 'Share Volume', 'Company Name', 'Symbol']
        for col in required_columns:
            if col not in data.columns:
                raise ValueError(f"Missing required column: {col}")
        # Ensure numeric columns are cleaned
        numeric_columns = ['Percentage Change', 'Share Volume']
        for col in numeric_columns:
            data[col] = pd.to_numeric(data[col], errors='coerce')  # Convert to numeric
        print("Dataset loaded successfully. Preview:")
        print(data.head())
        return data
    except FileNotFoundError:
        print("Error: nifty_500 dataset not found. Ensure it's in the same directory.")
        return None
    except ValueError as ve:
        print(ve)
        return None

# Fetch stock data based on user query
def fetch_stock_data(stock_name_or_symbol, data):
    try:
        stock = data[(data['Company Name'].str.lower() == stock_name_or_symbol.lower()) |
                     (data['Symbol'].str.lower() == stock_name_or_symbol.lower())]
        if not stock.empty:
            return stock.iloc[0].to_dict()  # Return first match as dictionary
        else:
            print(f"No data found for stock: {stock_name_or_symbol}")
            return None
    except Exception as e:
        print(f"Error fetching stock data: {e}")
        return None

# Detect potential fraud in stock data
def detect_fraud(stock_data, change_threshold=10, volume_threshold=1000000):
    fraud_warnings = []
    if abs(stock_data['Percentage Change']) > change_threshold:
        fraud_warnings.append(f"Unusual percentage change detected: {stock_data['Percentage Change']}%")
    if stock_data['Share Volume'] > volume_threshold:
        fraud_warnings.append(f"High trading volume detected: {stock_data['Share Volume']}")
    if fraud_warnings:
        return "\n".join(fraud_warnings)
    return "No suspicious activity detected."


def save_data_for_r(data):
    try:
        relevant_data = data[['Share Volume', 'Percentage Change','Symbol','Industry','Company Name']].dropna()
        if relevant_data.empty:
            print("No data to save for R visualization.")
            return
        save_path = r'C:/Users/Ruhi/Downloads/hsl/scatter_plot_data.csv'
        relevant_data.to_csv(save_path, index=False)
        print(f"Data saved for R visualization at: {save_path}")
    except Exception as e:
        print(f"Error saving data for R: {e}")





def chatbot():
    print("Welcome to the Nifty 500 Stock Market Chatbot!")
    data = load_dataset()
    if data is None:
        print("Dataset not loaded. Exiting chatbot.")
        return

    while True:
        stock_name_or_symbol = input("Enter the stock name or symbol (or type 'exit' to quit): ")
        if stock_name_or_symbol.lower() == "exit":
            # print("Saving data and exiting chatbot...")
            # save_data_for_r(data)  # Save data before exiting
            print("Goodbye!")
            break

        result = fetch_stock_data(stock_name_or_symbol, data)
        if result:
            print(f"\nStock Data for {result['Company Name']} ({result['Symbol']}):")
            for key, value in result.items():
                print(f"{key}: {value}")
            fraud_alert = detect_fraud(result)
            print(f"\nFraud Detection Result: {fraud_alert}")
            print("Saving data and exiting chatbot...")
            save_data_for_r(data)  # Save data before exiting

# Run the chatbot
chatbot()
