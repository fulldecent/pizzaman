//
//  FriendRank.swift
//  Pizza Slice
//
//  Created by Full Decent on 9/20/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import UIKit
import Contacts
import Alamofire
import MBProgressHUD

enum Player {
    case me;
    case friend([Account]);
    
    init(json jsonObject: [[String : String]]) {
        self = .friend(jsonObject.flatMap {Account(json: $0)})
    }
}

/*
// Can be a local player on this device or may represent someone out there in the world
struct Player {
    /// Whether this player is the user touching the device
    let isMe: Bool
    
    let maxScore: Int
    
    /// Accounts which identify the player
    let accounts: [Account]
    
    init?(json jsonObject: [String : Any]) {
        isMe = false
        guard let newMaxScore = jsonObject["max_score"] as? Int else {
            return nil
        }
        maxScore = newMaxScore
        guard let newAccounts = jsonObject["accounts"] as? [[String : String]] else {
            return nil
        }
        accounts = newAccounts.flatMap {Account(json: $0)}
    }
    
    /*
    private init() {
        isMe = true
        
        accounts = []
    }
 */
    
    static let me: Player = {
        
        
        let retval = Player()
        return retval
    }()
}
*/

struct Account {
    /// What network this account exists in
    let accountType: AccountTypes
    
    /// The globally-unique identifier for this on this network
    let accountIdentifier: String
    
    /// A name that this device may be able to use to uniquely identify this account
    let accountNickname: String?
    
    init?(json jsonObject: [String : String]) {
        guard let stringAccountType = jsonObject["account_type"] else {
            return nil
        }
        guard let newAccountType = AccountTypes.init(rawValue: stringAccountType) else {
            return nil
        }
        guard let newAccountIdentifier = jsonObject["account_identifier"] else {
            return nil
        }
        accountType = newAccountType
        accountIdentifier = newAccountIdentifier
        accountNickname = jsonObject["account_nickname"]
    }
}

enum AccountTypes: String {
    /// A phone contact's name
    case contactsName = "contacts-name"
    
    /// A phone contact's phone number
    case contactsPhone = "contacts-phone"
    
    /// A phone contact's email address
    case contactsEmail = "contacts-email"
}


class FriendRank {
    var myMaxScore = 0
    var delegate: FriendRankDelegate? = nil
    
    let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "anon uuid"
    var didConnectContacts = UserDefaults.standard.bool(forKey: "didConnectContacts")
    var didGivePhoneNumber = UserDefaults.standard.bool(forKey: "didGivePhoneNumber")
    var didGiveScore = UserDefaults.standard.bool(forKey: "didGiveScore")
    
    
    var presentingViewController: UIViewController! = nil
    var contactStore = CNContactStore()

