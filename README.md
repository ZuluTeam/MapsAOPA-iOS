# MapsAOPA-iOS

## Build
To build the project you have to create **AOPANetwork.Config.swift** in the *MapsAOPA-iOS/MapsAOPA/Classes* directory.
**AOPANetwork.Config.swift** must contain extension for *AOPANetwork* struct with apiKey
 You can get api key in your profile on http://maps.aopa.ru/user/export/
#### Please do not add AOPANetwork.Config.swift file to git repository (it's in .gitignore already)
 ```
 extension AOPANetwork {
    let apiKey = "..."
 }
 ```
