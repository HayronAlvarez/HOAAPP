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


import CoreData
// the intention for this class is to always have on hand the person that is logged in so we can pull the data and use it wehen ever its necessary.
final class currentlyLoggedSingleton{
    static let shared = currentlyLoggedSingleton()
    
    var loggedInUser : Users
    private init (){
        loggedInUser = Users()
    }
}
