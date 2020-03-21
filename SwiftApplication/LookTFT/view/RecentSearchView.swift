//
//  RecentSearchView.swift
//  Look TFT
//
//  Created by Lit Wa Yuen on 3/11/20.
//  Copyright © 2020 Lit Wa Yuen. All rights reserved.
//

import SwiftUI

struct RecentSearchView: View {
    @ObservedObject var riotApi: RiotApi
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @FetchRequest(
        entity: Player.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.createAt, ascending: false)]
    ) var players: FetchedResults<Player>
    var body: some View {
        VStack {
            List {
                ForEach(players, id: \.id) { player in
                    HStack {
                        Button(action: {
                            self.loadSummoner(player: player)
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                            Text("\(player.name!)")
                            Spacer()
                            Text("\(player.region!.uppercased())")
                            }
                        }
                    }
                    
                }.onDelete(perform: removePlayers)
            }
        }.navigationBarTitle("Recent Searches")
    }
    
    func loadSummoner(player: Player) {
        riotApi.summonerName = player.name!
        riotApi.reload = true
        riotApi.summoner = SummonerDto(name: player.name!, puuid: player.puuid!, id: player.id!, accountId: player.accountId!, region: player.region!)
    }
    
    func removePlayers(at offsets: IndexSet) {
        for index in offsets {
            let player = players[index]
            managedObjectContext.delete(player)
        }
        do {
            try managedObjectContext.save()
        } catch {
            // handle the Core Data error
        }
    }
}

struct RecentSearchView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSearchView(riotApi: RiotApi())
    }
}
