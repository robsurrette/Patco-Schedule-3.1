//
//  TimesViewController.swift
//  PatcoSchedule
//
//  Created by Rob Surrette on 4/3/18.
//  Copyright © 2018 Rob Surrette. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase

var userSelectedDate = ""
var weekday = 0
var todaysDate = ""
//var firebaseHour = ""



class TimesViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    var refresher: UIRefreshControl!
    
    let dateFormatter = DateFormatter()
    
    var startStationHour = [Int]()
    var startStationMinute = [Int]()
    var endStationHour = [Int]()
    var endStationMinute = [Int]()
    
    var finalStartTimes = [String]()
    var finalEndTimes = [String]()
    var finalTime = [String]()
    
    var timeDiffMin = [String]()
    var timeDiffHour = [String]()
    var timeDiffFinal = [String]()
    
    var flag = 0
    var startStation = 0
    var endStation = 0
    var tempStation = ""
    
    // Create UserDefaults
    let defaults = UserDefaults.standard
    
    
    
    // outlets
    @IBOutlet weak var stationPicker: UIPickerView!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    
    @IBOutlet weak var switchStationButton: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var openDatePicker: UIButton!
    @IBOutlet weak var selectDateButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneStationButton: UIButton!
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var specialScheduleButton: UIButton!
    
    
    
    var stationList = ["Lindenwold", "Ashland", "Woodcrest", "Haddonfield", "Westmont", "Collingswood", "Ferry Avenue", "Broadway", "City Hall", "8th & Market", "9/10th & Locust", "12/13th & Locust", "15/16th & Locust"]
    



    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /*
        // Set up effective date label at the top of table view
        let headerLabel = UILabel()
        headerLabel.text = "Effective: June 16, 2018"
        headerLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 25)
        
        headerLabel.layer.borderWidth = 0.75
        headerLabel.layer.borderColor = UIColor.black.cgColor
        
        headerLabel.font = UIFont(name:"SFProDisplay-Regular", size: 12.0)
        headerLabel.textAlignment = .center
        
        //tableView.tableHeaderView = headerLabel
        tableView.tableFooterView = headerLabel
        */
    
        
        // Set up userSelectedDate as the current day when app is first opened
        userSelectedDate = "\(Calendar.current.component(.month, from: Date()))/\(Calendar.current.component(.day, from: Date()))"
        weekday = Calendar.current.component(.weekday, from: Date())
        
        dateFormatter.dateFormat = "EEEE, MMMM d"
        openDatePicker.setTitle("  \(dateFormatter.string(from: Date()))", for: .normal)
        
        
        // Hide date picker and select date button
        datePicker.isHidden = true
        selectDateButton.isHidden = true
        
        // Hide special schedule button
        specialScheduleButton.isHidden = true
        
        // hide station picker view done button
        doneStationButton.isHidden = true
        
        startTextField.delegate = self
        stationPicker.delegate = self
        
        // Start with station picker hidden
        stationPicker.isHidden = true
        
        // Called when user clicks on text field
        startTextField.addTarget(self, action: #selector(clickedOnStartTextField), for: .touchDown)
        endTextField.addTarget(self, action: #selector(clickedOnEndTextField), for: .touchDown)
        
        
        
        // Set up pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(TimesViewController.populateTimes), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
 
        
        tableView.allowsSelection = false
        
        
        // Admob setup
        bannerView.isHidden = true
        bannerView.delegate = self
        
        // Add 50 pixel space to bottom of table view
        super.viewDidLayoutSubviews()
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        
        
        // Check if start station user default is set
        if defaults.value(forKey: "startStationUD") != nil {
            startTextField.text = defaults.string(forKey: "startStationUD")!
        } else {
            startTextField.text = "Lindenwold"
        }
        
        
        // Check if end station user default is set
        if defaults.value(forKey: "endStationUD") != nil {
            endTextField.text = defaults.string(forKey: "endStationUD")!
        } else {
            endTextField.text = "15/16th & Locust"
        }
        
        
        populateTimes()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Set date picker btton text to userSelectedDate
        //openDatePicker.setTitle(userSelectedDate, for: .normal)
        
        //Check if user has bought Remove Ads or not
        let save = UserDefaults.standard
        if save.value(forKey: "Purchase") == nil {
            
            bannerView.adUnitID = "ca-app-pub-1650430001549870/3815844675"
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            
        } else {
            
            bannerView.isHidden = true
            
        }
    }
    
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        bannerView.isHidden = true
    }
    
    
    
    func clickedOnStartTextField() {
        
        // hide table view
        tableView.isHidden = true
        
        // hide switch station button
        switchStationButton.isHidden = true
        
        // disable date picker button
        openDatePicker.isEnabled = false
        
        // show picker view
        stationPicker.isHidden = false
        
        // show done button
        doneStationButton.isHidden = false
        
        // disable user from typing in text box
        startTextField.isUserInteractionEnabled = false
        endTextField.isUserInteractionEnabled = false
        
        // hide keyboard
        startTextField.resignFirstResponder()
        
        flag = 0
    }
    
    func clickedOnEndTextField() {
        
        // hide table view
        tableView.isHidden = true
        
        // hide switch station button
        switchStationButton.isHidden = true
        
        // disable date picker button
        openDatePicker.isEnabled = false
        
        // show picker view
        stationPicker.isHidden = false
        
        // show done button
        doneStationButton.isHidden = false
        
        // disable user from typing in text box
        endTextField.isUserInteractionEnabled = false
        startTextField.isUserInteractionEnabled = false
        
        // hide keyboard
        endTextField.resignFirstResponder()
        
        flag = 1
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows in the picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return stationList.count
    }
    
    // Names of items in the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stationList[row]
    }
    
    // Called when user clicks item in picker
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        if flag == 0 {
            startTextField.text = stationList[row]
        }
        
        if flag == 1 {
            endTextField.text = stationList[row]
        }
        
    }
    
    
    @IBAction func doneStationButtonClicked(_ sender: UIButton) {
        
        // show table view
        tableView.isHidden = false
        
        // show switch station button
        switchStationButton.isHidden = false
        
        // enable date picker button
        openDatePicker.isEnabled = true
        
        // hide station picker
        stationPicker.isHidden = true
        
        // hide picker view done button
        doneStationButton.isHidden = true
        
        startTextField.isUserInteractionEnabled = true
        endTextField.isUserInteractionEnabled = true
        
        // save start and end station user defaults
        defaults.set(startTextField.text, forKey: "startStationUD")
        defaults.set(endTextField.text, forKey: "endStationUD")
        
        populateTimes()
        
    }
    
    
    
    @IBAction func switchStationButton(_ sender: UIButton) {
        
        tempStation = startTextField.text!
        startTextField.text = endTextField.text
        endTextField.text = tempStation
        
        // save start and end station user defaults
        defaults.set(startTextField.text, forKey: "startStationUD")
        defaults.set(endTextField.text, forKey: "endStationUD")
        
        populateTimes()
        
    }
    
    
    
    
    @IBAction func openDatePicker(_ sender: UIButton) {
        
        // Show date picker and select date button
        datePicker.isHidden = false
        selectDateButton.isHidden = false
        
        // Hide tableView and special schedule button
        tableView.isHidden = true
        specialScheduleButton.isHidden = true
        
        // Hide switch station button
        switchStationButton.isHidden = true
        
        // disable user from typing in text box
        startTextField.isUserInteractionEnabled = false
        endTextField.isUserInteractionEnabled = false
        
    }
    
    
    @IBAction func selectDateClicked(_ sender: UIButton) {
        
        weekday = Calendar.current.component(.weekday, from: datePicker.date)
        
        // Get date of user selection
        let year = Calendar.current.component(.year, from: datePicker.date)
        let month = Calendar.current.component(.month, from: datePicker.date)
        let day = Calendar.current.component(.day, from: datePicker.date)
        userSelectedDate = "\(month)/\(day)"
        
        // Hide date picker and select date button
        datePicker.isHidden = true
        selectDateButton.isHidden = true
        
        // Show tableView and special schedule button
        tableView.isHidden = false
        specialScheduleButton.isHidden = false
        
        // show switch station button
        switchStationButton.isHidden = false
        
        // Enable user from typing in text box
        startTextField.isUserInteractionEnabled = true
        endTextField.isUserInteractionEnabled = true
        
        // Set date formatter to incldude day of week
        dateFormatter.dateFormat = "EEEE, MMMM d"
        
        // Set date picker btton text to userSelectedDate
        openDatePicker.setTitle("  \(dateFormatter.string(from: datePicker.date))", for: .normal)
        
        // re-populate times based on what user selects
        populateTimes()
        
    }
    
    
    
    // =====================================================================================
    
    func populateTimes() {
        
        finalStartTimes = []
        finalEndTimes = []
        finalTime = []
        
        timeDiffFinal = []
        timeDiffMin = []
        timeDiffHour = []
        
        
        // Set todaysDate
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        todaysDate = "\(month)/\(day)"
        
        
        specialScheduleButton.isHidden = true
        
        checkSpecialSchedule()

        
        
        var hour = 0
        var minutes = 0
        
        // If user chose today's date, get current times (otherwise times will start from midnight on)
        if userSelectedDate == todaysDate {
            hour = Calendar.current.component(.hour, from: Date())
            minutes = Calendar.current.component(.minute, from: Date())
        }
        
        if startTextField.text != "" && endTextField.text != "" {
            
            // Assign numbers to stations to get Direction of Trip
            stationDirection()
            
            // Populate start and end tme arrays
            getStartAndEndStationTimes()
            
            
            /*
            if hour == 0 {
                firebaseHour = "12 am"
            } else if hour >= 1 && hour <= 11 {
                firebaseHour = "\(hour) am"
            } else if hour == 12 {
                firebaseHour = "12 pm"
            } else {
                firebaseHour = "\(hour-12) pm"
            }
            
            // Firebase data logging
            Analytics.logEvent("Schedule_Viewed", parameters: ["Start_Station": startTextField.text!, "End_Station": endTextField.text!, "Current_Time": firebaseHour])
            */
            
            
        // Populate starting times
        for (index,element) in startStationHour.enumerated() {
            if element==hour && startStationMinute[index]>=minutes {
                finalStartTimes.append(convertTime(xhour: startStationHour[index], xminute: startStationMinute[index]))
                finalEndTimes.append(convertTime(xhour: endStationHour[index], xminute: endStationMinute[index]))
                
                timeDiffHour.append(" ")
                timeDiffMin.append("\(startStationMinute[index]-minutes) minutes")
            } else if element>hour && element != 99 {
                finalStartTimes.append(convertTime(xhour: startStationHour[index], xminute: startStationMinute[index]))
                finalEndTimes.append(convertTime(xhour: endStationHour[index], xminute: endStationMinute[index]))
                
                //Set up arriving times array
                if minutes == 0 {
                    if startStationHour[index]-hour-1 == 0 {
                        timeDiffHour.append(" ")
                        timeDiffMin.append("\(60-minutes) minutes")
                    } else if startStationHour[index]-hour-1 == 1 {
                        timeDiffHour.append("\(startStationHour[index]-hour-1) hour")
                        timeDiffMin.append(" and \(60-minutes) minutes")
                    } else {
                        timeDiffHour.append("\(startStationHour[index]-hour-1) hours")
                        timeDiffMin.append(" and \(60-minutes) minutes")
                    }
                    
                } else if startStationMinute[index] < minutes {
                    if startStationHour[index]-hour-1 == 0 {
                        timeDiffHour.append(" ")
                        timeDiffMin.append("\(60-minutes + startStationMinute[index]) minutes")
                    } else if startStationHour[index]-hour-1 == 1 {
                        timeDiffHour.append("\(startStationHour[index]-hour-1) hour")
                        timeDiffMin.append(" and \(60-minutes + startStationMinute[index]) minutes")
                    } else {
                        timeDiffHour.append("\(startStationHour[index]-hour-1) hours")
                        timeDiffMin.append(" and \(60-minutes + startStationMinute[index]) minutes")
                    }
                    
                } else {
                    if startStationHour[index]-hour == 0 {
                        timeDiffHour.append(" ")
                        timeDiffMin.append("\(startStationMinute[index]-minutes) minutes")
                    } else if startStationHour[index]-hour == 1 {
                        timeDiffHour.append("\(startStationHour[index]-hour) hour")
                        timeDiffMin.append(" and \(startStationMinute[index]-minutes) minutes")
                    } else {
                        timeDiffHour.append("\(startStationHour[index]-hour) hours")
                        timeDiffMin.append(" and \(startStationMinute[index]-minutes) minutes")
                    }
                    
                } // end of arriving times array
                
              
            }
        }
        
        
        
        
        // Mark Express Trains
        
        if finalStartTimes.count != 0 {
            
            // If direction is west and it is a weekday
            if startStation < endStation && weekday != 7 && weekday != 1 {
                
                for k in 0...finalStartTimes.count-1 {
                    
                    // If station is Lindenwold
                    if startStation == 0 {
                        
                        if finalStartTimes[k] == "7:48 am" || finalStartTimes[k] == "7:57 am" || finalStartTimes[k] == "8:04 am" || finalStartTimes[k] == "8:12 am" || finalStartTimes[k] == "8:20 am" {
                            timeDiffMin[k] = "\(timeDiffMin[k])  -  EXPRESS"
                        }
                        
                    }
                    
                    // If station is Ashland
                    if startStation == 1 {
                        
                        if finalStartTimes[k] == "7:50 am" || finalStartTimes[k] == "7:59 am" || finalStartTimes[k] == "8:06 am" || finalStartTimes[k] == "8:14 am" || finalStartTimes[k] == "8:22 am" {
                            timeDiffMin[k] = "\(timeDiffMin[k])  -  EXPRESS"
                        }
                        
                    }
                    
                    // If station is Woodcrest
                    if startStation == 2 {
                        
                        if finalStartTimes[k] == "7:51 am" || finalStartTimes[k] == "8:00 am" || finalStartTimes[k] == "8:07 am" || finalStartTimes[k] == "8:15 am" || finalStartTimes[k] == "8:23 am" {
                            timeDiffMin[k] = "\(timeDiffMin[k])  -  EXPRESS"
                        }
                        
                    }
                    
                } // end of for statement
            }
            
        }
        
        
        
        
        // Populate ending times
        if finalStartTimes.count != 0 {
            for j in 0...finalStartTimes.count-1 {
                if finalStartTimes[j] != "87:99 pm" && finalEndTimes[j] != "87:99 pm" {
                    finalTime.append("\(finalStartTimes[j])  →  \(finalEndTimes[j])")
                    timeDiffFinal.append("\(timeDiffHour[j])\(timeDiffMin[j])")
                }
            }
        } else {
            finalTime.append("No more trains tonight")
        }
        
       
        
        // If user selects day other than current date, clear timeDiffFinal array
        if userSelectedDate != todaysDate {
            
            let timeDiffCount = timeDiffFinal.count
            for i in 0 ... timeDiffCount-1 {
                
                // If TimeDiffFinal does not contain Express, clear all text.  If it does, leave Express text
                if timeDiffFinal[i].range(of:"EXPRESS") == nil {
                    timeDiffFinal[i] = ""
                } else {
                    timeDiffFinal[i] = "EXPRESS TRAIN"
                }
                
            }
        }
        
        
        }
        
        self.tableView.reloadData()
        refresher.endRefreshing()
        
    } // end of populateTimes()
    
    // =====================================================================================
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalTime.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75 //set row height
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timesCell", for: indexPath)
        
        //allow multiple lines on one cell
        cell.textLabel!.numberOfLines = 0
        
        if finalTime[0] != "No more trains tonight" {
            let myString = NSMutableAttributedString(string: "\(finalTime[indexPath.row])\n\(timeDiffFinal[indexPath.row])")
            
            // Set font ranges
            let arrivingRange = NSRange(location: finalTime[indexPath.row].characters.count+1, length: timeDiffFinal[indexPath.row].characters.count)
            let timesRange = NSRange(location: 0, length: finalTime[indexPath.row].characters.count)
            let arrowRange = NSRange(location: finalStartTimes[indexPath.row].characters.count+2, length: 1) //+2, 1
            
            // Set font size attributes
            let smallFontAttribute = [ NSFontAttributeName: UIFont(name: "SFProDisplay-Regular", size: 14.0)! ]
            let bigFontAttribute = [ NSFontAttributeName: UIFont(name: "SFProDisplay-Medium", size: 23)! ]
            let arrowAttribute = [ NSFontAttributeName: UIFont(name: "Avenir", size: 22)! ]
            
            // add attributes to string
            myString.addAttributes(bigFontAttribute, range: timesRange)
            myString.addAttributes(smallFontAttribute, range: arrivingRange)
            myString.addAttributes(arrowAttribute, range: arrowRange)
            
            // Make times dark grey
            //myString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1.00), range: timesRange)
            
            // If EXPRESS word is not found in timeDiffFinal then make text red, otherwise make it green
            if timeDiffFinal[indexPath.row].range(of:"EXPRESS") == nil {
                myString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 209/255, green: 17/255, blue: 64/255, alpha: 1.00), range: arrivingRange)
            } else {
                myString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0/255, green: 150/255, blue: 36/255, alpha: 1.00), range: arrivingRange)
            }
            
            
            cell.textLabel?.attributedText = myString
            
            
        } else {
            cell.textLabel?.text = "No more trains tonight"
        }
        
        return cell
    }
    
    
    
    // Check for special schedule and display alert if there is one
    func checkSpecialSchedule() {
        
        // Hide special schedule alert
        specialScheduleButton.isHidden = true
        
        
        let myURLString = "http://www.ridepatco.org/schedules/alerts.asp"
        guard let myURL = URL(string: myURLString) else {
            print("**** Error: \(myURLString) is not a valid URL")
            return
        }
        
        do {
     
            // get HTML source code of patco alerts page
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            
            // default range of "schedule"
            var range: Range<String.Index> = myHTMLString.lowercased().range(of: "patco")!
            
            // find range of "station alert" and if that doesn't exist, use index of "elevator"
            if myHTMLString.range(of: "Station Alert") != nil {
                range = myHTMLString.range(of: "Station Alert")!
            } else if myHTMLString.range(of: "Elevator") != nil {
                range = myHTMLString.range(of: "Elevator")!
            }
 
            // get index number of where text "Station Alert" is within the entire HTML code
            let indexNum: Int = myHTMLString.distance(from: myHTMLString.startIndex, to: range.lowerBound)
            
            // cut HTML code into first half (up to "Station Alert")
            let subString = myHTMLString.index(myHTMLString.startIndex, offsetBy: indexNum)
            let finalHTMLstring = myHTMLString.substring(to: subString)
         
            
            
            if userSelectedDate == todaysDate {
                // if todays special schedule date appears two times in HTML substring
                
                let numTimesDateAppearsOnPage = finalHTMLstring.components(separatedBy: "\(todaysDate)")
                
                if numTimesDateAppearsOnPage.count-1 >= 2 {
                    
                    specialScheduleButton.isHidden = false
                    specialScheduleButton.setTitle("Special Schedule in effect for today.\nClick here to view.", for: .normal)
                    specialScheduleButton.titleLabel?.textAlignment = NSTextAlignment.center
                }
                
                
            } else {
                // if future special schedule date appears only once on page

                if finalHTMLstring.range(of: "\(userSelectedDate)") != nil {
                    
                    specialScheduleButton.isHidden = false
                    specialScheduleButton.setTitle("Special Schedule in effect for \(userSelectedDate).\nClick here to view.", for: .normal)
                    specialScheduleButton.titleLabel?.textAlignment = NSTextAlignment.center
                }
                
            }
            
            
        } catch let error {
            print("**** Error: \(error)")
        }
        
    }
    
    
    @IBAction func specialScheduleClicked(_ sender: UIButton) {
        
        if let url = NSURL(string: "http://www.ridepatco.org/schedules/alerts.asp") {
            UIApplication.shared.openURL(url as URL)
        }
        
    }
    
    
    
    // Convert times
    func convertTime(xhour: Int, xminute: Int) -> String {
        
        if xhour==24 && xminute>=10 {             //If time is 24:00
            return "\(xhour-12):\(xminute) am"
            
        } else if xhour==24 && xminute<10 {
            return "\(xhour-12):0\(xminute) am"
            
        } else if xhour>12 && xminute>=10 {             //If time is pm (1pm-11:59pm)
            return "\(xhour-12):\(xminute) pm"
            
        } else if xhour>12 && xminute<10 {
            return "\(xhour-12):0\(xminute) pm"
            
        } else if xhour==0 && xminute>=10 {      //If its between midnight and 12:59AM
            return "\(xhour+12):\(xminute) am"
            
        } else if xhour==0 && xminute<10 {
            return "\(xhour+12):0\(xminute) am"
            
        } else if xhour==12 && xminute>=10 {      // 12:00pm - 12:59pm
            return "\(xhour):\(xminute) pm"
            
        } else if xhour==12 && xminute<10 {
            return "\(xhour):0\(xminute) pm"
            
        } else if xminute>=10 {                  //If time is am
            return "\(xhour):\(xminute) am"
            
        } else {
            return "\(xhour):0\(xminute) am"
            
        }
        
    }
    
    
    
    
    func stationDirection() {
        
        switch startTextField.text! {
        case "Lindenwold" :
            startStation = 0
        case "Ashland" :
            startStation = 1
        case "Woodcrest" :
            startStation = 2
        case "Haddonfield" :
            startStation = 3
        case "Westmont" :
            startStation = 4
        case "Collingswood" :
            startStation = 5
        case "Ferry Avenue" :
            startStation = 6
        case "Broadway" :
            startStation = 7
        case "City Hall" :
            startStation = 8
        case "8th & Market" :
            startStation = 9
        case "9/10th & Locust" :
            startStation = 10
        case "12/13th & Locust" :
            startStation = 11
        case "15/16th & Locust" :
            startStation = 12
        default :
            print("default case")
        }
        
        
        switch endTextField.text! {
        case "Lindenwold" :
            endStation = 0
        case "Ashland" :
            endStation = 1
        case "Woodcrest" :
            endStation = 2
        case "Haddonfield" :
            endStation = 3
        case "Westmont" :
            endStation = 4
        case "Collingswood" :
            endStation = 5
        case "Ferry Avenue" :
            endStation = 6
        case "Broadway" :
            endStation = 7
        case "City Hall" :
            endStation = 8
        case "8th & Market" :
            endStation = 9
        case "9/10th & Locust" :
            endStation = 10
        case "12/13th & Locust" :
            endStation = 11
        case "15/16th & Locust" :
            endStation = 12
        default :
            print("default case")
        }
        
    } // end of stationDirection()
    
    
    
    
    func getStartAndEndStationTimes() {
        
        //get current date
        //let date = Date()
        //let weekday = Calendar.current.component(.weekday, from: date)
        
        
        //Finding station and direction of train
        if startStation < endStation {
            //West ===============================================================
            switch startStation {
            case 0  :
                print("Lindenwold West")
                if weekday == 7 { //Saturday
                    startStationHour = [0,0,1,2,3,3,4,5,5,6,6,7,7,7,7,8,8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15,16,16,16,16,17,17,17,17,18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,21,22,22,22,22,23,23,23]
                    startStationMinute = [9,45,30,15,0,45,30,0,30,0,30,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0,0,1,2,3,3,4,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15,16,16,16,17,17,17,18,18,18,19,19,19,20,20,20,21,21,21,22,22,22,23,23]
                    startStationMinute = [9,45,30,15,0,45,30,0,30,0,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30]
                } else { //Weekday
                    startStationHour = [0,0,1,2,3,3,4,5,5,5,5,5,6,6,6,6,6,6,7,7,7,7,7,7,7,7,7,99,7,99,8,99,8,99,8,99,8,8,8,8,9,9,9,9,9,10,10,10,10,10,11,11,11,11,11,12,12,12,12,12,13,13,13,13,13,14,14,14,14,14,15,15,15,15,15,15,16,16,16,16,16,16,17,17,17,17,17,18,18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,22,22,22,23,23,23]
                    startStationMinute = [9,45,30,15,0,45,30,0,15,30,45,55,8,20,30,40,50,58,3,8,12,17,22,27,32,40,48,99,57,99,4,99,12,99,20,99,29,38,47,55,3,12,24,36,48,0,12,24,36,48,0,12,24,36,48,0,12,24,36,48,0,12,24,36,48,0,12,24,36,48,0,10,20,30,39,51,5,12,24,33,45,55,6,19,31,44,50,2,12,22,38,48,0,15,30,45,0,15,30,45,0,20,40,0,20,40,0,20,40]
                }
            case 1  :
                print("Ashland West")
                if weekday == 7 { //Saturday
                    startStationHour = [0,0,1,2,3,3,4,5,5,6,6,7,7,7,7,8,8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15,16,16,16,16,17,17,17,17,18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,21,22,22,22,22,23,23,23]
                    startStationMinute = [11,47,32,17,2,47,32,2,32,2,32,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0,0,1,2,3,3,4,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15,16,16,16,17,17,17,18,18,18,19,19,19,20,20,20,21,21,21,22,22,22,23,23]
                    startStationMinute = [11,47,32,17,2,47,32,2,32,2,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32]
                } else { //Weekday
                    startStationHour = [0,0,1,2,3,3,4,5,5,5,5,5,6,6,6,6,6,7,7,7,7,7,7,7,7,7,7,99,7,99,8,99,8,99,8,99,8,8,8,8,9,9,9,9,9,10,10,10,10,10,11,11,11,11,11,12,12,12,12,12,13,13,13,13,13,14,14,14,14,14,15,15,15,15,15,15,16,16,16,16,16,16,17,17,17,17,17,18,18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,22,22,22,23,23,23]
                    startStationMinute = [11,47,32,17,2,47,32,2,17,32,47,57,10,22,32,42,52,0,5,10,14,19,24,29,34,42,50,99,59,99,6,99,14,99,22,99,31,40,49,57,5,14,26,38,50,2,14,26,38,50,2,14,26,38,50,2,14,26,38,50,2,14,26,38,50,2,14,26,38,50,2,12,22,32,41,53,7,14,26,35,47,57,8,21,33,46,52,4,14,24,40,50,2,17,32,47,2,17,32,47,2,22,42,2,22,42,2,22,42]
                }
            case 2  :
                print("Woodcrest West")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [12, 48, 33, 18, 3, 48, 33, 3, 33, 3, 33, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23]
                    startStationMinute = [12, 48, 33, 18, 3, 48, 33, 3, 33, 3, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33]
                } else { //Weekday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [12, 48, 33, 18, 3, 48, 33, 3, 18, 33, 48, 58, 11, 23, 33, 43, 53, 1, 6, 11, 15, 20, 25, 30, 35, 43, 51, 55, 0, 3, 7, 11, 15, 18, 23, 27, 32, 41, 50, 58, 6, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 13, 23, 33, 42, 54, 8, 15, 27, 36, 48, 58, 9, 22, 34, 47, 53, 5, 15, 25, 41, 51, 3, 18, 33, 48, 3, 18, 33, 48, 3, 23, 43, 3, 23, 43, 3, 23, 43]
                }
            case 3  :
                print("Haddonfield West")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [15, 51, 36, 21, 6, 51, 36, 6, 36, 6, 36, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23]
                    startStationMinute = [15, 51, 36, 21, 6, 51, 36, 6, 36, 6, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36]
                } else { //Weekday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 99, 7, 99, 8, 99, 8, 99, 8, 99, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [15, 51, 36, 21, 6, 51, 36, 6, 21, 36, 51, 1, 14, 26, 36, 46, 56, 4, 9, 14, 18, 23, 28, 33, 38, 46, 99, 58, 99, 6, 99, 14, 99, 21, 99, 30, 35, 44, 53, 1, 9, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 16, 26, 36, 45, 57, 11, 18, 30, 39, 51, 1, 12, 25, 37, 50, 56, 8, 18, 28, 44, 54, 6, 21, 36, 51, 6, 21, 36, 51, 6, 26, 46, 6, 26, 46, 6, 26, 46]
                }
            case 4  :
                print("Westmont West")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [17, 53, 38, 23, 8, 53, 38, 8, 38, 8, 38, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23]
                    startStationMinute = [17, 53, 38, 23, 8, 53, 38, 8, 38, 8, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38]
                } else { //Weekday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 99, 8, 99, 8, 99, 8, 99, 8, 99, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [17, 53, 38, 23, 8, 53, 38, 8, 23, 38, 53, 3, 16, 28, 38, 48, 58, 6, 11, 16, 20, 25, 30, 35, 40, 48, 99, 0, 99, 8, 99, 16, 99, 23, 99, 32, 37, 46, 55, 3, 11, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 18, 28, 38, 47, 59, 13, 20, 32, 41, 53, 3, 14, 27, 39, 52, 58, 10, 20, 30, 46, 56, 8, 23, 38, 53, 8, 23, 38, 53, 8, 28, 48, 8, 28, 48, 8, 28, 48]
                }
            case 5  :
                print("Collingswood West")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [19, 55, 40, 25, 10, 55, 40, 10, 40, 10, 40, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40]

                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [19, 55, 40, 25, 10, 55, 40, 10, 40, 10, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40]
                } else { //Weekday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 99, 8, 99, 8, 99, 8, 99, 8, 99, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [19, 55, 40, 25, 10, 55, 40, 10, 25, 40, 55, 5, 18, 30, 40, 50, 0, 8, 13, 18, 22, 27, 32, 37, 42, 50, 99, 2, 99, 10, 99, 18, 99, 25, 99, 34, 39, 48, 57, 5, 13, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 20, 30, 40, 49, 1, 15, 22, 34, 43, 55, 5, 16, 29, 41, 54, 0, 12, 22, 32, 48, 58, 10, 25, 40, 55, 10, 25, 40, 55, 10, 30, 50, 10, 30, 50, 10, 30, 50]
                }
            case 6  :
                print("Ferry Avenue West")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [21, 57, 42, 27, 12, 57, 42, 12, 42, 12, 42, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [21, 57, 42, 27, 12, 57, 42, 12, 42, 12, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42]
                } else { //Weekday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [21, 57, 42, 27, 12, 57, 42, 12, 27, 42, 57, 7, 20, 32, 42, 52, 2, 10, 15, 20, 24, 29, 34, 39, 44, 52, 58, 4, 7, 12, 14, 20, 22, 27, 30, 36, 41, 50, 59, 7, 15, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 22, 32, 42, 51, 3, 17, 24, 36, 45, 57, 7, 18, 31, 43, 56, 2, 14, 24, 34, 50, 0, 12, 27, 42, 57, 12, 27, 42, 57, 12, 32, 52, 12, 32, 52, 12, 32, 52]
                }
            case 7  :
                print("Broadway West")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    startStationMinute = [25, 1, 46, 31, 16, 1, 46, 16, 46, 16, 46, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [25, 1, 46, 31, 16, 1, 46, 16, 46, 16, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46]
                } else { //Weekday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [25, 1, 46, 31, 16, 1, 46, 16, 31, 46, 1, 11, 24, 36, 46, 56, 6, 14, 19, 24, 28, 33, 38, 43, 48, 56, 2, 8, 11, 16, 18, 24, 26, 31, 34, 40, 45, 54, 3, 11, 19, 28, 40, 52, 4, 16, 28, 40, 52, 4, 16, 28, 40, 52, 4, 16, 28, 40, 52, 4, 16, 28, 40, 52, 4, 16, 28, 40, 52, 4, 16, 26, 36, 46, 55, 7, 21, 28, 40, 49, 1, 11, 22, 35, 47, 0, 6, 18, 28, 38, 54, 4, 16, 31, 46, 1, 16, 31, 46, 1, 16, 36, 56, 16, 36, 56, 16, 36, 56]
                }
            case 8  :
                print("City Hall West")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    startStationMinute = [27, 3, 48, 33, 18, 3, 48, 18, 48, 18, 48, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [27, 3, 48, 33, 18, 3, 48, 18, 48, 18, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48]
                } else { //Weekday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [27, 3, 48, 33, 18, 3, 48, 18, 33, 48, 3, 13, 26, 38, 48, 58, 8, 16, 21, 26, 30, 35, 40, 45, 50, 58, 4, 10, 13, 18, 20, 26, 28, 33, 36, 42, 47, 56, 5, 13, 21, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 28, 38, 48, 57, 9, 23, 30, 42, 51, 3, 13, 24, 37, 49, 2, 8, 20, 30, 40, 56, 6, 18, 33, 48, 3, 18, 33, 48, 3, 18, 38, 58, 18, 38, 58, 18, 38, 58]
                }
            case 9  :
                print("8th & Market West")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    startStationMinute = [32, 8, 53, 38, 23, 8, 53, 23, 53, 23, 53, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [32, 8, 53, 38, 23, 8, 53, 23, 53, 23, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53]
                } else { //Weekday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [32, 8, 53, 38, 23, 8, 53, 23, 38, 53, 8, 18, 32, 44, 54, 4, 14, 22, 27, 32, 36, 41, 46, 51, 56, 4, 10, 15, 19, 23, 26, 31, 34, 38, 42, 47, 53, 2, 11, 18, 26, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 33, 43, 53, 2, 14, 28, 35, 47, 56, 8, 18, 29, 42, 54, 7, 13, 25, 35, 45, 1, 11, 23, 38, 53, 8, 23, 38, 53, 8, 23, 43, 3, 23, 43, 3, 23, 43, 3]
                }
            case 10  :
                print("9/10th & Locust West")
                if weekday == 7 { //Saturday
                    startStationHour = [99, 99, 99, 99, 99, 99, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    startStationMinute = [99, 99, 99, 99, 99, 99, 55, 25, 55, 25, 55, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55]
                } else if weekday == 1 { //Sunday
                    startStationHour = [99, 99, 99, 99, 99, 99, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [99, 99, 99, 99, 99, 99, 55, 25, 55, 25, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55]
                } else { //Weekday
                    startStationHour = [99, 99, 99, 99, 99, 99, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [99, 99, 99, 99, 99, 99, 55, 25, 40, 55, 10, 20, 34, 46, 56, 6, 16, 24, 29, 34, 38, 43, 48, 53, 58, 6, 12, 17, 21, 25, 28, 33, 36, 40, 44, 49, 55, 4, 13, 20, 28, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 35, 45, 55, 4, 16, 30, 37, 49, 58, 10, 20, 31, 44, 56, 9, 15, 27, 37, 47, 3, 13, 25, 40, 55, 10, 25, 40, 55, 10, 25, 45, 5, 25, 45, 5, 25, 45, 5]
                }
            case 11  :
                print("12/13th & Locust West")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    startStationMinute = [35, 11, 56, 41, 26, 11, 56, 26, 56, 26, 56, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56]

                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [35, 11, 56, 41, 26, 11, 56, 26, 56, 26, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56]
                } else { //Weekday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [35, 11, 56, 41, 26, 11, 56, 26, 41, 56, 11, 21, 35, 47, 57, 7, 17, 25, 30, 35, 39, 44, 49, 54, 59, 7, 13, 18, 22, 26, 29, 34, 37, 41, 45, 50, 56, 5, 14, 21, 29, 38, 50, 2, 14, 26, 38, 50, 2, 14, 26, 38, 50, 2, 14, 26, 38, 50, 2, 14, 26, 38, 50, 2, 14, 26, 38, 50, 2, 14, 26, 36, 46, 56, 5, 17, 31, 38, 50, 59, 11, 21, 32, 45, 57, 10, 16, 28, 38, 48, 4, 14, 26, 41, 56, 11, 26, 41, 56, 11, 26, 46, 6, 26, 46, 6, 26, 46, 6]
                }
            case 12  :
                print("15/16th & Locust West")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    startStationMinute = [36, 12, 57, 42, 27, 12, 57, 27, 57, 27, 57, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [36, 12, 57, 42, 27, 12, 57, 27, 57, 27, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57]
                } else { //Weekday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [36, 12, 57, 42, 27, 12, 57, 27, 42, 57, 12, 22, 36, 48, 58, 8, 18, 26, 31, 36, 40, 45, 50, 55, 0, 8, 14, 19, 23, 27, 30, 35, 38, 42, 46, 51, 57, 6, 15, 22, 30, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 37, 47, 57, 6, 18, 32, 39, 51, 0, 12, 22, 33, 46, 58, 11, 17, 29, 39, 49, 5, 15, 27, 42, 57, 12, 27, 42, 57, 12, 27, 47, 7, 27, 47, 7, 27, 47, 7]
                }
            default :
                print( "default case")
            }
            // ===============================================================
            switch endStation {
            case 0  :
                print("Lindenwold West")
                if weekday == 7 { //Saturday
                    endStationHour = [0,0,1,2,3,3,4,5,5,6,6,7,7,7,7,8,8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15,16,16,16,16,17,17,17,17,18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,21,22,22,22,22,23,23,23]
                    endStationMinute = [9,45,30,15,0,45,30,0,30,0,30,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30,45,0,15,30]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0,0,1,2,3,3,4,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15,16,16,16,17,17,17,18,18,18,19,19,19,20,20,20,21,21,21,22,22,22,23,23]
                    endStationMinute = [9,45,30,15,0,45,30,0,30,0,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30,50,10,30]
                } else { //Weekday
                    endStationHour = [0,0,1,2,3,3,4,5,5,5,5,5,6,6,6,6,6,6,7,7,7,7,7,7,7,7,7,99,7,99,8,99,8,99,8,99,8,8,8,8,9,9,9,9,9,10,10,10,10,10,11,11,11,11,11,12,12,12,12,12,13,13,13,13,13,14,14,14,14,14,15,15,15,15,15,15,16,16,16,16,16,16,17,17,17,17,17,18,18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,22,22,22,23,23,23]
                    endStationMinute = [9,45,30,15,0,45,30,0,15,30,45,55,8,20,30,40,50,58,3,8,12,17,22,27,32,40,48,99,57,99,4,99,12,99,20,99,29,38,47,55,3,12,24,36,48,0,12,24,36,48,0,12,24,36,48,0,12,24,36,48,0,12,24,36,48,0,12,24,36,48,0,10,20,30,39,51,5,12,24,33,45,55,6,19,31,44,50,2,12,22,38,48,0,15,30,45,0,15,30,45,0,20,40,0,20,40,0,20,40]
                }
            case 1  :
                print("Ashland West")
                if weekday == 7 { //Saturday
                    endStationHour = [0,0,1,2,3,3,4,5,5,6,6,7,7,7,7,8,8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15,16,16,16,16,17,17,17,17,18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,21,22,22,22,22,23,23,23]
                    endStationMinute = [11,47,32,17,2,47,32,2,32,2,32,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32,47,2,17,32]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0,0,1,2,3,3,4,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15,16,16,16,17,17,17,18,18,18,19,19,19,20,20,20,21,21,21,22,22,22,23,23]
                    endStationMinute = [11,47,32,17,2,47,32,2,32,2,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32,52,12,32]
                } else { //Weekday
                    endStationHour = [0,0,1,2,3,3,4,5,5,5,5,5,6,6,6,6,6,7,7,7,7,7,7,7,7,7,7,99,7,99,8,99,8,99,8,99,8,8,8,8,9,9,9,9,9,10,10,10,10,10,11,11,11,11,11,12,12,12,12,12,13,13,13,13,13,14,14,14,14,14,15,15,15,15,15,15,16,16,16,16,16,16,17,17,17,17,17,18,18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,22,22,22,23,23,23]
                    endStationMinute = [11,47,32,17,2,47,32,2,17,32,47,57,10,22,32,42,52,0,5,10,14,19,24,29,34,42,50,99,59,99,6,99,14,99,22,99,31,40,49,57,5,14,26,38,50,2,14,26,38,50,2,14,26,38,50,2,14,26,38,50,2,14,26,38,50,2,14,26,38,50,2,12,22,32,41,53,7,14,26,35,47,57,8,21,33,46,52,4,14,24,40,50,2,17,32,47,2,17,32,47,2,22,42,2,22,42,2,22,42]
                }
            case 2  :
                print("Woodcrest West")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [12, 48, 33, 18, 3, 48, 33, 3, 33, 3, 33, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23]
                    endStationMinute = [12, 48, 33, 18, 3, 48, 33, 3, 33, 3, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33]
                } else { //Weekday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [12, 48, 33, 18, 3, 48, 33, 3, 18, 33, 48, 58, 11, 23, 33, 43, 53, 1, 6, 11, 15, 20, 25, 30, 35, 43, 51, 55, 0, 3, 7, 11, 15, 18, 23, 27, 32, 41, 50, 58, 6, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 13, 23, 33, 42, 54, 8, 15, 27, 36, 48, 58, 9, 22, 34, 47, 53, 5, 15, 25, 41, 51, 3, 18, 33, 48, 3, 18, 33, 48, 3, 23, 43, 3, 23, 43, 3, 23, 43]
                }
            case 3  :
                print("Haddonfield West")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [15, 51, 36, 21, 6, 51, 36, 6, 36, 6, 36, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23]
                    endStationMinute = [15, 51, 36, 21, 6, 51, 36, 6, 36, 6, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36]
                } else { //Weekday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 99, 7, 99, 8, 99, 8, 99, 8, 99, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [15, 51, 36, 21, 6, 51, 36, 6, 21, 36, 51, 1, 14, 26, 36, 46, 56, 4, 9, 14, 18, 23, 28, 33, 38, 46, 99, 58, 99, 6, 99, 14, 99, 21, 99, 30, 35, 44, 53, 1, 9, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 16, 26, 36, 45, 57, 11, 18, 30, 39, 51, 1, 12, 25, 37, 50, 56, 8, 18, 28, 44, 54, 6, 21, 36, 51, 6, 21, 36, 51, 6, 26, 46, 6, 26, 46, 6, 26, 46]
                }
            case 4  :
                print("Westmont West")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [17, 53, 38, 23, 8, 53, 38, 8, 38, 8, 38, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23]
                    endStationMinute = [17, 53, 38, 23, 8, 53, 38, 8, 38, 8, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38, 58, 18, 38]
                } else { //Weekday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 99, 8, 99, 8, 99, 8, 99, 8, 99, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [17, 53, 38, 23, 8, 53, 38, 8, 23, 38, 53, 3, 16, 28, 38, 48, 58, 6, 11, 16, 20, 25, 30, 35, 40, 48, 99, 0, 99, 8, 99, 16, 99, 23, 99, 32, 37, 46, 55, 3, 11, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 18, 28, 38, 47, 59, 13, 20, 32, 41, 53, 3, 14, 27, 39, 52, 58, 10, 20, 30, 46, 56, 8, 23, 38, 53, 8, 23, 38, 53, 8, 28, 48, 8, 28, 48, 8, 28, 48]
                }
            case 5  :
                print("Collingswood West")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [19, 55, 40, 25, 10, 55, 40, 10, 40, 10, 40, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40]
                    
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [19, 55, 40, 25, 10, 55, 40, 10, 40, 10, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40, 0, 20, 40]
                } else { //Weekday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 99, 8, 99, 8, 99, 8, 99, 8, 99, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [19, 55, 40, 25, 10, 55, 40, 10, 25, 40, 55, 5, 18, 30, 40, 50, 0, 8, 13, 18, 22, 27, 32, 37, 42, 50, 99, 2, 99, 10, 99, 18, 99, 25, 99, 34, 39, 48, 57, 5, 13, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 20, 30, 40, 49, 1, 15, 22, 34, 43, 55, 5, 16, 29, 41, 54, 0, 12, 22, 32, 48, 58, 10, 25, 40, 55, 10, 25, 40, 55, 10, 30, 50, 10, 30, 50, 10, 30, 50]
                }
            case 6  :
                print("Ferry Avenue West")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [21, 57, 42, 27, 12, 57, 42, 12, 42, 12, 42, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [21, 57, 42, 27, 12, 57, 42, 12, 42, 12, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42, 2, 22, 42]
                } else { //Weekday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [21, 57, 42, 27, 12, 57, 42, 12, 27, 42, 57, 7, 20, 32, 42, 52, 2, 10, 15, 20, 24, 29, 34, 39, 44, 52, 58, 4, 7, 12, 14, 20, 22, 27, 30, 36, 41, 50, 59, 7, 15, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 22, 32, 42, 51, 3, 17, 24, 36, 45, 57, 7, 18, 31, 43, 56, 2, 14, 24, 34, 50, 0, 12, 27, 42, 57, 12, 27, 42, 57, 12, 32, 52, 12, 32, 52, 12, 32, 52]
                }
            case 7  :
                print("Broadway West")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    endStationMinute = [25, 1, 46, 31, 16, 1, 46, 16, 46, 16, 46, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [25, 1, 46, 31, 16, 1, 46, 16, 46, 16, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46]
                } else { //Weekday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [25, 1, 46, 31, 16, 1, 46, 16, 31, 46, 1, 11, 24, 36, 46, 56, 6, 14, 19, 24, 28, 33, 38, 43, 48, 56, 2, 8, 11, 16, 18, 24, 26, 31, 34, 40, 45, 54, 3, 11, 19, 28, 40, 52, 4, 16, 28, 40, 52, 4, 16, 28, 40, 52, 4, 16, 28, 40, 52, 4, 16, 28, 40, 52, 4, 16, 28, 40, 52, 4, 16, 26, 36, 46, 55, 7, 21, 28, 40, 49, 1, 11, 22, 35, 47, 0, 6, 18, 28, 38, 54, 4, 16, 31, 46, 1, 16, 31, 46, 1, 16, 36, 56, 16, 36, 56, 16, 36, 56]
                }
            case 8  :
                print("City Hall West")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    endStationMinute = [27, 3, 48, 33, 18, 3, 48, 18, 48, 18, 48, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [27, 3, 48, 33, 18, 3, 48, 18, 48, 18, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48]
                } else { //Weekday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [27, 3, 48, 33, 18, 3, 48, 18, 33, 48, 3, 13, 26, 38, 48, 58, 8, 16, 21, 26, 30, 35, 40, 45, 50, 58, 4, 10, 13, 18, 20, 26, 28, 33, 36, 42, 47, 56, 5, 13, 21, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 28, 38, 48, 57, 9, 23, 30, 42, 51, 3, 13, 24, 37, 49, 2, 8, 20, 30, 40, 56, 6, 18, 33, 48, 3, 18, 33, 48, 3, 18, 38, 58, 18, 38, 58, 18, 38, 58]
                }
            case 9  :
                print("8th & Market West")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    endStationMinute = [32, 8, 53, 38, 23, 8, 53, 23, 53, 23, 53, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [32, 8, 53, 38, 23, 8, 53, 23, 53, 23, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53]
                } else { //Weekday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [32, 8, 53, 38, 23, 8, 53, 23, 38, 53, 8, 18, 32, 44, 54, 4, 14, 22, 27, 32, 36, 41, 46, 51, 56, 4, 10, 15, 19, 23, 26, 31, 34, 38, 42, 47, 53, 2, 11, 18, 26, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 33, 43, 53, 2, 14, 28, 35, 47, 56, 8, 18, 29, 42, 54, 7, 13, 25, 35, 45, 1, 11, 23, 38, 53, 8, 23, 38, 53, 8, 23, 43, 3, 23, 43, 3, 23, 43, 3]
                }
            case 10  :
                print("9/10th & Locust West")
                if weekday == 7 { //Saturday
                    endStationHour = [99, 99, 99, 99, 99, 99, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    endStationMinute = [99, 99, 99, 99, 99, 99, 55, 25, 55, 25, 55, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55]
                } else if weekday == 1 { //Sunday
                    endStationHour = [99, 99, 99, 99, 99, 99, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [99, 99, 99, 99, 99, 99, 55, 25, 55, 25, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55]
                } else { //Weekday
                    endStationHour = [99, 99, 99, 99, 99, 99, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [99, 99, 99, 99, 99, 99, 55, 25, 40, 55, 10, 20, 34, 46, 56, 6, 16, 24, 29, 34, 38, 43, 48, 53, 58, 6, 12, 17, 21, 25, 28, 33, 36, 40, 44, 49, 55, 4, 13, 20, 28, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 35, 45, 55, 4, 16, 30, 37, 49, 58, 10, 20, 31, 44, 56, 9, 15, 27, 37, 47, 3, 13, 25, 40, 55, 10, 25, 40, 55, 10, 25, 45, 5, 25, 45, 5, 25, 45, 5]
                }
            case 11  :
                print("12/13th & Locust West")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    endStationMinute = [35, 11, 56, 41, 26, 11, 56, 26, 56, 26, 56, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56, 11, 26, 41, 56]
                    
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [35, 11, 56, 41, 26, 11, 56, 26, 56, 26, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56]
                } else { //Weekday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [35, 11, 56, 41, 26, 11, 56, 26, 41, 56, 11, 21, 35, 47, 57, 7, 17, 25, 30, 35, 39, 44, 49, 54, 59, 7, 13, 18, 22, 26, 29, 34, 37, 41, 45, 50, 56, 5, 14, 21, 29, 38, 50, 2, 14, 26, 38, 50, 2, 14, 26, 38, 50, 2, 14, 26, 38, 50, 2, 14, 26, 38, 50, 2, 14, 26, 38, 50, 2, 14, 26, 36, 46, 56, 5, 17, 31, 38, 50, 59, 11, 21, 32, 45, 57, 10, 16, 28, 38, 48, 4, 14, 26, 41, 56, 11, 26, 41, 56, 11, 26, 46, 6, 26, 46, 6, 26, 46, 6]
                }
            case 12  :
                print("15/16th & Locust West")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    endStationMinute = [36, 12, 57, 42, 27, 12, 57, 27, 57, 27, 57, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57, 12, 27, 42, 57]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [36, 12, 57, 42, 27, 12, 57, 27, 57, 27, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57, 17, 37, 57]
                } else { //Weekday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [36, 12, 57, 42, 27, 12, 57, 27, 42, 57, 12, 22, 36, 48, 58, 8, 18, 26, 31, 36, 40, 45, 50, 55, 0, 8, 14, 19, 23, 27, 30, 35, 38, 42, 46, 51, 57, 6, 15, 22, 30, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 37, 47, 57, 6, 18, 32, 39, 51, 0, 12, 22, 33, 46, 58, 11, 17, 29, 39, 49, 5, 15, 27, 42, 57, 12, 27, 42, 57, 12, 27, 47, 7, 27, 47, 7, 27, 47, 7]
                }
            default :
                print( "default case")
            }
            
        } else {
            
//East ===============================================================
            switch startStation {
            case 0  :
                print("Lindenwold East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24, 24]
                    startStationMinute = [38, 10, 55, 40, 25, 10, 55, 32, 2, 32, 2, 32, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [38, 10, 55, 40, 25, 10, 55, 32, 3, 33, 3, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13]

                } else { //Weekday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24, 24]
                    startStationMinute = [38, 10, 55, 40, 25, 10, 55, 42, 59, 14, 29, 44, 57, 8, 20, 28, 38, 48, 2, 15, 25, 44, 49, 0, 8, 21, 36, 52, 0, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 36, 48, 58, 8, 18, 28, 37, 42, 49, 55, 3, 10, 15, 22, 27, 31, 35, 39, 43, 48, 53, 58, 4, 10, 17, 23, 29, 36, 45, 50, 2, 12, 21, 36, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 23, 43, 3, 23, 43, 3, 23]
                }
            case 1  :
                print("Ashland East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24, 24]
                    startStationMinute = [35, 7, 52, 37, 22, 7, 52, 29, 59, 29, 59, 29, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [35, 7, 52, 37, 22, 7, 52, 29, 0, 30, 0, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10]
                } else { //Weekday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24, 24]
                    startStationMinute = [35, 7, 52, 37, 22, 7, 52, 39, 56, 11, 26, 41, 54, 5, 17, 25, 35, 45, 59, 12, 22, 41, 46, 57, 5, 18, 33, 49, 57, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 33, 45, 55, 5, 15, 25, 34, 39, 46, 52, 0, 7, 12, 19, 24, 28, 32, 36, 40, 45, 50, 55, 1, 7, 14, 20, 26, 33, 42, 47, 59, 9, 18, 33, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 20, 40, 0, 20, 40, 0, 20]
                }
            case 2  :
                print("Woodcrest East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    startStationMinute = [33, 5, 50, 35, 20, 5, 50, 27, 57, 27, 57, 27, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [33, 5, 50, 35, 20, 5, 50, 27, 58, 28, 58, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8]
                } else { //Weekday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [33, 5, 50, 35, 20, 5, 50, 37, 54, 9, 24, 39, 52, 3, 15, 23, 33, 43, 57, 10, 20, 39, 44, 55, 3, 16, 31, 47, 55, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 31, 43, 53, 3, 13, 23, 32, 37, 44, 50, 58, 5, 10, 17, 22, 26, 30, 34, 38, 43, 48, 53, 59, 5, 12, 18, 24, 31, 40, 45, 57, 7, 16, 31, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 18, 38, 58, 18, 38, 58, 18]
                }
            case 3  :
                print("Haddonfield East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    startStationMinute = [30, 2, 47, 32, 17, 2, 47, 24, 54, 24, 54, 24, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [30, 2, 47, 32, 17, 2, 47, 24, 55, 25, 55, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5]
                } else { //Weekday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [30, 2, 47, 32, 17, 2, 47, 34, 51, 6, 21, 36, 49, 0, 12, 20, 30, 40, 54, 7, 17, 36, 41, 52, 0, 13, 28, 44, 52, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 49, 59, 9, 19, 28, 33, 40, 46, 54, 1, 6, 13, 18, 22, 26, 30, 34, 39, 44, 49, 55, 1, 8, 14, 20, 27, 36, 41, 53, 3, 13, 28, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 15, 35, 55, 15, 35, 55, 15]
                }
            case 4  :
                print("Westmont East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    startStationMinute = [28, 0, 45, 30, 15, 0, 45, 22, 52, 22, 52, 22, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [28, 0, 45, 30, 15, 0, 45, 22, 53, 23, 53, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3]
                } else { //Weekday
                    startStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [28, 0, 45, 30, 15, 0, 45, 32, 49, 4, 19, 34, 47, 58, 10, 18, 28, 38, 52, 5, 15, 34, 39, 50, 58, 11, 26, 42, 50, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 47, 57, 7, 17, 26, 31, 38, 44, 52, 59, 4, 11, 16, 20, 24, 28, 32, 37, 42, 47, 53, 59, 6, 12, 18, 25, 34, 39, 51, 1, 11, 26, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 13, 33, 53, 13, 33, 53, 13]
                }
            case 5  :
                print("Collingswood East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    startStationMinute = [26, 58, 43, 28, 13, 58, 43, 20, 50, 20, 50, 20, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [26, 58, 43, 28, 13, 58, 43, 20, 51, 21, 51, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1]
                } else { //Weekday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [26, 58, 43, 28, 13, 58, 43, 30, 47, 2, 17, 32, 45, 56, 8, 16, 26, 36, 50, 3, 13, 32, 37, 48, 56, 9, 24, 40, 48, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 45, 55, 5, 15, 24, 29, 36, 42, 50, 57, 2, 9, 14, 18, 22, 26, 30, 35, 40, 45, 51, 57, 4, 10, 16, 23, 32, 37, 49, 59, 9, 24, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 11, 31, 51, 11, 31, 51, 11]
                }
            case 6  :
                print("Ferry Avenue East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    startStationMinute = [24, 56, 41, 26, 11, 56, 41, 18, 48, 18, 48, 18, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [24, 56, 41, 26, 11, 56, 41, 18, 49, 19, 49, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59]
                } else { //Weekday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [24, 56, 41, 26, 11, 56, 41, 28, 45, 0, 15, 30, 43, 54, 6, 14, 24, 34, 48, 1, 11, 30, 35, 46, 54, 7, 22, 38, 46, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 43, 53, 3, 13, 22, 27, 34, 40, 48, 55, 0, 7, 12, 16, 20, 24, 28, 33, 38, 43, 49, 55, 2, 8, 14, 21, 30, 35, 47, 57, 7, 22, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 9, 29, 49, 9, 29, 49, 9]
                }
            case 7  :
                print("Broadway East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    startStationMinute = [21, 53, 38, 23, 8, 53, 38, 15, 45, 15, 45, 15, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [21, 53, 38, 23, 8, 53, 38, 15, 46, 16, 46, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56]

                } else { //Weekday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [21, 53, 38, 23, 8, 53, 38, 25, 42, 57, 12, 27, 40, 51, 3, 11, 21, 31, 45, 58, 8, 27, 32, 43, 51, 4, 19, 35, 43, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 40, 50, 0, 10, 19, 24, 31, 37, 45, 52, 57, 4, 9, 13, 17, 21, 25, 30, 35, 40, 46, 52, 59, 5, 11, 18, 27, 32, 44, 54, 4, 19, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 6, 26, 46, 6, 26, 46, 6]
                }
            case 8  :
                print("City Hall East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    startStationMinute = [20, 52, 37, 22, 7, 52, 37, 14, 44, 14, 44, 14, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [20, 52, 37, 22, 7, 52, 37, 14, 45, 15, 45, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55]
                } else { //Weekday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [20, 52, 37, 22, 7, 52, 37, 24, 41, 56, 11, 26, 39, 50, 2, 10, 20, 30, 44, 57, 7, 26, 31, 42, 50, 3, 18, 34, 42, 53, 5, 17, 29, 41, 53, 5, 17, 29, 41, 53, 5, 17, 29, 41, 53, 5, 17, 29, 41, 53, 5, 17, 29, 41, 53, 5, 17, 29, 39, 49, 59, 9, 18, 23, 30, 36, 44, 51, 56, 3, 8, 12, 16, 20, 24, 29, 34, 39, 45, 51, 58, 4, 10, 17, 26, 31, 43, 53, 3, 18, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 5, 25, 45, 5, 25, 45, 5]
                }
            case 9  :
                print("8th & Market East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    startStationMinute = [15, 47, 32, 17, 2, 47, 32, 9, 39, 9, 39, 9, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [15, 47, 32, 17, 2, 47, 32, 9, 40, 10, 40, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50]
                } else { //Weekday
                    startStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    startStationMinute = [15, 47, 32, 17, 2, 47, 32, 19, 36, 51, 6, 21, 34, 45, 57, 5, 15, 25, 39, 52, 2, 21, 26, 37, 45, 58, 13, 29, 37, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 34, 44, 54, 4, 13, 18, 25, 31, 39, 46, 51, 58, 3, 7, 11, 15, 19, 24, 29, 34, 40, 46, 53, 59, 5, 12, 21, 26, 38, 48, 58, 13, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 0, 20, 40, 0, 20, 40, 0]
                }
            case 10  :
                print("9/10th & Locust East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 99, 99, 99, 99, 99, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    startStationMinute = [13, 99, 99, 99, 99, 99, 30, 7, 37, 7, 37, 7, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 99, 99, 99, 99, 99, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [13, 99, 99, 99, 99, 99, 30, 7, 38, 8, 38, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48]
                } else { //Weekday
                    startStationHour = [0, 99, 99, 99, 99, 99, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [13, 99, 99, 99, 99, 99, 30, 17, 34, 49, 4, 19, 32, 43, 55, 3, 13, 23, 37, 50, 0, 19, 24, 35, 43, 56, 11, 27, 35, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 32, 42, 52, 2, 11, 16, 23, 29, 37, 44, 49, 56, 1, 5, 9, 13, 17, 22, 27, 32, 38, 44, 51, 57, 3, 10, 19, 24, 36, 46, 56, 11, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 58, 18, 38, 58, 18, 38, 58]
                }
            case 11  :
                print("12/13th & Locust East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 0, 1, 2, 2, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    startStationMinute = [12, 44, 29, 14, 59, 44, 29, 6, 36, 6, 36, 6, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 0, 1, 2, 2, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [12, 44, 29, 14, 59, 44, 29, 6, 37, 7, 37, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47]
                } else { //Weekday
                    startStationHour = [0, 0, 1, 2, 2, 3, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [12, 44, 29, 14, 59, 44, 29, 16, 33, 48, 3, 18, 31, 42, 54, 2, 12, 22, 36, 49, 59, 18, 23, 34, 42, 55, 10, 26, 34, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 31, 41, 51, 1, 10, 15, 22, 28, 36, 43, 48, 55, 0, 4, 8, 12, 16, 21, 26, 31, 37, 43, 50, 56, 2, 9, 18, 23, 35, 45, 55, 10, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 57, 17, 37, 57, 17, 37, 57]
                }
            case 12  :
                print("15/16th & Locust East")
                if weekday == 7 { //Saturday
                    startStationHour = [0, 0, 1, 2, 2, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    startStationMinute = [11, 43, 28, 13, 58, 43, 28, 5, 35, 5, 35, 5, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51]
                } else if weekday == 1 { //Sunday
                    startStationHour = [0, 0, 1, 2, 2, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [11, 43, 28, 13, 58, 43, 28, 5, 36, 6, 36, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46]
                } else { //Weekday
                    startStationHour = [0, 0, 1, 2, 2, 3, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    startStationMinute = [11, 43, 28, 13, 58, 43, 28, 15, 32, 47, 2, 17, 30, 41, 53, 1, 11, 21, 35, 48, 58, 17, 22, 33, 41, 54, 9, 25, 33, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 30, 40, 50, 0, 9, 14, 21, 27, 35, 42, 47, 54, 59, 3, 7, 11, 15, 20, 25, 30, 36, 42, 49, 55, 1, 8, 17, 22, 34, 44, 54, 9, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 56, 16, 36, 56, 16, 36, 56]
                }
            default :
                print( "default case")
            }
            // ====================================================================================
            switch endStation {
            case 0  :
                print("Lindenwold East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24, 24]
                    endStationMinute = [38, 10, 55, 40, 25, 10, 55, 32, 2, 32, 2, 32, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 18]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [38, 10, 55, 40, 25, 10, 55, 32, 3, 33, 3, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13, 33, 53, 13]
                    
                } else { //Weekday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24, 24]
                    endStationMinute = [38, 10, 55, 40, 25, 10, 55, 42, 59, 14, 29, 44, 57, 8, 20, 28, 38, 48, 2, 15, 25, 44, 49, 0, 8, 21, 36, 52, 0, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 36, 48, 58, 8, 18, 28, 37, 42, 49, 55, 3, 10, 15, 22, 27, 31, 35, 39, 43, 48, 53, 58, 4, 10, 17, 23, 29, 36, 45, 50, 2, 12, 21, 36, 48, 3, 18, 33, 48, 3, 18, 33, 48, 3, 23, 43, 3, 23, 43, 3, 23]
                }
            case 1  :
                print("Ashland East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24, 24]
                    endStationMinute = [35, 7, 52, 37, 22, 7, 52, 29, 59, 29, 59, 29, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [35, 7, 52, 37, 22, 7, 52, 29, 0, 30, 0, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10]
                } else { //Weekday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24, 24]
                    endStationMinute = [35, 7, 52, 37, 22, 7, 52, 39, 56, 11, 26, 41, 54, 5, 17, 25, 35, 45, 59, 12, 22, 41, 46, 57, 5, 18, 33, 49, 57, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 33, 45, 55, 5, 15, 25, 34, 39, 46, 52, 0, 7, 12, 19, 24, 28, 32, 36, 40, 45, 50, 55, 1, 7, 14, 20, 26, 33, 42, 47, 59, 9, 18, 33, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 20, 40, 0, 20, 40, 0, 20]
                }
            case 2  :
                print("Woodcrest East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    endStationMinute = [33, 5, 50, 35, 20, 5, 50, 27, 57, 27, 57, 27, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 13]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [33, 5, 50, 35, 20, 5, 50, 27, 58, 28, 58, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8]
                } else { //Weekday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [33, 5, 50, 35, 20, 5, 50, 37, 54, 9, 24, 39, 52, 3, 15, 23, 33, 43, 57, 10, 20, 39, 44, 55, 3, 16, 31, 47, 55, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 31, 43, 53, 3, 13, 23, 32, 37, 44, 50, 58, 5, 10, 17, 22, 26, 30, 34, 38, 43, 48, 53, 59, 5, 12, 18, 24, 31, 40, 45, 57, 7, 16, 31, 43, 58, 13, 28, 43, 58, 13, 28, 43, 58, 18, 38, 58, 18, 38, 58, 18]
                }
            case 3  :
                print("Haddonfield East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    endStationMinute = [30, 2, 47, 32, 17, 2, 47, 24, 54, 24, 54, 24, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [30, 2, 47, 32, 17, 2, 47, 24, 55, 25, 55, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5, 25, 45, 5]
                } else { //Weekday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [30, 2, 47, 32, 17, 2, 47, 34, 51, 6, 21, 36, 49, 0, 12, 20, 30, 40, 54, 7, 17, 36, 41, 52, 0, 13, 28, 44, 52, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 51, 3, 15, 27, 39, 49, 59, 9, 19, 28, 33, 40, 46, 54, 1, 6, 13, 18, 22, 26, 30, 34, 39, 44, 49, 55, 1, 8, 14, 20, 27, 36, 41, 53, 3, 13, 28, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 15, 35, 55, 15, 35, 55, 15]
                }
            case 4  :
                print("Westmont East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    endStationMinute = [28, 0, 45, 30, 15, 0, 45, 22, 52, 22, 52, 22, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [28, 0, 45, 30, 15, 0, 45, 22, 53, 23, 53, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3, 23, 43, 3]
                } else { //Weekday
                    endStationHour = [0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [28, 0, 45, 30, 15, 0, 45, 32, 49, 4, 19, 34, 47, 58, 10, 18, 28, 38, 52, 5, 15, 34, 39, 50, 58, 11, 26, 42, 50, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 49, 1, 13, 25, 37, 47, 57, 7, 17, 26, 31, 38, 44, 52, 59, 4, 11, 16, 20, 24, 28, 32, 37, 42, 47, 53, 59, 6, 12, 18, 25, 34, 39, 51, 1, 11, 26, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 13, 33, 53, 13, 33, 53, 13]
                }
            case 5  :
                print("Collingswood East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    endStationMinute = [26, 58, 43, 28, 13, 58, 43, 20, 50, 20, 50, 20, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [26, 58, 43, 28, 13, 58, 43, 20, 51, 21, 51, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1, 21, 41, 1]
                } else { //Weekday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [26, 58, 43, 28, 13, 58, 43, 30, 47, 2, 17, 32, 45, 56, 8, 16, 26, 36, 50, 3, 13, 32, 37, 48, 56, 9, 24, 40, 48, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 47, 59, 11, 23, 35, 45, 55, 5, 15, 24, 29, 36, 42, 50, 57, 2, 9, 14, 18, 22, 26, 30, 35, 40, 45, 51, 57, 4, 10, 16, 23, 32, 37, 49, 59, 9, 24, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 11, 31, 51, 11, 31, 51, 11]
                }
            case 6  :
                print("Ferry Avenue East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    endStationMinute = [24, 56, 41, 26, 11, 56, 41, 18, 48, 18, 48, 18, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 4]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [24, 56, 41, 26, 11, 56, 41, 18, 49, 19, 49, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59, 19, 39, 59]
                } else { //Weekday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [24, 56, 41, 26, 11, 56, 41, 28, 45, 0, 15, 30, 43, 54, 6, 14, 24, 34, 48, 1, 11, 30, 35, 46, 54, 7, 22, 38, 46, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 43, 53, 3, 13, 22, 27, 34, 40, 48, 55, 0, 7, 12, 16, 20, 24, 28, 33, 38, 43, 49, 55, 2, 8, 14, 21, 30, 35, 47, 57, 7, 22, 34, 49, 4, 19, 34, 49, 4, 19, 34, 49, 9, 29, 49, 9, 29, 49, 9]
                }
            case 7  :
                print("Broadway East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    endStationMinute = [21, 53, 38, 23, 8, 53, 38, 15, 45, 15, 45, 15, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 1]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [21, 53, 38, 23, 8, 53, 38, 15, 46, 16, 46, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56, 16, 36, 56]
                    
                } else { //Weekday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [21, 53, 38, 23, 8, 53, 38, 25, 42, 57, 12, 27, 40, 51, 3, 11, 21, 31, 45, 58, 8, 27, 32, 43, 51, 4, 19, 35, 43, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 42, 54, 6, 18, 30, 40, 50, 0, 10, 19, 24, 31, 37, 45, 52, 57, 4, 9, 13, 17, 21, 25, 30, 35, 40, 46, 52, 59, 5, 11, 18, 27, 32, 44, 54, 4, 19, 31, 46, 1, 16, 31, 46, 1, 16, 31, 46, 6, 26, 46, 6, 26, 46, 6]
                }
            case 8  :
                print("City Hall East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24]
                    endStationMinute = [20, 52, 37, 22, 7, 52, 37, 14, 44, 14, 44, 14, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 0]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [20, 52, 37, 22, 7, 52, 37, 14, 45, 15, 45, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55, 15, 35, 55]
                } else { //Weekday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [20, 52, 37, 22, 7, 52, 37, 24, 41, 56, 11, 26, 39, 50, 2, 10, 20, 30, 44, 57, 7, 26, 31, 42, 50, 3, 18, 34, 42, 53, 5, 17, 29, 41, 53, 5, 17, 29, 41, 53, 5, 17, 29, 41, 53, 5, 17, 29, 41, 53, 5, 17, 29, 41, 53, 5, 17, 29, 39, 49, 59, 9, 18, 23, 30, 36, 44, 51, 56, 3, 8, 12, 16, 20, 24, 29, 34, 39, 45, 51, 58, 4, 10, 17, 26, 31, 43, 53, 3, 18, 30, 45, 0, 15, 30, 45, 0, 15, 30, 45, 5, 25, 45, 5, 25, 45, 5]
                }
            case 9  :
                print("8th & Market East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    endStationMinute = [15, 47, 32, 17, 2, 47, 32, 9, 39, 9, 39, 9, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 55]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [15, 47, 32, 17, 2, 47, 32, 9, 40, 10, 40, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50, 10, 30, 50]
                } else { //Weekday
                    endStationHour = [0, 0, 1, 2, 3, 3, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24]
                    endStationMinute = [15, 47, 32, 17, 2, 47, 32, 19, 36, 51, 6, 21, 34, 45, 57, 5, 15, 25, 39, 52, 2, 21, 26, 37, 45, 58, 13, 29, 37, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 36, 48, 0, 12, 24, 34, 44, 54, 4, 13, 18, 25, 31, 39, 46, 51, 58, 3, 7, 11, 15, 19, 24, 29, 34, 40, 46, 53, 59, 5, 12, 21, 26, 38, 48, 58, 13, 25, 40, 55, 10, 25, 40, 55, 10, 25, 40, 0, 20, 40, 0, 20, 40, 0]
                }
            case 10  :
                print("9/10th & Locust East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 99, 99, 99, 99, 99, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    endStationMinute = [13, 99, 99, 99, 99, 99, 30, 7, 37, 7, 37, 7, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 53]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 99, 99, 99, 99, 99, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [13, 99, 99, 99, 99, 99, 30, 7, 38, 8, 38, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48, 8, 28, 48]
                } else { //Weekday
                    endStationHour = [0, 99, 99, 99, 99, 99, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [13, 99, 99, 99, 99, 99, 30, 17, 34, 49, 4, 19, 32, 43, 55, 3, 13, 23, 37, 50, 0, 19, 24, 35, 43, 56, 11, 27, 35, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 34, 46, 58, 10, 22, 32, 42, 52, 2, 11, 16, 23, 29, 37, 44, 49, 56, 1, 5, 9, 13, 17, 22, 27, 32, 38, 44, 51, 57, 3, 10, 19, 24, 36, 46, 56, 11, 23, 38, 53, 8, 23, 38, 53, 8, 23, 38, 58, 18, 38, 58, 18, 38, 58]
                }
            case 11  :
                print("12/13th & Locust East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 0, 1, 2, 2, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    endStationMinute = [12, 44, 29, 14, 59, 44, 29, 6, 36, 6, 36, 6, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 52]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 0, 1, 2, 2, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [12, 44, 29, 14, 59, 44, 29, 6, 37, 7, 37, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47, 7, 27, 47]
                } else { //Weekday
                    endStationHour = [0, 0, 1, 2, 2, 3, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [12, 44, 29, 14, 59, 44, 29, 16, 33, 48, 3, 18, 31, 42, 54, 2, 12, 22, 36, 49, 59, 18, 23, 34, 42, 55, 10, 26, 34, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 33, 45, 57, 9, 21, 31, 41, 51, 1, 10, 15, 22, 28, 36, 43, 48, 55, 0, 4, 8, 12, 16, 21, 26, 31, 37, 43, 50, 56, 2, 9, 18, 23, 35, 45, 55, 10, 22, 37, 52, 7, 22, 37, 52, 7, 22, 37, 57, 17, 37, 57, 17, 37, 57]
                }
            case 12  :
                print("15/16th & Locust East")
                if weekday == 7 { //Saturday
                    endStationHour = [0, 0, 1, 2, 2, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23]
                    endStationMinute = [11, 43, 28, 13, 58, 43, 28, 5, 35, 5, 35, 5, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 51]
                } else if weekday == 1 { //Sunday
                    endStationHour = [0, 0, 1, 2, 2, 3, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [11, 43, 28, 13, 58, 43, 28, 5, 36, 6, 36, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46, 6, 26, 46]
                } else { //Weekday
                    endStationHour = [0, 0, 1, 2, 2, 3, 4, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 23, 23, 23]
                    endStationMinute = [11, 43, 28, 13, 58, 43, 28, 15, 32, 47, 2, 17, 30, 41, 53, 1, 11, 21, 35, 48, 58, 17, 22, 33, 41, 54, 9, 25, 33, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 32, 44, 56, 8, 20, 30, 40, 50, 0, 9, 14, 21, 27, 35, 42, 47, 54, 59, 3, 7, 11, 15, 20, 25, 30, 36, 42, 49, 55, 1, 8, 17, 22, 34, 44, 54, 9, 21, 36, 51, 6, 21, 36, 51, 6, 21, 36, 56, 16, 36, 56, 16, 36, 56]
                }
            default :
                print( "default case")
            }
            
        } //end of if startStation < endStation
        
        
    } // end of getStartAndEndStationTimes()
    
    
    
    
    
} // end of class