    func showMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        presentingViewController.present(alert, animated: true, completion: nil)
    }
    
    func getAddressBook() {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        var authorized = false

        switch authorizationStatus {
        case .authorized:
            authorized = true
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: .contacts, completionHandler: {
                (access, accessError) -> Void in
                if access {
                    authorized = access
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async {
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(message)
                        }
                    }
                }
            })
            
        case .restricted:
            let message = "Restrictions are in effect that prevent you from sharing your contacts."
            showMessage(message)
        }
        if authorized {
            actuallyGetAddressBook()
        }
    }
    
    func actuallyGetAddressBook() {
        var contacts = [CNContact]()
        let keys: [CNKeyDescriptor] = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactEmailAddressesKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try self.contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                contacts.append(contact)
            }
        }
        catch {
            print("unable to fetch contacts")
        }
    }
    
    func sendAddressBookToCloud(_ contacts: [CNContact]) {
        var parameters: [[String : String]] = []
        let formatter = CNContactFormatter()
        for contact in contacts {
            guard let name = formatter.string(from: contact) else {
                continue // boring contact
            }
            parameters.append([
                "account_type": "contacts-name",
                "account_identifier": name,
                "account_nickname": contact.identifier
                ])
            for phoneNumber in contact.phoneNumbers {
                parameters.append([
                    "account_type": "contacts-phone",
                    "account_identifier": phoneNumber.value.stringValue,
                    "account_nickname": contact.identifier
                    ])
                parameters.append([
                    "account_type": "contacts-phone",
                    "account_identifier": phoneNumber.value.description,
                    "account_nickname": contact.identifier
                    ])
            }
            for emailAddress in contact.emailAddresses {
                parameters.append([
                    "account_type": "contacts-email",
                    "account_identifier": emailAddress.value as String,
                    "account_nickname": contact.identifier
                    ])
            }
        }
        
        let url = URL(string: "https://phor.net/apps/friend-rank/api/1/friends/" + uuid)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        MBProgressHUD.showAdded(to: presentingViewController.view, animated: true)
        Alamofire.request(request).responseJSON {
            (response: DataResponse<Any>) in
            print(response)
            print(String(data: response.data!, encoding: .utf8))
            MBProgressHUD.hide(for: self.presentingViewController.view, animated: true)
            self.didConnectContacts = true
            UserDefaults.standard.set(true, forKey: "didConnectContacts")
            self.delegate?.friendRank(self, wasSuccessful: true)
        }
    }
    
    func getUserNumber() {
        let alert = UIAlertController(title: "Phone number", message: "Please enter your phone number to compare scores", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Save", style: .default) {
            (action: UIAlertAction) in
            if let alertTextField = alert.textFields?.first, alertTextField.text != nil {
                if let number = alertTextField.text {
                    self.sendPhoneNumberToCloud(number: number)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: {
            (textField: UITextField!) in
            textField.placeholder = "Enter text:"
            textField.keyboardType = .phonePad
        })
        self.presentingViewController.present(alert, animated: true) {
            
        }
        
    }
    
    func sendPhoneNumberToCloud(number: String) {
        var parameters: [[String : String]] = []
        parameters.append([
            "account_type": "contacts-phone",
            "account_identifier": number
            ])
        
        let url = URL(string: "https://phor.net/apps/friend-rank/api/1/accounts/" + uuid)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        MBProgressHUD.showAdded(to: presentingViewController.view, animated: true)
        Alamofire.request(request).responseJSON {
            (response: DataResponse<Any>) in
            print(response)
            print(String(data: response.data!, encoding: .utf8))
            MBProgressHUD.hide(for: self.presentingViewController.view, animated: true)
            self.didGivePhoneNumber = true
            UserDefaults.standard.set(true, forKey: "didGivePhoneNumber")
            self.delegate?.friendRank(self, wasSuccessful: true)
        }
    }
    
    func sendScoreToCloud(score: Int) {
        myMaxScore = score
        var parameters: [String : Int] = [:]
        parameters["score"] = score
        
        let url = URL(string: "https://phor.net/apps/friend-rank/api/1/scores/" + uuid)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        Alamofire.request(request).responseJSON {
            (response: DataResponse<Any>) in
            print(response)
        }
    }
    
    // -------------
    
    var rankings = [Player]()
    
    var leaderBoard = [(maxScore: Int, player: Player)]()
    
    func updateRankings(completion: ((Bool) -> Void)?) {
        MBProgressHUD.showAdded(to: presentingViewController.view, animated: true)
        let url = URL(string: "https://phor.net/apps/friend-rank/api/1/rankings/" + uuid)!
        Alamofire.request(url).responseJSON {
            (response: DataResponse<Any>) in
            var newLeaderBoard = [(maxScore: Int, player: Player)]()
            MBProgressHUD.hide(for: self.presentingViewController.view, animated: true)
            if let json = response.result.value as? [[String : Any]] {
                for jsonEntry in json {
                    guard let maxScore = jsonEntry["max_score"] as? Int else {
                        continue
                    }
                    guard let accounts = jsonEntry["accounts"] as? [[String: String]] else {
                        continue
                    }
                    newLeaderBoard.append((maxScore: maxScore, player: Player(json: accounts)))
                }
                let myBoardEntry: (maxScore: Int, player: Player) = (maxScore: self.myMaxScore, player: .me)
                let indexToInsert = newLeaderBoard.index(where: {$0.maxScore < self.myMaxScore}) ?? self.leaderBoard.endIndex
                newLeaderBoard.insert(myBoardEntry, at: indexToInsert)
                self.leaderBoard = newLeaderBoard
                completion?(true)
            } else {
                // Malformed response
                completion?(false)
            }
        }
    }
}

protocol FriendRankDelegate {
    func friendRank(_ friendRank: FriendRank, wasSuccessful success: Bool)
}
