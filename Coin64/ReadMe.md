# Coin64

**Coin64** is a small iOS application built with **Swift** and minimum iOS 15 that displays the historical prices of **Bitcoin (BTC)** over the last 14 days in **Euro (EUR)**. Tapping on a date row shows more detailed information for that day in **three currencies**: EUR, USD, and GBP.

- For the API service, I used CoinDesk free APIs:
  - https://data-api.coindesk.com/index/cc/v1/latest/tick
    - gets the latest BTC prices in three currencies(EUR,USD,GBP)
  - https://data-api.coindesk.com/index/cc/v1/historical/days
    - gets the history of BTC prices in last 14 days

- Results are sorted from the most recent prices to older prices. First row(record) is today's value.

- First row will be updated every 60 seconds.(we can modify `refreshRateInSeconds` to change the refresh rate to the desired frequency) 

---

## Features

- Fetches the last **14 days** of BTC data in **EUR**
- Displays a simple, clean **UITableView** with daily prices
- Tapping a row reveals a **detailed view** showing the BTC value in:
  - **EUR**
  - **USD**
  - **GBP**
- Shows loading indicators and error messages (Kept it simple to satisfy the task purposes)
- Built entirely **programmatically** (no Storyboards)

---

## Architecture

The project follows the **MVVM (Model-View-ViewModel)** pattern and has cleanly separated layers:

- **Model Wrapper Layer**: 
  - `CoinInfoResponse`, `CoinCurrentResponse`, and related DTOs
- **Repository Layer**:
  - `CoinRepositoryProtocol` and `CoinRepository` handle all data fetching logic
- **Service Layer**:
  - `CoinServiceProvider` abstracts networking logic
- **ViewModels**:
  - `CoinListViewModel`: fetches historical data and manages auto-refresh
  - `CoinDetailViewModel`: fetches multi-currency data for a selected date
- **Views / Controllers**:
  - Simple SwiftUI-based screens using `SwiftUI` and `Combine`

---

## Testing

- Includes unit tests for ViewModels and Repository logic
- Xcode Code coverage report: 100% of logics (pure view componenets are not included)
- Mock services used to simulate API success and failure scenarios


