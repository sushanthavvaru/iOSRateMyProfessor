//
//  TableViewController.swift
//  pro5
//
//  Created by Sushanth on 11/10/16.
//
//

import UIKit

class TableViewController: UITableViewController {
    
    var completeName: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: "http://bismarck.sdsu.edu/rateme/list") {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: downloadPage)
            task.resume()
        }
        else {
            print("Error")
        }
    }

    func downloadPage(data:Data?, response:URLResponse?, error:Error?) -> Void {
        guard error == nil else {
            print("error: \(error!.localizedDescription)")
            return
        }
        var element = 0;
        var fullname:String=""
        if data != nil {
            if let arrayOfJasonObjects = String(data: data!, encoding: String.Encoding.utf8) {
                print(arrayOfJasonObjects)
                let jsonData:Data? = arrayOfJasonObjects.data(using: String.Encoding.utf8)
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: jsonData!)
                    for eachInformation in jsonResult as! [Dictionary<String, AnyObject>] {
                        fullname = ""
                        let fName = eachInformation["firstName"] as! String
                        let lName = eachInformation["lastName"] as! String
                        
                        fullname = fName + " " + lName
                        completeName.insert(String(fullname), at: element)
                        element += 1;
                    }
                    self.tableView.reloadData()
                }
                catch {
                }
                
            } else {
                print(" conversion of data to text failed")
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completeName.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = completeName[indexPath.row]
        return cell
}
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueid", sender: indexPath.row)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let guest = segue.destination as! DetailViewController
        guest.temp = sender as! Int
    }
    
}
