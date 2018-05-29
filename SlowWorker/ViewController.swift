//
//  ViewController.swift
//  SlowWorker
//
//  Created by Pedro Alonso on 3/6/18.
//  Copyright © 2018 Pedro Alonso. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UIApplicationDelegate {

    @IBOutlet var startButton: UIButton!
    @IBOutlet var resultsTExtView: UITextView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    
    func fetchSomethingFromServer() -> String {
        Thread.sleep(forTimeInterval: 1)
        return "Hi there"
    }
    
    func processData(data: String) -> String {
        Thread.setThreadPriority(2)
        
        return data.uppercased()
    }
    
    func calculateFirstResult(data: String) -> String {
        Thread.sleep(forTimeInterval: 3)
        return "Number of chars: \(data.characters.count)"
    }
    func calculateSecondResult(data: String) -> String {
        Thread.sleep(forTimeInterval: 4)
        return data.replacingOccurrences(of: "E", with: "e")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //MARK: Change of State app
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(ViewController.applicationWillResignActive), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        center.addObserver(self, selector: #selector(ViewController.applicationDidBecomeActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        center.addObserver(self, selector: #selector(ViewController.applicationDidEnterBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        center.addObserver(self, selector: #selector(ViewController.applicationWillEnterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        let centerPush = UNUserNotificationCenter.current()
        centerPush.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
        
    }
    
    @objc func applicationDidEnterBackground() {
        print("Time to save state")
        
//        MARK: Request more time
        let app = UIApplication.shared
        var taskId = UIBackgroundTaskInvalid
        let id = app.beginBackgroundTask() {
            print("Background task ran out of time and was terminated.")
            app.endBackgroundTask(taskId)
        }
        taskId = id
        if taskId == UIBackgroundTaskInvalid {
            print("Failed to start background task!")
            return
        }
        
        //     MARK:   Then some work
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.sync {
                print("Starting background task with " + "\(app.backgroundTimeRemaining) seconds remaining")

            }
//            self.smiley = nil
//            self.smileyView.image = nil
            // simulate a lengthy (25 seconds) procedure
            Thread.sleep(forTimeInterval: 25)
            DispatchQueue.main.async {
                print("Finishing background task with " + "\(app.backgroundTimeRemaining) seconds remaining")

            }
            app.endBackgroundTask(taskId)
        }
    }
    
    @objc func applicationWillEnterForeground() {
        print("Time to recover saved state")
    }
    
    @objc func applicationWillResignActive() {
        print("We are going out")
    }
    
    @objc func applicationDidBecomeActive() {
        print("We are coming in")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func doWork(sender: UIButton) {
        // MARK:        //normal method
//        let startTime = NSDate()
//        self.resultsTExtView.text = ""
//        let fetchedData = self.fetchSomethingFromServer()
//        let processedData = self.processData(data: fetchedData)
//        let firstResult = self.calculateFirstResult(data: processedData)
//        let secondResult = self.calculateSecondResult(data: processedData)
//        let resultsSummary =
//        "First: [\(firstResult)]\nSecond: [\(secondResult)]"
//        self.resultsTExtView.text = resultsSummary
//        let endTime = NSDate()
//        print("Completed in \(endTime.timeIntervalSince(startTime as Date)) seconds")
//
//        //MARK: Method with GDC
//        let startTime = Date()
//        self.resultsTExtView.text = ""
//        self.startButton.isEnabled = false
//        self.spinner.startAnimating()
//        let queue = DispatchQueue.global(qos: .default)
//        queue.async {
//            let fetchedData = self.fetchSomethingFromServer()
//            let processedData = self.processData(data: fetchedData)
//            let firstResult = self.calculateFirstResult(data: processedData)
//            let secondResult = self.calculateSecondResult(data: processedData)
//            let resultsSummary =
//            "First: [\(firstResult)]\nSecond: [\(secondResult)]"
//            DispatchQueue.main.async {
//
//                self.startButton.isEnabled = true
//                self.resultsTExtView.text = resultsSummary
//                self.spinner.stopAnimating()
//            }
//
//            let endTime = Date()
//            print("Completed in \(endTime.timeIntervalSince(startTime as Date)) seconds")
//
//        }
        
        //MARK: GCD has a way to accomplish this by using what’s called a dispatch group.
        let startTime = Date()
        self.resultsTExtView.text = ""
        startButton.isEnabled = false
        spinner.startAnimating()
        let queue = DispatchQueue.global(qos: .default)
        queue.async {
            let fetchedData = self.fetchSomethingFromServer()
            let processedData = self.processData(data: fetchedData)
            var firstResult: String!
            var secondResult: String!
            let group = DispatchGroup()
            queue.async(group: group, execute: {
                firstResult = self.calculateFirstResult(data: processedData)
            })
            
            queue.async(group: group, execute: {
                secondResult = self.calculateSecondResult(data: processedData)
            })
        group.notify(queue: queue, execute: {
            let resultsSummary = "First: [\(firstResult!)]\nSecond: [\(secondResult!)]"
            DispatchQueue.main.async {
                self.resultsTExtView.text = resultsSummary
                self.startButton.isEnabled = true
                self.spinner.stopAnimating()
            }
            let endTime = Date()
            print("Completed in \(endTime.timeIntervalSince(startTime)) seconds")
        })
        
    }

    // Declare a closure variable "loggerClosure" with no parameters
    // and no return value.
    let loggerClosure = {
        print("I'm just glad they didn't call it a lambda")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
     print("x")
    }

}
