//
//  FeedViewController.swift
//  parsestagram
//
//  Created by Isaac Perez on 8/3/21.
//
import Parse
import UIKit
import AlamofireImage

class FeedViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    
    var posts = [PFObject]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //pull in post that was just created
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //make query
        let query = PFQuery(className:"Post")
        //include key
        query.includeKey("author")
        //get the last 20
        query.limit = 20
        
        //get the query
        query.findObjectsInBackground { posts, error in
            if posts != nil{
                self.posts = posts!//store the data
                self.tableView.reloadData()//reload the table view
            }
        }
    }
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell 
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.userNameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as? String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af_setImage(withURL: url)
        return cell
        
    }

    @IBAction func onLogOutButton(_ sender: Any) {
        //user is logged out
        
        PFUser.logOut()
        
        //switch user back to login screen
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else {return}
        
        delegate.window?.rootViewController = loginViewController
 
    }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
