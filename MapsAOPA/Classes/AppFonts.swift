//
//  AppFonts.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/27/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    static func makiFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Maki", size: size)!
    }
}

enum AppIcons : String {
    
// MARK: Maki icons
    case MakiAbovegroundRail = "\u{e800}"
    case MakiAirfield = "\u{e801}"
    case MakiAirport = "\u{e802}"
    case MakiArtGallery = "\u{e803}"
    case MakiBar = "\u{e804}"
    case MakiBaseball = "\u{e806}"
    case MakiBasketball = "\u{e807}"
    case MakiBeer = "\u{e808}"
    case MakiBelowgroundRail = "\u{e809}"
    case MakiBicycle = "\u{e80a}"
    case MakiBus = "\u{e80b}"
    case MakiCafe = "\u{e80c}"
    case MakiCampsite = "\u{e80d}"
    case MakiCemetery = "\u{e80e}"
    case MakiCinema = "\u{e80f}"
    case MakiCollege = "\u{e810}"
    case MakiCommericalBuilding = "\u{e811}"
    case MakiCreditCard = "\u{e812}"
    case MakiCricket = "\u{e813}"
    case MakiEmbassy = "\u{e814}"
    case MakiFastFood = "\u{e815}"
    case MakiFerry = "\u{e816}"
    case MakiFireStation = "\u{e817}"
    case MakiFootball = "\u{e818}"
    case MakiFuel = "\u{e819}"
    case MakiGarden = "\u{e81a}"
    case MakiGiraffe = "\u{e81b}"
    case MakiGolf = "\u{e81c}"
    case MakiGroceryStore = "\u{e81e}"
    case MakiHarbor = "\u{e81f}"
    case MakiHeliport = "\u{e820}"
    case MakiHospital = "\u{e821}"
    case MakiIndustrialBuilding = "\u{e822}"
    case MakiLibrary = "\u{e823}"
    case MakiLodging = "\u{e824}"
    case MakiLondonUnderground = "\u{e825}"
    case MakiMinefield = "\u{e826}"
    case MakiMonument = "\u{e827}"
    case MakiMuseum = "\u{e828}"
    case MakiPharmacy = "\u{e829}"
    case MakiPitch = "\u{e82a}"
    case MakiPolice = "\u{e82b}"
    case MakiPost = "\u{e82c}"
    case MakiPrison = "\u{e82d}"
    case MakiRail = "\u{e82e}"
    case MakiReligiousChristian = "\u{e82f}"
    case MakiReligiousIslam = "\u{e830}"
    case MakiReligiousJewish = "\u{e831}"
    case MakiRestaurant = "\u{e832}"
    case MakiRoadblock = "\u{e833}"
    case MakiSchool = "\u{e834}"
    case MakiShop = "\u{e835}"
    case MakiSkiing = "\u{e836}"
    case MakiSoccer = "\u{e837}"
    case MakiSwimming = "\u{e838}"
    case MakiTennis = "\u{e839}"
    case MakiTheatre = "\u{e83a}"
    case MakiToilet = "\u{e83b}"
    case MakiTownHall = "\u{e83c}"
    case MakiTrash = "\u{e83d}"
    case MakiTree1 = "\u{e83e}"
    case MakiTree2 = "\u{e83f}"
    case MakiWarehouse = "\u{e840}"
}
