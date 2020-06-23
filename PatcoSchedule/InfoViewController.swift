//
//  InfoViewController.swift
//  PatcoSchedule
//
//  Created by Rob Surrette on 9/5/17.
//  Copyright © 2017 Rob Surrette. All rights reserved.
//

import UIKit
import MessageUI

class InfoViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    //patco fares
    @IBOutlet weak var patcoInfo: UIImageView!
    
    //icons
    @IBOutlet weak var patcoPhone: UIImageView!
    @IBOutlet weak var patcoEmail: UIImageView!
    @IBOutlet weak var patcoWebsite: UIImageView!
    @IBOutlet weak var devEmail: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //patcoInfo.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    
    
    //Patco Phone call
    @IBAction func patcoPhoneCall(_ sender: UIButton) {
        if let url = URL(string: "tel://8567726900"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    
    //Patco Send Email
    @IBAction func patcoSendEmail(_ sender: UIButton) {
        
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
        
    }
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["patco@ridepatco.com"])
        //mailComposerVC.setSubject("Hello")
        //mailComposerVC.setMessageBody("How are you doing?", isHTML: false)
        
        return mailComposerVC
    }
    
    
    
    //Freedom Card reload internet link
    @IBAction func addValue(_ sender: UIButton) {
        if let url = NSURL(string: "http://www.patcofreedomcard.org/front/account/login.jsp?path=/front/add_ride/index.jsp") {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    
    
    //ridepatco.com Internet Link
    @IBAction func patcoWebsite(_ sender: UIButton) {
        if let url = NSURL(string: "http://www.ridepatco.org") {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    
    
    //Rob Surrette Gmail Send Email
    @IBAction func devSendEmail(_ sender: UIButton) {
        
        let mailComposeViewController = configureMailController2()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
        
    }
    
    func configureMailController2() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["robsurrette@gmail.com"])
        mailComposerVC.setSubject("Patco Train Schedule v3.1")
        //mailComposerVC.setMessageBody("How are you doing?", isHTML: false)
        
        return mailComposerVC
    }
    
    
    
    //Mail Error func
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Cannot send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }  

}
