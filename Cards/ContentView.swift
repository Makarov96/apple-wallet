//
//  ContentView.swift
//  Cards
//
//  Created by Guerin Steven Colocho Chacon on 7/05/23.
//

import SwiftUI
import MapKit


struct ContentView: View {
    
    @State private var expandedCard:Bool = false
    @State var cardSelected: CardModel
    @State private var showDetailContent: Bool = false
    @State var showDetailView: Bool = false
    
    
    @Namespace private var cardAnimation
    var body: some View {
        
        ZStack{
            GeometryReader{
                geo in
                ZStack{}
                    .frame(maxWidth: .infinity, maxHeight: .infinity).background(.black)
                    .overlay(content: {
                        Rectangle().fill(.ultraThinMaterial).ignoresSafeArea().opacity(expandedCard ? 1 : 0)
                        
                            .overlay(content: {
                                if  showDetailView {
                                    DetailView(card: cardSelected, geo: geo).transition(.asymmetric(insertion: .identity, removal: .offset(y:5)))
                                }
                            })
                    })
                
                VStack{
                    HStack{
                        Image(systemName: "chevron.left" )
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("yes")
                                withAnimation(.easeOut(duration: 0.35)) {
                                    expandedCard = false
                                }
                            }
                        Spacer()
                        Text("All Cards" ).font(.title2.bold())
                    }.padding(35).opacity(showDetailView   ? 0 : 1 )
                    ScrollView(.vertical,showsIndicators: false){
                        ForEach(0..<cards.count) { index in
                            let currentIndex = CGFloat(index)
                            let offsetY = currentIndex * -170
                            let reserveIndex = CGFloat(cards.count - 1) - currentIndex
                            
                            
                            let scaleEffect = (reserveIndex / CGFloat(cards.count)) * 0.15
                            
                            ZStack{
                                
                                if cardSelected.id == cards[index].id && showDetailView  {
                                    Rectangle().foregroundColor(.clear)
                                }else {
                                    CardBase(cardModel: cards[index], geo: geo)
                                        .matchedGeometryEffect(id: cards[index].id, in: cardAnimation)
                                        .rotation3DEffect(.init(degrees: expandedCard ? (showDetailView ? 0 : -15 ) : 0 ), axis: (x: 1, y: 0, z: 0), anchor: .top)
                                        .scaleEffect(1-(expandedCard ? 0 : scaleEffect))
                                        .offset(y:offsetY)
                                        .padding(.top, expandedCard ? (reserveIndex == 0 ? 60 : 70) : 0)
                                        .offset(y: showDetailView ? geo.size.height + 500 : 0 )
                                        .onTapGesture {
                                            
                                            if expandedCard {
                                                cardSelected = cards[index]
                                                
                                                withAnimation(.easeOut(duration: 0.35)) {
                                                    showDetailView = true
                                                }
                                                DispatchQueue.main.asyncAfter(deadline:.now() + 0.15) {
                                                    withAnimation(.easeOut(duration: 0.35)) {
                                                        showDetailContent = true
                                                    }
                                                }
                                                
                                            }else {
                                                withAnimation(.easeOut(duration: 0.35)) {
                                                    expandedCard.toggle()
                                                }
                                            }
                                            
                                        }
                                    
                                }
                            }
                            
                            
                            
                        }
                        
                        
                    }.scrollDisabled(!expandedCard).opacity(showDetailView   ? 0 : 1 )
                    
                        .frame(width: geo.size.width)
                        .frame(minHeight: geo.size.height)
                }
                
                
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(.black)
        
    }
    
    
    @ViewBuilder
    func DetailView(card:CardModel, geo:GeometryProxy) -> some View {
        
        VStack(spacing: 0){
            HStack{
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showDetailContent = false
                    }
                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.35)) {
                            showDetailView = false
                        }
                    }
                    
                } label: {
                    Image(systemName: "chevron.left" )
                        .foregroundColor(.white)
                        .font(.title3)
                }
                
                Spacer()
                Text("Transaction").font(.title2.bold()) .foregroundColor(.white)
                
                
                
            }.foregroundColor(.black).padding(35)
                .opacity(showDetailContent ? 1 : 0 )
            VStack{
                
                CardBase(cardModel: card, geo: geo)
                    .rotation3DEffect(.init(degrees: showDetailContent ? 0 : -15  ), axis: (x: 1, y: 0, z: 0), anchor: .top)
                    .frame(height: 220)
                    .padding([.horizontal, .top], 15)
                
                    .matchedGeometryEffect(id: card.id, in: cardAnimation)
                
                VStack{
                    Text("Last Transactions").font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading).padding([.horizontal, .top], 30)
                    List(card.transactions) { transaction in
                        HStack{
                            
                            VStack{
                                HStack{
                                    Text("\(transaction.storeName)").font(.system(size: 18))
                                        .foregroundColor(Color.white)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text("Q \(transaction.amount,specifier: "%.2f")")
                                        .foregroundColor(Color.white)
                                    
                                    
                                }
                                VStack(alignment: .leading){
                                    Text("\(transaction.ubicationName)").font(.system(size: 14))
                                        .foregroundColor(Color.gray)
                                        .fontWeight(.regular)
                                    Text("\(transaction.date)").font(.system(size: 14))
                                        .foregroundColor(Color.gray)
                                        .fontWeight(.regular)
                                }.frame(maxWidth: .infinity, alignment:.leading)
                                
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 7)
                                .foregroundColor(.white)
                                .padding()
                        }.listRowBackground(Color("black-card-color"))
                            .listRowSeparatorTint(Color.white)
                            .background(  NavigationLink(value: Router.transactionDetail(transaction)) {
                                EmptyView()
                            }.opacity(0))
                        
                        
                        
                    } .scrollContentBackground(.hidden)
                    
                    
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background{
            Rectangle().fill(Color.black).ignoresSafeArea() .opacity(showDetailContent ? 1 : 0 )
        }
        
        
        
        
    }
    
}

