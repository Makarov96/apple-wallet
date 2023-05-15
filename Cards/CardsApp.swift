//
//  CardsApp.swift
//  Cards
//
//  Created by Guerin Steven Colocho Chacon on 7/05/23.
//

import SwiftUI


enum Router : Hashable{

    case transactionDetail(Transaction)
}

@main
struct CardsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                ContentView(cardSelected: CardModel(cardBrand: CardBrand.other, cardType: CardType.gold, cardNumber: "2354  4567  8860  1234",transactions: [])).navigationDestination(for: Router.self) { route in
                    switch route {
                    case .transactionDetail(let transaction):
                        TransationDetail(trasaction: transaction)
                    }
                    
                }
            }
        }
    }
}
