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

// manages the filters for the list
class FiltersViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var infractionsTable: UITableView!
    @IBOutlet weak var statusTable: UITableView!
    
     var infractionsList:[InfractionLists]?
    
    // reference to manage object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // list of status options
    let statusList : [String] = ["New","Pending","Closed"]

    var statusListSelected : [String] = []
    var infractionsListSelected :[String] = []
    // gets all the data from the singleton to be used when it loads the data into the tableview
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.statusListSelected = FilterSettingSingleton.shared.statusListSelected
        self.infractionsListSelected = FilterSettingSingleton.shared.infractionsListSelected
        
        self.fetchInfractionsList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infractionsTable.delegate = self
        infractionsTable.dataSource = self
        statusTable.delegate = self
        statusTable.dataSource = self
        self.statusListSelected = FilterSettingSingleton.shared.statusListSelected
        self.infractionsListSelected = FilterSettingSingleton.shared.infractionsListSelected
     
        self.fetchInfractionsList()
    }

    // when the view goes away saves all the data to the singleton to be used on the listing side.
    override func viewWillDisappear(_ animated: Bool) {
        
        FilterSettingSingleton.shared.updateStatusListSelected(newList: self.statusListSelected)
        FilterSettingSingleton.shared.updateinfractionsListSelected(newList: self.infractionsListSelected)
        
        super.viewWillDisappear(animated)
    }
    // this gets the information used to get all the infractions list
    func fetchInfractionsList(){
       do {
           self.infractionsList = try context.fetch(InfractionLists.fetchRequest())
           //this is so the main thread does the reload
           DispatchQueue.main.async {
               self.infractionsTable.reloadData()
           }
       } catch {
           print("Error")
       }
    }
    
    
    // this manages two tables  each one is identified with the tag number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.tag == 1){
            return self.infractionsList?.count ?? 0
        } else if (tableView.tag == 2) {
            return self.statusList.count
        } else { return 0}
    }
    
    // this manages two tables.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        if (tableView.tag == 1){

            let infractionList = self.infractionsList![indexPath.row]
            cell.textLabel?.text = infractionList.infractionType
            //checks to see if its in the singleton and if it is than it turns the swith to true.
            let isSelected:Bool = infractionsListSelected.contains(infractionList.infractionType!)

            let switchView = UISwitch(frame: .zero)
            switchView.setOn(isSelected, animated: true)
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchDidChangeInfractions(_:)), for: .valueChanged)
            cell.accessoryView = switchView

       } else if (tableView.tag == 2) {

            let curStatusList = self.statusList[indexPath.row]
            cell.textLabel?.text = curStatusList
        
            // want to see if this option is selected or not
            let isSelected:Bool = statusListSelected.contains(curStatusList)

            let switchView = UISwitch(frame: .zero)
              switchView.setOn(isSelected, animated: true)
              switchView.tag = indexPath.row
              switchView.addTarget(self, action: #selector(self.switchDidChangeStatus(_:)), for: .valueChanged)
              cell.accessoryView = switchView
       }

      return cell
    }
    
    // this is for the switches.  manages only the infraction switches. removing or addign to the local aray to be saved later
    @objc func switchDidChangeInfractions(_ sender: UISwitch){
        let infractionWord = self.infractionsList![sender.tag].infractionType
        let curPostion = self.infractionsListSelected.firstIndex(of: (infractionWord)!)
        
        if curPostion ?? -1 >= 0 {
            self.infractionsListSelected.remove(at: curPostion!)
        }else {
            self.infractionsListSelected.append((infractionWord)!)
        }
        // from here we would just
    }

    // this is for the switches.  manages only the Status switches. removing or addign to the local aray to be saved later
    @objc func switchDidChangeStatus(_ sender: UISwitch){
        let statusWord =  self.statusList[sender.tag]
        let curPostion = self.statusListSelected.firstIndex(of: statusWord)
        
        if curPostion ?? -1 >= 0 {
            self.statusListSelected.remove(at: curPostion!)
        }else {
            self.statusListSelected.append(statusWord)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