/**
 
 
 
 */

var cards: Array<CardModel> = [.init(cardBrand: CardBrand.visa, cardType: CardType.normal, cardNumber: "1024  8946  1066  3046",transactions: [   Transaction(storeName: "Best Buy", ubicationName: "San Francisco", date: "2023/07/07", amount: 700.0, status:  StatusTransaction.approved, lat: 37.7749, long: -122.4194),Transaction(storeName: "The Home Depot", ubicationName: "Atlanta", date: "2023/08/08", amount: 800.0, status:  StatusTransaction.approved, lat: 33.7490, long: -84.3880),Transaction(storeName: "Amazon", ubicationName: "Seattle", date: "2023/09/09", amount: 900.0, status:  StatusTransaction.approved, lat: 47.6062, long: -122.3321)]), .init(cardBrand: CardBrand.mastercard, cardType: CardType.platinum, cardNumber: "2036  9632  3576  7768",transactions: [   Transaction(storeName: "Target", ubicationName: "Chicago", date: "2023/04/04", amount: 400.0, status: .approved, lat: 41.8781, long: -87.6298),Transaction(storeName: "Walmart", ubicationName: "Houston", date: "2023/05/05", amount: 500.0, status: .refunded, lat: 29.7604, long: -95.3698),Transaction(storeName: "McDonald's", ubicationName: "Miami", date: "2023/06/06", amount: 600.0, status: .refunded, lat: 25.7617, long: -80.1918),]), .init(cardBrand: CardBrand.visa, cardType: CardType.black, cardNumber: "4818  4188  5473  5790",transactions: [    Transaction(storeName: "Apple Store", ubicationName: "New York City", date: "2023/01/01", amount: 100.0, status: .approved, lat: 40.7128, long: -74.0060),Transaction(storeName: "Nike Store", ubicationName: "Los Angeles", date: "202/0202", amount: 200.0, status: .refunded, lat: 34.0522, long: -118.2437),Transaction(storeName: "Starbucks", ubicationName: "Seattle", date: "2023/03/03", amount: 300.0, status: .approved, lat: 47.6062, long: -122.3321),])]


