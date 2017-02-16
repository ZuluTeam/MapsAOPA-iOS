//
//  AOPANetwork.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/15/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation

struct AOPANetwork {
    private static let apiURL = "http://maps.aopa.ru"
    private static let dataPath = "/export/exportFormRequest/?api_key=\(AOPANetwork.apiKey)&exportAll%5B%5D=airport&exportAll%5B%5D=vert&exportFormat=xml&exportType=standart"
    private static let imagesPath = "/static/pointImages/"
    private static let imagesURL = apiURL + imagesPath
    
    static let dataURL = apiURL + dataPath
    
    static func imageURL(for imagePath: String) -> String {
        return self.imagesURL + imagePath
    }
}

/*
 AOPANetwork.Config.swift must contain extension for AOPANetwork struct with apiKey
 You can get api key in your profile on http://maps.aopa.ru/user/export/
 Please do not add AOPANetwork.Config.swift file to git repository
 
 extension AOPANetwork {
    let apiKey = "..."
 }
 */
