//
//  FeedViewController.swift
//  parsestagram
//
//  Created by Isaac Perez on 8/3/21.
//
import Parse
import UIKit
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        //top of keyboar is hidden until you click on comment bar
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
       // create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground { success, error in
            if success{
                print("Comment saved")
            }else{
                print("Error saving comment")
            }
        }
        //comments will show after posting them
        tableView.reloadData()
        
        //clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        //keyboard is dismissed after posting comment
        commentBar.inputTextView.resignFirstResponder()
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    //pull in post that was just created
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //make query
        let query = PFQuery(className:"Post")
        //include key
        query.includeKeys(["author", "comments", "comments.author"])
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
        let post = posts[section]
        //grab the comments as an array of PFObjects
        //?? is a nil coalescing operator
        //if what ever is on the left is nil set it equal to what is on the right ie a default value
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        // 2 for the actual post and the comment box+ the comment
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        //determine what type of cell is reurned
        //post cell is always the 0th row
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
           
            let user = post["author"] as! PFUser
            cell.userNameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
        }  else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.comentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
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
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        //keyboard shows up when you click on comment bar
        if indexPath.row == comments.count + 1{
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
            
        }
        

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
