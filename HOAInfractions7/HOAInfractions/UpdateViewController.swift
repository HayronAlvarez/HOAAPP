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

import DropDown
import UIKit
import CoreData
import MessageUI

// this manages the Complaints Detail window which updates and displays the information

class UpdateViewController: UIViewController,MFMailComposeViewControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var txtIssueReported: UITextView!
    @IBOutlet var txtAdminResponse: UITextView!
    @IBOutlet var lblReportedBy: UILabel!
    @IBOutlet var lblPhoneNumber: UILabel!
    @IBOutlet var lblDateOpened: UILabel!
    @IBOutlet var lblDateClosed: UILabel!
    @IBOutlet var lblType: UILabel!
    @IBOutlet var btnStatus: UIButton!
    @IBOutlet var houseNumber: UILabel!
    
    @IBOutlet var btnContact: UIButton!
    @IBOutlet var savedMessage: UILabel!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dropDown = DropDown()
    var users:[Users]?
    var item: Infraction!
    
    var myImageStore = ImageStore()
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtIssueReported.layer.borderWidth = 1.0
        self.txtAdminResponse.layer.borderWidth = 1.0
    }
    // to format the date fields
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
        savedMessage.text = ""
        do{
            let request = Users.fetchRequest() as NSFetchRequest<Users>
            let pred = NSPredicate(format: "userName == %@", item.userName ?? "")
            request.predicate = pred
            self.users = try context.fetch(request)
        } catch {
            print("Error")
        }
        lblReportedBy.text = "\(item.firstName ?? "") \(item.lastName ?? "")"
        lblPhoneNumber.text = self.users?[0].phoneNumber
        lblDateOpened.text = dateFormatter.string(from: item.dateOpen!)
        if let closedDate = item.dateClosed
        {
            lblDateClosed.text = dateFormatter.string(from: closedDate)
        } else {
            lblDateClosed.text = ""
        }
        
        lblType.text = item.infractionType
        btnStatus.setTitle(item.status, for: .normal)
        txtIssueReported.text = item.complainDescription
        txtAdminResponse.text=item.adminResponse
        houseNumber.text = item.houseNumber
        
        let key = item.photo ?? ""
       if key != ""
       {
         imageView.image = self.myImageStore.getImage(forKey: key)
       }
        
        if(currentlyLoggedSingleton.shared.loggedInUser.isAdmin){
            btnSave.isHidden=false
            btnSave.isEnabled=true
            btnContact.isHidden=false
            btnContact.isEnabled=true
            
        }else{
            btnSave.isHidden=true
            btnSave.isEnabled=false
            btnContact.isHidden=true
            btnContact.isEnabled=false
        }

    }
    
    @IBAction func btnStatusPressed(_ sender: UIButton) {
        
          let statusList : [String] = ["New","Pending","Closed"]
          dropDown.dataSource = statusList
          dropDown.anchorView = sender
          dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height) //6
          dropDown.show() //7
          dropDown.selectionAction = { [weak self] (index: Int, item: String) in //8
            guard let _ = self else { return }
            sender.setTitle(item, for: .normal) //9
          }
        }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // If the triggered segue is the "showInfraction" segue
    switch segue.identifier {
        case "showOnMap":
                // Get the coordinates and pass it
                let showOnMap = segue.destination as! showOnMapViewController
                showOnMap.latitude = item.latitude
                showOnMap.longitude = item.longitude
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    
    @IBAction func btnSavePressed(_ sender: Any) {
        item.status = btnStatus.titleLabel?.text
        item.adminResponse = txtAdminResponse.text
        savedMessage.text = ""
        if (btnStatus.titleLabel?.text == "Closed")
        {
            item.dateClosed = Date()
        } else {
            item.dateClosed = nil
        }
        // we save the data
        do{
           try self.context.save()
            
        } catch {
            print("Could not save user")
        }
        // to make sure the person knows that the info was saved.
        savedMessage.text = "Your Information has been Saved"
        
    }
    
    //email logic
    
    
    @IBAction func contactUserPressed(_ sender: UIButton) {
        var userEmail = [String]()
        userEmail.append((self.users?[0].eMail)!)
        if MFMailComposeViewController.canSendMail(){
           let vc = MFMailComposeViewController()
           vc.delegate = self
           vc.setSubject("Complaint Update")
            vc.setToRecipients(userEmail)
           vc.setMessageBody("This is an update on your complaint", isHTML: false)
           
           present(vc,animated: true)
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    
}
