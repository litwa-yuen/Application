import requests
import json
import sys

# API key for Alpha Vantage API
api_key = "3C5NQZHT8EP4J77B"

# Function to fetch stock data from Alpha Vantage API
def get_stock_data(symbol):
    url = f"https://www.alphavantage.co/query?function=OVERVIEW&symbol={symbol}&apikey={api_key}"
    response = requests.get(url)
    data = json.loads(response.text)
    return data

# Function to calculate recommendation based on P/E ratio, EPS, and P/B ratio
def get_recommendation(symbol):
    stock_data = get_stock_data(symbol)
    print(stock_data)
    pe_ratio = float(stock_data["PERatio"])
    eps = float(stock_data["EPS"])
    pb_ratio = float(stock_data["PriceToBookRatio"])

    if pe_ratio < 15 and eps > 0 and pb_ratio < 2:
        recommendation = "Buy"
    elif pe_ratio > 20 or eps <= 0 or pb_ratio > 3:
        recommendation = "Sell"
    else:
        recommendation = "Hold"

    return recommendation

# Example usage
symbol = "AAPL"
if len(sys.argv) > 1:
    symbol = sys.argv[1]
recommendation = get_recommendation(symbol)
print(f"The recommendation for stock {symbol} is: {recommendation}")
