//
//  InformationDetailViewModel.swift
//  Shari
//
//  Created by Horus on 6/22/24.
//

import Foundation

struct InformationDetailViewModel {
    let title: String
    let url: URL?
}

extension InformationDetailViewModel {
    init(information: Information) {
        self.title = information.title
        self.url = information.url
    }
}
