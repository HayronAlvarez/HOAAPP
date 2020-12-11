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

class logInViewController : UIViewController, UITextFieldDelegate{
    
        
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var users:[Users]?
    
    
    
    @IBAction func login(_ sender: Any) {
        do {
            let request = Users.fetchRequest() as NSFetchRequest<Users>
            let pred = NSPredicate(format: "userName == %@ AND password == %@", userName.text!.lowercased(), passWord.text!)
            
            request.predicate = pred
            self.users = try context.fetch(request)
            
        } catch {
            print("Error")
        }
        
        
        if self.users?.count == 1
        {
            // this is where we get the data
            let foundUser = self.users?[0]
            
            //this is how to call the values to put it into the singleton class that holds this information.
//            foundUser?.isAdmin
//            foundUser?.firstName
//            foundUser?.lastName
//            foundUser?.userName
            currentlyLoggedSingleton.shared.loggedInUser = foundUser!
            //print(currentlyLoggedSingleton.shared.loggedInUser.firstName ?? "")
            
            clearScreen()
            
            //this is to go to the tabviewcontroller
            let main = UIStoryboard(name:"Main", bundle: nil)
            let second = main.instantiateViewController(identifier: "create")
            second.modalPresentationStyle = .fullScreen
            self.present(second, animated: true, completion: nil)
            
            
        }
        else{
            var messageToShow = "Invalid Username or Password"
            
            if userName.text! == "" || passWord.text! == ""
            {
                messageToShow = "Please Provide a Username and Password"
            }
            
            
            let alert = UIAlertController(title: "Log In Error", message: messageToShow, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
           self.present(alert, animated: true)
           clearScreen()
        }
        
        
    }
    
        
    @IBAction func clear(_ sender: Any) {
        clearScreen()
    }

    func clearScreen(){
        userName.text = ""
        passWord.text = ""
    }
    
    
    // this for the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
