import UIKit
import CoreData
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    override init() {
        super.init()
        FIRApp.configure()
        // not really needed unless you really need it FIRDatabase.database().persistenceEnabled = true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DispatchQueue.global(qos: .background).async {
            () -> Void in
            if let path = Bundle.main.path(forResource: "rune", ofType: "json")
            {
                do {
                    let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    if let runesMap: NSArray = jsonResult!["runesMap"] as? NSArray
                    {
                        for rune in runesMap {
                            
                            let runeId = (rune as? NSDictionary)?["runeId"] as? CLong ?? 0
                            let jsonRune:JsonRune = JsonRune(rune: rune as! NSDictionary)
                            map[runeId] = jsonRune
                        }
                    }
                }
                catch _ {}
            }

        }
        let context = self.managedObjectContext
        let result: NSArray = (try! context.fetch(fetchMeRequest())) as! [Me] as NSArray
        if result.count > 0 {
            // mainStoryboard
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            // rootViewController
            let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "CurrentGameViewController") as? CurrentGameViewController
            let id = (result[0] as! Me).value(forKey: "id") as! NSNumber
            let myRegion = (result[0] as! Me).value(forKey: "region") as! String
            region = myRegion
            let obj:NSDictionary = ["name":(result[0] as! Me).name!, "id":id]

            rootViewController?.summoner = Summoner(data:obj)
            rootViewController?.isMainPage = true
            // navigationController
            let navigationController = UINavigationController(rootViewController: rootViewController!)
        
            // self.window
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            self.window!.rootViewController = navigationController
            
            self.window!.makeKeyAndVisible()

   
        }

       

        return true
    }

    func fetchMeRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Me")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        window?.rootViewController?.dismiss(animated: false, completion: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handledShhortcutItem = self.handleShortcutItem(shortcutItem: shortcutItem)
        completionHandler(handledShhortcutItem)

    }
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "lit.wa.yuen.SelfLOL" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "SelfLOL", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    enum ShortcutIdentifier: String
    {
        case Bans
        case Favorite
        
        init?(fullType: String)
        {
            guard let last = fullType.components(separatedBy: ".").last else {return nil}
            self.init(rawValue: last)
        }
        
        var type: String
        {
            return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
        }
        
    }
    
    func handleShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool
    {
        var handled = false
        
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
        guard let shortcutType = shortcutItem.type as String? else { return false }
        
        switch (shortcutType)
        {
        case ShortcutIdentifier.Bans.type:
            FIRAnalytics.logEvent(withName: "3D_Bans", parameters: [
                "region": region as NSObject
                ])

            handled = true
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            // rootViewController
            let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "TrendingViewController") as? TrendingViewController
            rootViewController?.isMainPage = true
            // navigationController
            let navigationController = UINavigationController(rootViewController: rootViewController!)
         
            window?.rootViewController?.present(navigationController, animated: true, completion: nil)
        case ShortcutIdentifier.Favorite.type:
            FIRAnalytics.logEvent(withName: "3D_Favorite", parameters: [
                "region": region as NSObject
                ])
            handled = true
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            // rootViewController
            let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "LOLSelfViewController") as? LOLSelfViewController
            let navigationController = UINavigationController(rootViewController: rootViewController!)

            let result: NSArray = (try! self.managedObjectContext.fetch(fetchMeRequest())) as! [Me] as NSArray
            if result.count > 0 {
                let id = (result[0] as! Me).value(forKey: "id") as! NSNumber
                let myRegion = (result[0] as! Me).value(forKey: "region") as! String
                region = myRegion
                let obj:NSDictionary = ["name":(result[0] as! Me).name!, "id":id]
                rootViewController?.summoner = Summoner(data: obj)
                rootViewController?.summonerName = (result[0] as! Me).name!
            }
            else {
                rootViewController?.showAlert = true
            }
            
            window?.rootViewController?.present(navigationController, animated: true, completion: nil)
        default:
            break
        }
        
        return handled
        
    }

}

