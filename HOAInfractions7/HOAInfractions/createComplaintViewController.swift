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
import CoreLocation
import UIKit
import DropDown
import MapKit

class createComplaintViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // this is what helps us get the connection to the core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet var txtIssueReported: UITextView!
    @IBOutlet var mapView : MKMapView!
    var myImageStore = ImageStore()
    @IBOutlet var houseNumber: UITextField!
    @IBOutlet var btnType: UIButton!
    @IBOutlet var errIssue: UILabel!
    @IBOutlet var errType: UILabel!
    
    // this is later used as the image name to save to the database
    let curUUID = UUID().uuidString
    @IBOutlet var imageView: UIImageView!

    var imageUploaded = false
    let dropDown = DropDown()
    let manager = CLLocationManager()
    var userLocation : CLLocation?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtIssueReported.layer.borderWidth = 1.0
        errIssue.textColor = UIColor.red
        errType.textColor = UIColor.red

        errIssue.isHidden = true
        errType.isHidden = true
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        errIssue.textColor = UIColor.red
        errType.textColor = UIColor.red
        
        errIssue.isHidden = true
        errType.isHidden = true
        
    }
  
   //User is trying to select an item for the infraction type
    @IBAction func tapChooseInfractionType(_ sender: UIButton) {
        do{
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let infractions = try context.fetch(InfractionLists.fetchRequest()) as! [InfractionLists]
            var infractionsString = [String]()
            for infraction in infractions{
                infractionsString.append(infraction.infractionType ?? "")
            }
            dropDown.dataSource = infractionsString
        }
        catch{
            print("Error")
        }
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height) //6
        dropDown.show() //7
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in //8
            guard let _ = self else { return }
        
        sender.setTitle(item, for: .normal) //9
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            manager.stopUpdatingLocation()
            userLocation = location
            render(location)
        }
        
    }
    
    func render (_ location: CLLocation){
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate,span:span)
        mapView.setRegion(region, animated: true)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
    }
    //This is what takes the form and saves it  creates a new Infraction and uses the context to save it
    @IBAction func btnSubmitPressed(_ sender: UIButton) {
        if(!errors()){
            //the user has entered the required fields so now load everything to the database
            let newInfraction = Infraction(context: self.context)
            newInfraction.firstName = currentlyLoggedSingleton.shared.loggedInUser.firstName
            newInfraction.lastName = currentlyLoggedSingleton.shared.loggedInUser.lastName
            newInfraction.userName = currentlyLoggedSingleton.shared.loggedInUser.userName
            newInfraction.infractionType = btnType.titleLabel?.text
            newInfraction.complainDescription = txtIssueReported.text
            newInfraction.status = "New"
            newInfraction.adminResponse = ""
            newInfraction.houseNumber = houseNumber.text!
            newInfraction.dateOpen = Date()
            newInfraction.latitude = userLocation!.coordinate.latitude
            newInfraction.longitude = userLocation!.coordinate.longitude
            txtIssueReported.text = ""
            if self.imageUploaded{
                newInfraction.photo = self.curUUID
            }
            
            goToComplaints()
            do{
                try self.context.save()
            }catch{
                print("Something happened while saving complaint")
            }
        }
    }
    
    @IBAction func btnClearPressed(_ sender: UIButton) {
        clearInputs()
    }
    
    func goToComplaints(){
        clearInputs()
        //This sends it back to the list section
        tabBarController?.selectedIndex=0
    }
    //this is to clear all the fields
    func clearInputs(){
        houseNumber.text = ""
        txtIssueReported.text = ""
        btnType.setTitle("Infraction Type", for: .normal)
        imageView.image = UIImage()
    }
    
    func errors() -> Bool{
        var errors = false

        if(txtIssueReported.text == ""){
            errors = true
            errIssue.isHidden = false
        }else{
            errIssue.isHidden = true
        }

        if(btnType.titleLabel?.text == "Infraction Type"){
            errors = true
            errType.isHidden = false
        }else{
            errType.isHidden = true
        }
        return errors
    }
    
    //-----this section handles the pictures
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any] )
    {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage

        let key = self.curUUID
        self.myImageStore.setImage(image, forKey: key)

        imageView.image = image
        dismiss(animated: true, completion: nil)
        self.imageUploaded = true
    }

    func imagePicker(for sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        return imagePicker
    }
    //when the button is pressed to choose a foto it pulls up the options to be from camara or device
    @IBAction func choosePhotoSource(_ Sender: Any){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.modalPresentationStyle = .popover
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                let imagePicker = self.imagePicker(for: .camera)
                self.present(imagePicker, animated: true, completion: nil)
                }
            alertController.addAction(cameraAction)
        }

        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) {_ in
            let imagePicker = self.imagePicker(for: .photoLibrary)
            imagePicker.modalPresentationStyle = .popover
            self.present(imagePicker, animated: true, completion: nil)
            }
        alertController.addAction(photoLibraryAction)
                
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


