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

//Manages the Complaints List

class listComplaintsViewController: UITableViewController, UISearchBarDelegate {
    
    // reference to manage object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //data for the table
    var infractions:[Infraction]?
    
    var currenltyLog = currentlyLoggedSingleton.shared.loggedInUser
    var statusListSelected : [String] = []
    var infractionsListSelected : [String] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        searchBar.delegate = self;
        self.statusListSelected = FilterSettingSingleton.shared.statusListSelected
        self.infractionsListSelected = FilterSettingSingleton.shared.infractionsListSelected
        fetchInfractions()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.statusListSelected = FilterSettingSingleton.shared.statusListSelected
        self.infractionsListSelected = FilterSettingSingleton.shared.infractionsListSelected
        fetchInfractions()
    }
    
    // Search Bar Config
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        fetchInfractions(searchW: searchText)
    }
    
    //Pre-builts the actual search string to be used based on the filters they have selected
    func buildFilters() -> String{
        var curFilterString = ""

        if self.statusListSelected.count > 0 {
            curFilterString += " ( "
            for i in 0...(self.statusListSelected.count-1){
                if i > 0{
                   curFilterString += " or "
                }
                curFilterString += "status = '\(self.statusListSelected[i])'"
            }
            curFilterString += " ) "
        }

        if self.infractionsListSelected.count > 0 {
            if self.statusListSelected.count > 0 {
               curFilterString += " and "
            }
            curFilterString += " ( "
            for i in 0...(self.infractionsListSelected.count-1){
                if i > 0{
                 curFilterString += " or "
                }
                curFilterString += "infractionType = '\(self.infractionsListSelected[i])'"
            }
            curFilterString += " ) "
        }

        return curFilterString
    }
    
    //this gets the data but applying the search on the search bar
    func fetchInfractions(searchW:String){
        let request = Infraction.fetchRequest() as NSFetchRequest<Infraction>
        do {
            if searchW != "" {
                var predicateL : [NSPredicate] = []
                // this searches inside complaint descriptions, infraction types, lastname and housenumber
                let pred = NSPredicate(format: "complainDescription contains[cd] %@ or infractionType contains[cd] %@ or lastName contains[cd] %@ or houseNumber contains[cd] %@", searchW,searchW,searchW,searchW)
                predicateL.append(pred)
                
                // if its not an adimin limits the result to be only the ones that the person logged in as posted.
                if !currenltyLog.isAdmin  {
                    let isAdminFilter = "userName == '\(currenltyLog.userName!)'"
                    
                    predicateL.append(NSPredicate(format: isAdminFilter))
                }
                
                let presetfilters = self.buildFilters()
                if presetfilters != "" {
                    predicateL.append(NSPredicate(format: presetfilters))
                }
                
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateL)
                self.infractions = try context.fetch(request)
                 //this is so the main thread does the reload
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            else{
                self.fetchInfractions()
            }
           
       } catch {
           print("Error")
       }
    
    }

    // this is a regular fetch of the data before any type of search is completed.
    func fetchInfractions(){
        let request = Infraction.fetchRequest() as NSFetchRequest<Infraction>
        do {
            
            var presetfilters = self.buildFilters()
            
           if !currenltyLog.isAdmin  {
               presetfilters += " and (userName = '\(currenltyLog.userName!)') "
           }
            
            if presetfilters != "" {
                let pred2 = NSPredicate(format: presetfilters)
                request.predicate = pred2
            }

            self.infractions = try context.fetch(request)
            
            //this is so the main thread does the reload
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } catch {
            print("Error")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infractions?.count ?? 0
    }
    
    // to get the date
    let dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
      let cell = tableView.dequeueReusableCell(withIdentifier: "infractionCell", for: indexPath) as! InfractionCell
        
       let infraction = self.infractions![indexPath.row]
        cell.infractionType?.text = infraction.infractionType
        cell.curStatus?.text = infraction.status
        if let curDate = infraction.dateOpen {
            cell.datePosted?.text = dateFormatter.string(from: curDate)
        }

        
      return cell
    }
    
    //delete
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        // If the table view is asking to commit a delete command...
        if editingStyle == .delete {
            let infractionToRemove = infractions![indexPath.row]
            
            self.context.delete(infractionToRemove)
            do{
               try self.context.save()
                
            } catch {
                print("Could not save user")
            }

            self.fetchInfractions()
            // Also remove that row from the table view with an animation
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    
    //sends the info to view
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // If the triggered segue is the "showInfraction" segue
    switch segue.identifier {
        case "showInfraction":
            // Figure out which row was just tapped
            if let row = tableView.indexPathForSelectedRow?.row {

                // Get the item associated with this row and pass it along
                let item = self.infractions![row]
                let UpdateViewController = segue.destination as! UpdateViewController
                UpdateViewController.item = item
        
            }
    case "filter":print("")
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    @IBAction func toggleEditingMode(_ sender: UIButton) {
        // If you are currently in editing mode...
            if isEditing {
                // Change text of button to inform user of state
                sender.setTitle("Edit", for: .normal)

                // Turn off editing mode
                setEditing(false, animated: true)
            } else {
                // Change text of button to inform user of state
                sender.setTitle("Done", for: .normal)

                // Enter editing mode
                setEditing(true, animated: true)
        }

    }
    
    
}
