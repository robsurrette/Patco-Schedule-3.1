//
//  StoreViewController.swift
//  PatcoSchedule
//
//  Created by Rob Surrette on 8/20/17.
//  Copyright © 2017 Rob Surrette. All rights reserved.
//

import UIKit
import StoreKit

class StoreViewController: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    

    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var buyButton: UIButton!
    
    var product: SKProduct?
    var productID = "com.robsurrette.PatcoTrainSchedule.removeAds"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add border to buy button
        buyButton.layer.cornerRadius = 6
        buyButton.layer.borderWidth = 1
        buyButton.layer.borderColor = UIColor.blue.cgColor
        
        buyButton.isHidden = true
        buyButton.isEnabled = false
        SKPaymentQueue.default().add(self)
        getPurchaseInfo()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let save = UserDefaults.standard
        if save.value(forKey: "Purchase") != nil {
            
            productTitle.text = "Thank you!"
            productDescription.text = "This product has been purchased."
            buyButton.isEnabled = false
            buyButton.layer.borderColor = UIColor.lightGray.cgColor
            
        }
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func purchase(_ sender: UIButton) {
        let payment = SKPayment(product: product!)
        SKPaymentQueue.default().add(payment)
    }
    
    
    @IBAction func restore(_ sender: UIButton) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    
    func getPurchaseInfo() {
        
        if SKPaymentQueue.canMakePayments() {
            
            let request = SKProductsRequest(productIdentifiers: NSSet(objects: self.productID) as! Set<String>)
            request.delegate = self
            request.start()
            
        } else {
            
            productTitle.text = "Warning"
            productDescription.text = "Please enable in-app-purchases in your settings."
            
        }
        
    }
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        var products2 = response.products
        
        let save = UserDefaults.standard
        
        
        if products2.count == 0 {
            
            productTitle.text = "Warning"
            productDescription.text = "Product not found."
            
        } else if save.value(forKey: "Purchase") == nil {
            
            //If there is a product to grab and they did not buy it, display it here
            product = products2[0]
            productTitle.text = product!.localizedTitle
            productDescription.text = product!.localizedDescription
            
            buyButton.isHidden = false
            buyButton.isEnabled = true
        }
        
        let invalids = response.invalidProductIdentifiers
        
        for product in invalids {
            print("****Product not found:  \(product)")
        }
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            
            case SKPaymentTransactionState.purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                productTitle.text = "Thank you!"
                productDescription.text = "This product has been purchased."
                buyButton.isEnabled = false
                buyButton.layer.borderColor = UIColor.lightGray.cgColor
                
                //Set save point if user buys ad removal
                let save = UserDefaults.standard
                save.set(true, forKey: "Purchase")
                save.synchronize()
                
                
            case SKPaymentTransactionState.restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                productTitle.text = "Welcome Back!"
                productDescription.text = "This product has been restored."
                buyButton.isEnabled = false
                buyButton.layer.borderColor = UIColor.lightGray.cgColor
                
                //Set save point if user buys ad removal
                let save = UserDefaults.standard
                save.set(true, forKey: "Purchase")
                save.synchronize()
                
                
            case SKPaymentTransactionState.failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                productTitle.text = "Warning"
                productDescription.text = "This product has not been purchased."
                
            default:
                break
                
            }
            
        }
        
    }

    
}
