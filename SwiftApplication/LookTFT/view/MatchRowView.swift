//
//  MatchRowVieew.swift
//  Look TFT
//
//  Created by Lit Wa Yuen on 2/26/20.
//  Copyright © 2020 Lit Wa Yuen. All rights reserved.
//

import SwiftUI

struct MatchRowView: View {
    let match: MatchDto

    var body: some View {
        HStack (alignment: .center, spacing: 5) {
            ZStack {
                match.getMatchColor()
            }.frame(width: 10, height: 80, alignment: .leading)
            VStack(alignment: .leading) {
                HStack {
                    Text(match.getPlacement())
                    Spacer()
                    Text(timeAgoSince(match.info.game_datetime))
                }

                    HStack (alignment: .center, spacing: 2){
                        ForEach(match.summmonerInfo!.traits, id: \.name) { trait  in
                      
                            ZStack {

                                Image(traitMap["\(trait.tier_current)-\(trait.tier_total)"]!)
                                    .resizable()
                                    .frame(width: 27, height: 27)
                                
                                ZStack {
                                    Image("\(trait.name)")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                            }
                        }
                    }
                HStack {
                    ForEach(match.summmonerInfo!.units, id: \.character_id) { unit  in
                        VStack(alignment: .center, spacing: 1) {
                            HStack(alignment: .center,spacing: 0.5) {
                                if unit.tier >= 1 {
                                   Image("star")
                                }
                                if unit.tier >= 2 {
                                    Image("star")
                                }
                                if unit.tier == 3 {
                                    Image("star")
                                }
                            }
                            Image(unit.character_id)
                                .resizable()
                                .frame(width: 27, height: 27)
                            HStack(alignment: .center,spacing: 0.5) {
                                if unit.items.count == 0 {
                                    Image("empty").hidden()
                                }
                                ForEach(unit.items, id: \.self) { item in
                                    HStack(alignment: .center,spacing: 0.5) {
                                        Image("\(item)")
                                        .resizable()
                                        .frame(width: 9, height: 9)
                                    
                                    }

                                }
                            }
                        }
                      
                    }
                }

            }
        }
    }
}
