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

//With this we create a logout portion.  when this is reached then it sends it to the log in screen.
class LogOutViewController: UIViewController {
    override func viewDidLoad() {
        let main = UIStoryboard(name:"Main", bundle: nil)
           let second = main.instantiateViewController(identifier: "FirstVC")
           second.modalPresentationStyle = .fullScreen
        
           self.present(second, animated: true, completion: nil)
    }
}