struct CardBase:View{
    var cardModel:CardModel
    var geo: GeometryProxy
    var body: some View{
        
        
        VStack(alignment:.center){
            VStack{
                
                VStack{
                    Text(cardModel.cardType.cardName).fontWeight(.bold).font(.system(size:30)).foregroundColor(.white)
                        .frame(maxWidth:  .infinity, alignment: .leading).padding()
                    
                    Text(cardModel.cardNumber).fontWeight(.bold).font(.system(size:20)).foregroundColor(.white)
                        .frame(maxWidth:  .infinity, alignment: .center).padding()
                    
                }
                Spacer()
                HStack(alignment:.bottom){
                    Spacer(minLength: 0)
                    Image(cardModel.cardBrand.creditCardImageName).resizable().aspectRatio(contentMode: .fit)
                        .frame(maxWidth: cardModel.cardBrand.imageSize, maxHeight:cardModel.cardBrand.imageSize, alignment:.bottomTrailing).padding()
                    
                }.frame(maxHeight: 70)
            }.frame(minWidth: 350, maxWidth: 350,minHeight:   220)
                .background(Color(cardModel.cardType.backgrounColor))
                .background(RadialGradient(gradient:Gradient(colors: [Color(cardModel.cardType.backgrounColor), Color(cardModel.cardType.backgrounColor).opacity(0.9)]),  center: .bottomTrailing, startRadius: 400, endRadius: 200))
            
                .cornerRadius(10.0)
            
        }
        
        
    }
}

struct TransationDetail: View{
    var trasaction: Transaction
    @State private var region:MKCoordinateRegion
    
