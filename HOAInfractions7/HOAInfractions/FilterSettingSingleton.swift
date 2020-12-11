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
// This class holds the data for filtering options that they set when they go to the filters section.
// It initializes to have all the options set to On
final class FilterSettingSingleton{
    
    static let shared = FilterSettingSingleton()
    private init (){
        do{
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let infractions = try context.fetch(InfractionLists.fetchRequest()) as! [InfractionLists]
            for infraction in infractions{
                self.infractionsListSelected.append(infraction.infractionType ?? "")
            }
        }
        catch{
            print("Error")
        }
    }
    
    var statusListSelected : [String] = ["New","Closed","Pending"]
    var infractionsListSelected :[String] = []
    
    func updateStatusListSelected (newList:[String])
    {
        self.statusListSelected = newList
    }

    func updateinfractionsListSelected (newList:[String])
    {
        self.infractionsListSelected = newList
    }

}
