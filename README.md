# SmartKitty
<p align=“center”>
<img src="https://img.shields.io/badge/Swift-5.2-orange.svg?style=flat&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Xcode-11.5-blue.svg?style=flat&logo=xcode&logoColor=white" />
<img src="https://img.shields.io/badge/platform-iOS-000000.svg?style=flat" />
</p>

SmartKitty is a free third-party app for [SmartCat](https://smartcat.ai) translation platform. It’s built for translation project managers to help them search and navigate the projects, get project details, share project link with colleagues and never miss the deadline. 

## Usage

To login and use the app users are required to have a LSP account at [SmartCat](https://smartcat.ai). Company account ID is used as a username and API key is used as a password. Users can generate the API key in their Smartcat account under Settings -> API.

## 📱 Features

Straight from app’s homescreen users can jump into 4 categories: projects with deadline due today, tomorrow, favourite projects or browse all projects.

Project statuses are easily recognized by different icons assigned accordingly to project’s stage.

Instant search allows to filter projects by name as user start typing in the search bar.

Project title can be easily copied to clipboard just by tapping on it. Once copied users can use it in other apps on their devices (for example in messengers while communicating project details with colleagues).

Users can mark any project as a favourite and access it right from app’s homescreen Favourite category.

Sharing project’s link to a colleague has never been easier - just tapping on a Share button will bring iOS share sheet, so users can choose sharing via mail, messages, AirDrop or any other installed app.

Offline mode enables users to browse projects when there is no internet connection.
## 🛠 Implementation details

### 🧭 Navigation
The app is built using classic scheme: *UINavigationController* embedded in *UITabBarController*. 

In most cases the transition between controllers utilizes *present(_:animated:completion:)* method. Presentation style of new view controller is defined by *modalPresentationStyle* and *modalTransitionStyle* properties.

### 🕸 Networking
All networking logic is encapsulated in a separate class. 

*UIActivityViewController* is used to show the networking activity.

 Encoding and decoding of requests is supported by structs that conform to *Codable* protocol.

Connection failures are detected using *code* property of *URLError* struct. Appropriate alerts are displayed to users.

All possible request errors are handled using *HTTPStatusCodes* enum holding all possible server responses.

Smartcat API endpoints are constructed with the help of *URLComponents* struct.

### 🗄 Data Persistence
Users data is saved on the device using *Core Data* framework. *Core Data* stack is built using singleton pattern and encapsulated in a separate class. 

There are 5 entities in the data model. SkProject is the main object and others objects are complementing it.
![Core Data Entities](https://github.com/OlehTitov/SmartKitty/blob/master/images/coreDataDiagram.png)

### 🖼 Collection Views
All collection views are built with modern approach using  *UICollectionViewDiffableDataSource* and *NSDiffableDataSourceSnapshot*. This allows to avoid manual coordination of updates and makes it possible to apply more complex layout.
### 🛣 Roadmap

Please see the list of upcoming updates in the [Issues] (https://github.com/OlehTitov/SmartKitty/issues) section.

## Thank you for your interest!
This app is made within my **Udacity iOS Developer Nanodegree** learning path. If you have any ideas or suggestions you can open an issue or simply contact me in [Twitter] (https://twitter.com/olegTitov81)  😊




