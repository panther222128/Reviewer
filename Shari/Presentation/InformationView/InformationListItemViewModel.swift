//
//  InformationListItemViewModel.swift
//  Shari
//
//  Created by Horus on 6/22/24.
//

import Foundation

struct InformationListItemViewModel {
    let title: String
}

extension InformationListItemViewModel {
    init(information: Information) {
        self.title = information.title
    }
}
