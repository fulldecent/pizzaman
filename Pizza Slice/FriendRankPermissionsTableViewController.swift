//
//  FriendRankPermissionsTableViewController.swift
//  Pizza Slice
//
//  Created by Full Decent on 9/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import UIKit


/*

let sources = [
    "Phone contacts",
    "Enter your number"
//    ,
//    "Facebook",
//    "Twitter"
]

let colors = [
    UIColor(red: 230.0/255, green: 126.0/255, blue: 34.0/255, alpha: 1),
    UIColor(red: 39.0/255, green: 174.0/255, blue: 96.0/255, alpha: 1),
    UIColor(red: 142.0/255, green: 68.0/255, blue: 173.0/255, alpha: 1),
    UIColor(red: 192.0/255, green: 57.0/255, blue: 43.0/255, alpha: 1),
    UIColor(red: 241.0/255, green: 196.0/255, blue: 15.0/255, alpha: 1),
    UIColor(red: 52.0/255, green: 152.0/255, blue: 219.0/255, alpha: 1)
]
*/

class FriendRankPermissionsTableViewController: UITableViewController {
    enum TableSections: Int {
        case givePermission = 0
        case leaderboard = 1
    }
    
    let TableSectionHeaders: [TableSections : String] = [
        .givePermission: "ADD FRIENDS TO COMPARE SCORES\nPizza Slice does not message your friends",
        .leaderboard: "LEADERBOARD"
    ]
    
    let permissions: [(name: String, color: UIColor, icon: String?)] = [
        (name: "Phone contacts", color: UIColor(red: 230.0/255, green: 126.0/255, blue: 34.0/255, alpha: 1), icon: nil),
        (name: "Enter your number", color: UIColor(red: 39.0/255, green: 174.0/255, blue: 96.0/255, alpha: 1), icon: nil)
    ]

    let friendRank = FriendRank()    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 31.0/255, green: 42.0/255, blue: 62.0/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        navigationController?.navigationBar.barStyle = .black
        self.friendRank.delegate = self
        self.friendRank.presentingViewController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return [TableSections.givePermission, TableSections.leaderboard].count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableSections(rawValue: section)! {
        case .givePermission:
            return permissions.count
        case .leaderboard:
            return friendRank.leaderBoard.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "source", for: indexPath)
        switch TableSections(rawValue: indexPath.section)! {
        case .givePermission:
            cell.textLabel?.text = permissions[indexPath.row].name
            cell.backgroundColor = permissions[indexPath.row].color
            cell.textLabel?.textColor = .white
            
            switch indexPath.row {
            case 0:
                cell.accessoryType = friendRank.didConnectContacts ? .checkmark : .none
            case 1:
                cell.accessoryType = friendRank.didGivePhoneNumber ? .checkmark : .none
            default:
                break
                
            }
        case .leaderboard:
            break
        }
        return cell
    }
    
    
    ///
    let headerFont = UIFont.systemFont(ofSize: 14)
    let margin: CGFloat = 20

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerText = TableSectionHeaders[TableSections(rawValue: section)!]!
        let width = tableView.frame.size.width - margin * 2
        return height(ofText: headerText, withFont: headerFont, boundedByWidth: width) + margin * 2
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerText = TableSectionHeaders[TableSections(rawValue: section)!]!
        let textHeight = self.tableView(tableView, heightForHeaderInSection: section)
        let headerLabel = UILabel(frame: CGRect(x: margin, y: 0, width: tableView.frame.size.width - margin * 2, height: textHeight))
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .byWordWrapping
        headerLabel.font = headerFont
        headerLabel.text = headerText
        headerLabel.textColor = .white
        let container = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: textHeight + margin * 2))
        container.addSubview(headerLabel)
        return container;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            return
        }
        switch indexPath.row {
        case 0:
            friendRank.presentingViewController = self
            friendRank.getAddressBook()
        case 1:
            friendRank.presentingViewController = self
            friendRank.getUserNumber()
        default:
            break
        }
        
    }


    /////
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        friendRank.updateRankings {
            (Bool) -> Void in
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
}

func height(ofText text: String, withFont font: UIFont, boundedByWidth width: CGFloat) -> CGFloat {
    return NSString(string: text).boundingRect(
        with: CGSize(width: width, height: 9999),
        options: .usesLineFragmentOrigin,
        attributes: [NSFontAttributeName : font],
        context: nil
        ).size.height
}

extension FriendRankPermissionsTableViewController: FriendRankDelegate {
    func friendRank(_ friendRank: FriendRank, wasSuccessful success: Bool) {
        self.tableView.reloadData()
    }
   
}
