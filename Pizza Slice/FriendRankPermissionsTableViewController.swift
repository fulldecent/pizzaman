//
//  FriendRankPermissionsTableViewController.swift
//  Pizza Slice
//
//  Created by Full Decent on 9/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import UIKit

let sources = [
    "Phone contacts",
    "Enter your number"
//    ,
//    "Facebook",
//    "Twitter"
]

let colors = [
    UIColor(red: 52.0/255, green: 152.0/255, blue: 219.0/255, alpha: 1),
    UIColor(red: 230.0/255, green: 126.0/255, blue: 34.0/255, alpha: 1),
    UIColor(red: 39.0/255, green: 174.0/255, blue: 96.0/255, alpha: 1),
    UIColor(red: 142.0/255, green: 68.0/255, blue: 173.0/255, alpha: 1),
    UIColor(red: 192.0/255, green: 57.0/255, blue: 43.0/255, alpha: 1),
    UIColor(red: 241.0/255, green: 196.0/255, blue: 15.0/255, alpha: 1)
]

class FriendRankPermissionsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 31.0/255, green: 42.0/255, blue: 62.0/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        navigationController?.navigationBar.barStyle = .black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "source", for: indexPath)
        cell.textLabel?.text = sources[indexPath.row]
        cell.backgroundColor = colors[indexPath.row]
        cell.textLabel?.textColor = .white
        
        let FR = FriendRank()
        switch indexPath.row {
        case 0:
            cell.accessoryType = FR.didConnectContacts ? .checkmark : .none
        case 1:
            cell.accessoryType = FR.didGivePhoneNumber ? .checkmark : .none
        default:
            break
        
        }
        
        return cell
    }
    
    
    ///
    let headerText = "ADD FRIENDS TO COMPARE SCORES\nPizza Slice does not message your friends"
    let headerFont = UIFont.systemFont(ofSize: 14)
    let margin: CGFloat = 20

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let width = tableView.frame.size.width - margin * 2
        return height(ofText: headerText, withFont: headerFont, boundedByWidth: width) + margin * 2
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        switch indexPath.row {
        case 0:
            let fr = FriendRank()
            fr.presentingViewController = self
            fr.getAddressBook()
        case 1:
            let fr = FriendRank()
            fr.presentingViewController = self
            fr.getUserNumber()
        default:
            break
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
