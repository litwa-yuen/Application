//
//  ContentView.swift
//  Look TFT
//
//  Created by Lit Wa Yuen on 2/23/20.
//  Copyright © 2020 Lit Wa Yuen. All rights reserved.
//

import SwiftUI
import Combine
import GoogleMobileAds

struct ContentView : View {
    @ObservedObject var riotApi: RiotApi

    var interstitial:Interstitial = Interstitial()
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: Summoner.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Summoner.name, ascending: false)]
    ) var mySummoner: FetchedResults<Summoner>
        
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                HStack(alignment: .center) {
                    TextField("Enter Summoner Name", text: self.$riotApi.summonerName) {
                        UIApplication.shared.endEditing()
                        self.riotApi.fetchSummoner(name: self.riotApi.summonerName)
                    }
                    .multilineTextAlignment(.center)
                    .disableAutocorrection(true)
                    .padding(.init(top: 10, leading: 30, bottom: 0, trailing: 0))
                    NavigationLink(destination: RecentSearchView(riotApi: self.riotApi)) {
                        Image("clock")
                            .resizable()
                            .frame(width: 15, height: 15)

                    }.onTapGesture {
                        UIApplication.shared.endEditing()
                    }.padding(.init(top: 10, leading: 0, bottom: 0, trailing: 30))

                }
         
                if riotApi.league != nil {
                    HStack(alignment: .center) {
                        Button(action: {
                            print("enter data core")
                        }) {
                            HStack {
                                Image("full heart")
                            }
                        }.hidden()
                        Spacer()
                        Image(riotApi.league.tier)
                        .resizable()
                        .frame(width: 50, height: 50)

                       
                        Text("\(riotApi.league.getLeague())").bold()
                        Spacer()
                        Button(action: {
                            self.interstitial.showAd()
                            self.saveSummoner()
                        }) {
                            HStack {
                                Image(isSummoner() ?"full star" :"star-outline")
                            }
                        }
                        
                    }.padding(.init(top: 0, leading: 15, bottom: 0, trailing: 15))
                }
                ZStack{
                    if riotApi.isError {
                        Text("\(riotApi.message)").bold()
                        .foregroundColor(Color.red)
                    }
                }
                List{
                    ForEach(riotApi.matchesDetail, id: \.metadata.match_id) { match  in
                        MatchRowView(match: match)
                    }
                }
                .onAppear { UITableView.appearance().separatorStyle = .none }
                
                //BannerViewController().frame(width: 320, height: 50, alignment: .center)

        
            }.navigationBarTitle(Text("Summoner: \(self.riotApi.searchRegion)"), displayMode: .inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(
                leading: NavigationLink(destination: SettingsView()) {
                    Image("Settings")
                }.onTapGesture {
                    UIApplication.shared.endEditing()
                },
                trailing: Button(action: {
                    UIApplication.shared.endEditing()
                    self.riotApi.fetchSummoner(name: self.riotApi.summonerName)
                    
                }) {
                    HStack {
                        Image("Search")
                    }
                }
            ).onAppear {
                if self.riotApi.reload {
                    self.riotApi.reloadSummoner()
                } else {
                    self.riotApi.updateRegion()
                }
            }
        }
        
    }
    func saveSummoner() {
        if isSummoner() {
            managedObjectContext.delete(mySummoner.first!)
        }
        else {
            if mySummoner.first != nil {
                managedObjectContext.delete(mySummoner.first!)
            }
            let me: Summoner = Summoner(context: managedObjectContext)
            me.accountId = riotApi.summoner.accountId
            me.id = riotApi.summoner.id
            me.name = riotApi.summoner.name
            me.puuid = riotApi.summoner.puuid
            me.region = region
            do {
                try managedObjectContext.save()
            } catch {
                print("error")
            }
        }
    
    }
    
    func isSummoner() -> Bool{
        let temp = mySummoner.first { (sum) -> Bool in
            sum.puuid == riotApi.summoner.puuid && sum.region == region
        }
        return temp != nil ? true : false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(riotApi: RiotApi())
    }
}
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
