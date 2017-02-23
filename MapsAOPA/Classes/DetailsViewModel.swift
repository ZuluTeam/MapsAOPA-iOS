//
//  DetailsViewModel.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/22/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

struct DetailsCellViewModel {
    let title : String?
    let subtitle : String?
    let value : String?
}

class DetailsViewModel {
    private enum DetailsReuseIdentifier : String
    {
        case ContactsCell
        case FrequenciesCell
        
        var cellClass : String
        {
            switch self {
            case .ContactsCell: return "PhoneTableViewCell"
            case .FrequenciesCell: return "FrequenciesTableViewCell"
            }
        }
    }
    
    let cellViewModels : [DetailsCellViewModel]
    var reuseIdentifier : String {
        return cellReuseIdentifier.rawValue
    }
    private let cellReuseIdentifier : DetailsReuseIdentifier
    
    var phoneNumber : Property<String?> { return Property(_phoneNumber) }
    private let _phoneNumber = MutableProperty<String?>(nil)
    
    init(frequencies: [Frequency]) {
        self.cellViewModels = frequencies.map({
            DetailsCellViewModel(title: $0.callsign, subtitle: $0.type, value: "Frequencies_Format".localized(arguments: $0.frequency))
        })
        self.cellReuseIdentifier = .FrequenciesCell
    }
    
    init(contacts: [Contact]) {
        self.cellViewModels = contacts.map({
            DetailsCellViewModel(title: $0.name, subtitle: $0.type, value: $0.phone)
        })
        self.cellReuseIdentifier = .ContactsCell
    }
    
    func selectAction(with cellModel: DetailsCellViewModel?) {
        switch cellReuseIdentifier {
        case .ContactsCell: _phoneNumber.value = cellModel?.value
        default: break
        }
    }
    
    private func createContact(with cellModel: DetailsCellViewModel) {
        
    }
}
