//
//  DetailViewController.swift
//  pro5
//
//  Created by Sushanth on 11/10/16.
//
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate,  UITableViewDataSource {

    
    var details:Dictionary<String, AnyObject> = [:]
    var temp = 0
    let id = 0
    var singleComment:Dictionary<String, AnyObject> = [:]
    var commentArray:Array<String> = []
    
    @IBOutlet weak var fn: UILabel!
    @IBOutlet weak var ln: UILabel!
    @IBOutlet weak var loc: UILabel!
    @IBOutlet weak var contact: UILabel!
    @IBOutlet weak var mail: UILabel!
    @IBOutlet weak var avgRating: UILabel!
    @IBOutlet weak var totalRating: UILabel!
    @IBOutlet weak var rateText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var commentView: UITableView!
    @IBAction func submitpressed(_ sender: Any) {
        
        
        
        if rateText != nil && rateText.text?.characters.count != 0
        {
            if Int(rateText.text!)! >= 1 && Int(rateText.text!)! <= 5
            {
                
                let urlRating = "http://bismarck.sdsu.edu/rateme/rating/"+String(self.temp+1)+"/"+rateText.text!
                var getURL = URLRequest(url: URL(string: urlRating)!)
                getURL.httpMethod = "POST"
                let toDo = URLSession.shared.dataTask(with: getURL) { data, response, error in
                    guard let data = data, error == nil else
                    {
                        print("Error=\(error)")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
                    {
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response)")
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(responseString)")
                }
                toDo.resume()
            }
        }
        
        if commentText != nil
        {
            let urlComments = "http://bismarck.sdsu.edu/rateme/comment/"+String(self.temp+1)
            print(urlComments)
            var getURL = URLRequest(url: URL(string: urlComments)!)
            getURL.httpMethod = "POST"
            let postString = commentText.text
            getURL.httpBody = postString?.data(using: .utf8)
            let toDo = URLSession.shared.dataTask(with: getURL) { data, response, error in
                guard let data = data, error == nil else {
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
                {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")
            }
            toDo.resume()
        }
        
        commentText.text = ""
        rateText.text = ""
        dismissKeyboard()
        
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentView.dataSource = self
        let id = String(temp + 1)
        let urlStr = "http://bismarck.sdsu.edu/rateme/instructor/"+id
        if let url = URL(string: urlStr) {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: downloadProfInfo)
            task.resume()
        }
        else {
            print("Error")
        }
        
       
        let urlStr1 = "http://bismarck.sdsu.edu/rateme/comments/"+id
        if let url1 = URL(string: urlStr1) {
            let session1 = URLSession.shared
            let task1 = session1.dataTask(with: url1, completionHandler: getComments)
            task1.resume()
        }
        else {
            print("Error")
        }
        
        
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
       }
    

    override func viewWillAppear(_ animated: Bool) {
        print("id is \(self.temp)")
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    

    func downloadProfInfo(data:Data?, response:URLResponse?, error:Error?) -> Void {
        
        guard error == nil else {
            print("error: \(error!.localizedDescription)")
            return
        }
        if data != nil {
            if let getRows = String(data: data!, encoding: String.Encoding.utf8) {
                let jsonData:Data? = getRows.data(using: String.Encoding.utf8)
                do
                {
                    let jsonResult = try JSONSerialization.jsonObject(with: jsonData!)
                    details = (jsonResult as! NSDictionary) as! Dictionary<String, AnyObject>
                    DispatchQueue.main.async{
                        self.fn.text = self.details["firstName"] as? String
                        self.ln.text = self.details["lastName"] as? String
                        self.loc.text = self.details["office"] as? String
                        self.contact.text = self.details["phone"] as? String
                        self.mail.text = self.details["email"] as? String
                        let tempdict = self.details["rating"] as! Dictionary<String, Any>
                        self.avgRating.text = "\(tempdict["average"]!)"
                        self.totalRating.text = "\(tempdict["totalRatings"]!)"
                    }
                }
                    
                catch
                {
                }
            }
            else
            {
                print(" conversion of data to text failed")
            }
        }
        }
    
    
    func getComments(data:Data?, response:URLResponse?, error:Error?) -> Void {
        
        guard error == nil else {
            print("error: \(error!.localizedDescription)")
            return
        }
        if data != nil {
            if let commentcontent = String(data: data!, encoding: String.Encoding.utf8) {
                let jsonData1:Data? = commentcontent.data(using: String.Encoding.utf8)
                do
                {
                    let jsonResult1 = try JSONSerialization.jsonObject(with: jsonData1!)
                    for singleComment in jsonResult1 as! [Dictionary<String, AnyObject>] {
                        let comments = singleComment["text"] as! String
                        commentArray.append(comments)
                    }
                   commentView.reloadData()
                    
                }
                    
                catch
                {
                }
            }
            else
            {
                print(" conversion of data to text failed")
            }
        }
    }
    
    
    
    
     func numberOfSections(in commentView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ commentView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
     func tableView(_ commentView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = commentArray[indexPath.row]
        return cell
        
        
    }
    
    
    func moveTextField(textField: UITextField, moveDistance: Int, up:Bool)
    {
        let duration = 0.3
        let movement:CGFloat = CGFloat(up ? moveDistance: -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(duration)
        self.view.frame = self.view.frame.offsetBy(dx: 0 , dy: movement)
        UIView.commitAnimations()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        moveTextField(textField: rateText, moveDistance: -120, up: true)
        moveTextField(textField: commentText, moveDistance: -120, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        moveTextField(textField: rateText, moveDistance: -120, up: false)
        moveTextField(textField: commentText, moveDistance: -120, up: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }

}
