//
//  RiotApi.swift
//  Look TFT
//
//  Created by Lit Wa Yuen on 2/23/20.
//  Copyright © 2020 Lit Wa Yuen. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class RiotApi: ObservableObject {
    @Published var summoner: SummonerDto!
    @Published var matchesDetail: [MatchDto] = []
    @Published var league: LeagueEntryDto!
    @Published var message: String = ""
    @Published var isError: Bool = false
    @Published var searchRegion = region.uppercased()
    @Published var reload = false
    @Published var summonerName = ""
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var leagues: [LeagueEntryDto] = []
    var matches: [String] = []
    
    func updateRegion() {
        if searchRegion != region.uppercased() {
            searchReset()
            searchRegion = region.uppercased()
        }
    }
    
    func searchReset() {
        summoner = nil
        resetData()
    }

    func resetData() {
        matches.removeAll()
        matchesDetail.removeAll()
        leagues.removeAll()
        league = nil
        message.removeAll()
        isError = false
        reload = false
    }
    func reloadSummoner() {
        resetData()
        region = summoner.region!
        regionIndex = regionIndexMap[region]!
        searchRegion = region.uppercased()
        fetchMatches(puuid: summoner.puuid)
        fetchSummonerLeague(id: summoner.id)
    }
    
    func showReponseMessage(_ mess: String)  {
        self.isError.toggle()
        self.message = mess
    }
    
    func fetchMatches(puuid: String)  {
        let route = regionMap[region]
        let apiUrl = "https://\(route!).api.riotgames.com/tft/match/v1/matches/by-puuid/\(puuid)/ids?count=20&api_key=\(API_KEY)"
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            DispatchQueue.main.async {
                self.matches = try! JSONDecoder().decode([String].self, from: data!)
                self.matches.forEach { (match) in
                    self.fetchMatch(matchId: match)
                }
                if self.matches.count == 0 {
                    self.showReponseMessage("No Match found")
                }
            }
        }.resume()
    }
    
    func fetchSummonerLeague(id: String)  {
        let route = platformMap[region]
        let apiUrl = "https://\(route!).api.riotgames.com/tft/league/v1/entries/by-summoner/\(id)?api_key=\(API_KEY)"
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            DispatchQueue.main.async {
                self.leagues = try! JSONDecoder().decode([LeagueEntryDto].self, from: data!)
                self.league = self.leagues.first { (league) -> Bool in
                    league.queueType == "RANKED_TFT"
                }
                if self.league == nil {
                    self.league = LeagueEntryDto(queueType: "RANKED_TFT", rank: "I", tier: "provisional", leaguePoints: 0)
                }
            }
        }.resume()
    }
    
    func fetchMatch(matchId: String)  {
        let route = regionMap[region]
        let apiUrl = "https://\(route!).api.riotgames.com/tft/match/v1/matches/\(matchId)?api_key=\(API_KEY)"
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            DispatchQueue.main.async {
                guard let httpResponse = resp as? HTTPURLResponse else {return }

                switch(httpResponse.statusCode) {
                case 200:
                    do {
                         var matchD = try JSONDecoder().decode(MatchDto.self, from: data!)
                        matchD.getSummonerInfo(self.summoner.puuid)
                        
                        self.matchesDetail.append(matchD)
                        self.matchesDetail.sort(by: { (m1:MatchDto, m2:MatchDto) -> Bool in
                            return m1.info.game_datetime > m2.info.game_datetime
                        })

                    } catch {
                        print("error")
                    }

                default:
                    print(httpResponse.statusCode)
                }
            }
        }.resume()
    }
    func fetchSummoner(name: String)  {
        let urlSummonerName: String = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        if urlSummonerName.count == 0 {
            return
        }
        
        if summoner != nil && name == summoner.name && summoner.region == region {
            return
        }
        self.searchReset()
        if !CheckReachability.isConnectedToNetwork() {
            showReponseMessage("Network Unavailable.")
            return
        }
        
        let route = platformMap[region]
        let apiUrl = "https://\(route!).api.riotgames.com/tft/summoner/v1/summoners/by-name/\(urlSummonerName)?api_key=\(API_KEY)"
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            DispatchQueue.main.async {
                guard let httpResponse = resp as? HTTPURLResponse else {return }

                switch(httpResponse.statusCode) {
                case 200:
                        self.summoner = try! JSONDecoder().decode(SummonerDto.self, from: data!)
                        self.summoner.region = region
                        self.summonerName = self.summoner.name
                        self.addRecentSearchPlayer(self.summoner.id)
                        self.fetchSummonerLeague(id: self.summoner.id)
                        self.fetchMatches(puuid: self.summoner.puuid)
                        

                case 404:
                    self.showReponseMessage("Summoner Not Found.")
                case 429:
                    self.showReponseMessage("Rate Limit Exceeded.")
                case 500, 503:
                    self.showReponseMessage("Service Unavailable.")
                default:
                    self.showReponseMessage("Wait for Update.")
                }
                
            }
        }.resume()
    }
    
    func addRecentSearchPlayer(_ id : String)  {
        do {
            let fetchRequest = Player.fetchPlayersRequest(id: self.summoner.id, region: region)
            let playersData = (try! self.context.fetch(fetchRequest))
            if playersData.count > 0 {
                guard let player = playersData.first else { return }
                player.createAt = Date()
            } else {
                let ent = NSEntityDescription.entity(forEntityName: "Player", in: self.context)
                let nPlayer = Player(entity: ent!, insertInto: self.context)
                nPlayer.name = self.summoner.name
                nPlayer.id = self.summoner.id
                nPlayer.region = region
                nPlayer.createAt = Date()
                nPlayer.accountId = self.summoner.accountId
                nPlayer.puuid = self.summoner.puuid
            }
            
            try self.context.save()

        } catch _ {}
    }
}