    init(trasaction: Transaction) {
        self.trasaction = trasaction
        _region = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: trasaction.lat, longitude: trasaction.long), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)))
    }
    
    var body: some View{
        
        ZStack{
            VStack{
                
                
                List{
                    TransactionAmountAndStoreName(amount: trasaction.amount, storeName: trasaction.storeName, date: trasaction.date, ubicationName:  trasaction.ubicationName)      .listRowBackground(Color.black)
                        .listRowSeparatorTint(Color.white)
                        .listRowInsets(EdgeInsets())
                    
                    
                    
                    Section{
                        VStack(alignment:.leading){
                            Text("Status: \(trasaction.status.statusToString)").font(.title3.bold()).foregroundColor(.white)
                            Text("Platinum").foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment:.leading)
                        .listRowBackground(Color("black-card-color"))
                        .listRowSeparatorTint(Color.white)
                        VStack{
                            HStack{
                                Text("Total").font(.title3.bold()).foregroundColor(.white)
                                Spacer()
                                Text("Q \(trasaction.amount , specifier: "%.2f")").font(.title3.bold()).foregroundColor(.white)
                            }
                        }
                    }.listRowBackground(Color("black-card-color"))
                        .listRowSeparatorTint(Color.white)
                    Section{
                        VStack(alignment:.leading){
                            Map(coordinateRegion: $region)
                                .frame(width: 400, height: 160).disabled(true)
                        }
                        .listRowInsets(EdgeInsets())
                        .frame(maxWidth: .infinity, alignment:.leading)
                        .listRowBackground(Color("black-card-color"))
                        .listRowSeparatorTint(Color.clear)
                        VStack{
                            HStack{
                                Text("\(trasaction.storeName) \(trasaction.ubicationName)").font(.title3.bold()).foregroundColor(.white)
                                
                            }
                        }
                    }.listRowBackground(Color("black-card-color"))
                        .listRowSeparatorTint(Color.white)
                    
                    Section(content:{
                        
                        VStack{
                            HStack{
                                Text("Contact with your bank").font(.title3.bold()).foregroundColor(.blue)
                                
                            }
                        }
                    }, footer: {
                        Text("For help with a carge you dont recognize or to dispute a charge, contact with your bank").foregroundColor(.gray).fontWeight(.medium).frame(maxWidth: .infinity, alignment:.leading)
                            .font(.system(size: 12)).listRowBackground(Color.black)
                            .listRowSeparatorTint(Color.white)
                    }).listRowBackground(Color("black-card-color"))
                        .listRowSeparatorTint(Color.clear)
                    
                    
                    Section(content:{
                        
                        VStack{
                            HStack{
                                Text("Report Incorrect Merchat Info").font(.title3.bold()).foregroundColor(.blue)
                                
                            }
                        }
                    }, footer: {
                        Text("Wallet uses maps to provide merchant name, category and location for your transactions. Help improve accuracyby reporting incorrect information").foregroundColor(.gray).fontWeight(.medium).frame(maxWidth: .infinity, alignment:.leading)
                            .font(.system(size: 12)).listRowBackground(Color.black)
                            .listRowSeparatorTint(Color.white)
                    }).listRowBackground(Color("black-card-color"))
                        .listRowSeparatorTint(Color.clear)
                    
                    
                    
                }.scrollContentBackground(.hidden)
                    .background(Color.black)
                
                    .frame(maxWidth: .infinity, maxHeight: 1000)
                
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
                .padding([.horizontal], 0)
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
    }
}

struct TransactionAmountAndStoreName:View{
    
    var amount:Double
    var storeName:String
    var date:String
    var ubicationName:String
    init(amount: Double, storeName: String, date: String, ubicationName:String) {
        self.amount = amount
        self.storeName = storeName
        self.date = date
        self.ubicationName = ubicationName
    }
    var body: some View{
        VStack{
            Text("Q \(amount,specifier: "%.2f")").foregroundColor(.white).font(.system(size:50)).fontWeight(.bold)
            Text("\(storeName) \(ubicationName)  \(date)").multilineTextAlignment(.center).foregroundColor(.gray).fontWeight(.medium).frame(maxWidth: .infinity, alignment:.center)
        }
    }
}


struct Transaction: Identifiable, Hashable {
    var id = UUID()
    var storeName:String
    var ubicationName:String
    var date:String
    var amount: Double
    var status: StatusTransaction
    var lat:Double
    var long:Double
    init(id: UUID = UUID(), storeName: String, ubicationName: String, date: String, amount: Double, status: StatusTransaction, lat: Double, long: Double) {
        self.id = id
        self.storeName = storeName
        self.ubicationName = ubicationName
        self.date = date
        self.amount = amount
        self.status = status
        self.lat = lat
        self.long = long
    }
}

enum StatusTransaction{
    case approved
    case denied
    case undefined
    case refunded
    
    var statusToString: String{
        switch self {case .approved:
            return "Approved"
        case .denied:
            return "Denied"
        case .refunded:
            return "Refunded"
        case .undefined:
            return  "On the way"
            
        }
    }
}

struct CardModel {
    var id = UUID()
    var cardBrand: CardBrand
    var cardType: CardType
    var cardNumber: String
    var transactions: Array<Transaction>
    init(cardBrand: CardBrand, cardType: CardType, cardNumber:String,transactions: Array<Transaction>) {
        self.cardBrand = cardBrand
        self.cardType = cardType
        self.cardNumber = cardNumber
        self.transactions = transactions
    }
    
}

enum CardType{
    case normal
    case gold
    case platinum
    case black
    
    var cardName: String {
        switch self {
            
        case .normal:
            return "Signature"
        case .gold:
            return "Gold"
        case .platinum:
            return "Platinum"
        case .black:
            return "Black"
        }
    }
    
    var backgrounColor: String {
        switch self {
            
        case .normal:
            return "normal-card-color"
        case .gold:
            return "gold-card-color"
        case .platinum:
            return "platinum-card-color"
        case .black:
            return "black-card-color"
        }
    }
}


enum CardBrand{
    case visa
    case mastercard
    case other
    
    var creditCardImageName: String {
        switch self {
        case .visa:
            return "visa-card"
        case .mastercard:
            return "master-card"
        case .other:
            return "visa-card"
        }
    }
    
    var imageSize: Double {
        switch self {
        case .visa:
            return 80.0
        case .mastercard:
            return 70.0
        case .other:
            return  0
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TransationDetail(trasaction: Transaction(storeName: "Apple Store", ubicationName: "New York City", date: "2023/01/01", amount: 100.0, status: .approved, lat: 40.7128, long: -74.0060))
        
        NavigationStack{
            ContentView(cardSelected: CardModel(cardBrand:        CardBrand.visa, cardType: CardType.normal, cardNumber: "2342  23423  2346  0349",transactions: [])).navigationDestination(for: Router.self) { route in
                switch route {
                case .transactionDetail(let transaction):
                    TransationDetail(trasaction: transaction)
                }
                
            }
        }
        
        
    }
}


