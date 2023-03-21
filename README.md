# SmsHubAPI Swift Library #

SmsHubAPI is a Swift library that provides an easy-to-use interface for interacting with the SmsHub API. With this library, you can access various [SmsHub services](https://smshub.org/en/main), such as getting your account balance, purchasing a phone number, setting and retrieving the status of an activation, and more.

## Features ##

* Swift concurrency support with async/await
* Simple, protocol-based API
* Lightweight and modular

## Requirements ##

* iOS 15.0+
* Swift 5.6+

## Installation ##

Add the library to your project using Swift Package Manager:

1. Open your project in Xcode.
2. Go to File > Swift Packages > Add Package Dependency.
3. Enter the repository URL for the SmsHubAPI library and click Next.
4. Choose the latest available version and click Next.
5. Select the target where you want to use SmsHubAPI and click Finish.

## Usage ##

First, import the **_SmsHubAPI_** library in your Swift file:

```swift
import SmsHubAPI
```

To start using the library, create an instance of **_SmsHubAPI_** with your API key:

```swift
let smsHubAPI = SmsHubAPI(apiKey: "your_api_key_here")
```
Now, you can call the methods provided by the **_SmsHubAPI_** protocol:

### Get Account Balance ###

```swift
do {
    let balance = try await smsHubAPI.getBalance()
    print("Account balance: \(balance)")
} catch {
    print("Error: \(error)")
}
```

### Purchase Phone Number ###

```swift
let getNumber = GetNumberRequest(service: "example_service", operator: "operator_name", country: "country_name")

do {
    let (id, phone) = try await smsHubAPI.purchasePhoneNumber(by: getNumber)
    print("Purchased phone number: \(phone) with ID: \(id)")
} catch {
    print("Error: \(error)")
}
```

### Set Activation Status ###

```swift
do {
    let response = try await smsHubAPI.setStatus(id: activationId, status: .smsSent)
    print("Status set response: \(response)")
} catch {
    print("Error: \(error)")
}
```

### Get Activation Status ###

```swift
do {
    let (status, code) = try await smsHubAPI.getStatus(id: activationId)
    print("Activation status: \(status)")

    if let code = code {
        print("Activation code: \(code)")
    }
} catch {
    print("Error: \(error)")
}
```

For more information on the available methods and their parameters, refer to the **_ISmsHubAPI_** protocol and the library's source code.

## License ##

This project is released under the MIT License.
