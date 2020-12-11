//
//  PROGRAMMERS: Hayron Alvarez, Ariel Pentzke
//  PANTHERID'S: 5200111, 1364786
//  CLASS: COP 4655 RH1 & U01 TR 5:00
//  INSTRUCTOR: Steve Luis Online
//  ASSIGNMENT: Deliverable #2
//  DUE: Firday 12/11/20
//
//  This work is licensed under a Creative Commons Attribution 4.0 International License.
//  Details can be found under  https://creativecommons.org/licenses/by/4.0/

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.preloadData()
        return true
    }
    
    /* This funciton takes care of preloading all the data from the plist.  It only does it when the app is initialized.  It uploads the data to the core data.
        the things it uploads are the complaint types, a list of users, and some preloaded complaints to the system.
     */
    private func preloadData(){
        let preloadedDataKey = "didPreloadedData"
        
        let userDefaults = UserDefaults.standard
        // checks in the userDefaults plist to see if it was already done if so it will ignore it.
        if userDefaults.bool(forKey: preloadedDataKey) == false {
            
            // gets the plist for users
            guard let urlPath = Bundle.main.url(forResource: "defaultUsers", withExtension: "plist") else {
                return
            }
            
            //to import out data in the background thread
            let backgroundContext = persistentContainer.newBackgroundContext()
            persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                
            
            backgroundContext.perform {
    
                if let arrayOfDictionaries = NSArray(contentsOf: urlPath){
                    do {
                        for dict in arrayOfDictionaries {
                            let newDic = dict as! NSDictionary
                            
                            let userObject = Users(context: backgroundContext)
                            userObject.firstName = newDic["firstName"] as? String
                            userObject.lastName = newDic["lastName"] as? String
                            userObject.isAdmin = newDic["isAdmin"] as! Bool
                            userObject.eMail = newDic["eMail"] as? String
                            userObject.userName = newDic["userName"] as? String
                            userObject.password = newDic["password"] as? String
                            userObject.address = newDic["address"] as? String
                            userObject.city = newDic["city"] as? String
                            userObject.state = newDic["state"] as? String
                            userObject.zip = newDic["zip"] as? String
                            userObject.phoneNumber = newDic["phoneNumber"] as? String
                        }
                        
                        try backgroundContext.save()
                        userDefaults.set(true, forKey: preloadedDataKey)
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
                
                // this is for the list of infractions
                guard let urlPathInfraction = Bundle.main.url(forResource: "infractionList", withExtension: "plist") else {
                    return
                }
                
                if let array = NSArray(contentsOf: urlPathInfraction){
                  do {
                      
                      for infraction in array {
                          let infractionObject = InfractionLists(context: backgroundContext)
                          infractionObject.infractionType = infraction as? String
                      }
                      try backgroundContext.save()
                      userDefaults.set(true, forKey: preloadedDataKey)
                      
                  } catch {
                      print(error.localizedDescription)
                  }
               }

              // this is for the list of complaints
                guard let urlPathComplaints = Bundle.main.url(forResource: "defaultComplaints", withExtension: "plist") else {
                    return
                }
                
                if let arrayOfDictionaries = NSArray(contentsOf: urlPathComplaints){
                    
                    do {
                         var user:Users?
                         let request = Users.fetchRequest() as NSFetchRequest<Users>
                          do {
                             let pred = NSPredicate(format: "userName == %@", "reg1")
                             request.predicate = pred
                             user = try backgroundContext.fetch(request).first
                          } catch {
                             print("Error")
                          }
                        
                        
                        for dict in arrayOfDictionaries {
                            let newDic = dict as! NSDictionary
                            
                            let complaintObject = Infraction(context: backgroundContext)
                            complaintObject.complainDescription = newDic["complainDescription"] as? String
                            complaintObject.infractionType = newDic["infractionType"] as? String
                            complaintObject.status = newDic["status"] as? String
                            complaintObject.latitude = newDic["latitude"] as? Double ?? 0
                            complaintObject.longitude = newDic["longitude"] as? Double ?? 0
                            complaintObject.dateOpen = newDic["dateOpen"] as? Date
                            complaintObject.firstName = user?.firstName
                            complaintObject.lastName = user?.lastName
                            complaintObject.userName = user?.userName
                            complaintObject.houseNumber = newDic["houseNumber"] as? String
                            
                        }
                        
                        try backgroundContext.save()
                        userDefaults.set(true, forKey: preloadedDataKey)
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
                
            
            }
            
            
        }
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "HOAInfractions")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
