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

class FriendRank {
    
    
    let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "anon uuid"
    var didConnectContacts = UserDefaults.standard.bool(forKey: "didConnectContacts")
    var didGivePhoneNumber = UserDefaults.standard.bool(forKey: "didGivePhoneNumber")
    
    
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
        
        let fmt = CNContactFormatter()
        sendAddressBookToCloud(contacts)
        /*
        for contact in contacts {
            guard let name = fmt.string(from: contact) else {
                continue // boring contact
            }
            
            print(name)
            print(contact.identifier)
            for emailAddress in contact.emailAddresses {
                print(emailAddress.value)
            }
            for phoneNumber in contact.phoneNumbers {
                print(phoneNumber.value.stringValue)
                print(phoneNumber.value.description)
            }
        }
         */
    }
    
    func sendAddressBookToCloud(_ contacts: [CNContact]) {
        var parameters: [[String : String]] = []
        let formatter = CNContactFormatter()
        for contact in contacts {
            guard let name = formatter.string(from: contact) else {
                continue // boring contact
            }
            for phoneNumber in contact.phoneNumbers {
                parameters.append([
                    "account_type": "contacts-phone",
                    "account_id": phoneNumber.value.stringValue,
                    "account_nickname": contact.identifier
                    ])
                parameters.append([
                    "account_type": "contacts",
                    "account_id": phoneNumber.value.description,
                    "account_nickname": contact.identifier
                    ])
            }
            for emailAddress in contact.emailAddresses {
                parameters.append([
                    "account_type": "contacts-email",
                    "account_id": emailAddress.value as String,
                    "account_nickname": contact.identifier
                    ])
            }
        }
        
        let url = "https://phor.net/apps/friend-rank/api/1/friends/" + uuid
        Alamofire.request(url, method: .post, parameters: ["friends": parameters], encoding: JSONEncoding.default, headers: nil)
        .responseJSON {
            (response: DataResponse<Any>) in
        }
    }
    
    func getUserNumber() {
        let alert = UIAlertController(title: "Phone number", message: "Please enter your phone number to compare scores", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: nil))
        alert.addTextField(configurationHandler: {
            (textField: UITextField!) in
            textField.placeholder = "Enter text:"
            textField.keyboardType = .phonePad
        })
        self.presentingViewController.present(alert, animated: true, completion: nil)
    }
}
