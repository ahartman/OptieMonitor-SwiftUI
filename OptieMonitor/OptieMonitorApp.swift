//
//  OptieMonitorApp.swift
//  OptieMonitor
//
//  Created by André Hartman on 27/10/2020.
//

import SwiftUI
import os

@main
struct OptieMonitorApp: App {
    var viewModel = ViewModel()

    @StateObject var notificationCenter = NotificationCenter()
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            TabView {
                IntradayView()
                    .tabItem{
                        Image(systemName: "calendar.circle")
                        Text("Intraday")
                    }
                InterdayView()
                    .tabItem{
                        Image(systemName: "calendar.circle.fill")
                        Text("Interday")
                    }
                SettingsView()
                    .tabItem{
                        Image(systemName: "gear")
                        Text("Notificaties")
                    }
                LocalNotificationDemoView(notificationCenter: notificationCenter)
                    .tabItem{
                        Image(systemName: "gear")
                        Text("Test")
                    }
            }
            .environmentObject(viewModel)
        }
    }
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }
    //No callback in simulator -- must use device to get valid push token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("Registered deviceTokenString: \(deviceTokenString)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
}

class NotificationCenter: NSObject, ObservableObject {
    var dumbData: UNNotificationResponse?

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
}

extension NotificationCenter: UNUserNotificationCenterDelegate  {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) { }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        dumbData = response
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
}

class LocalNotification: ObservableObject {
    init() {

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (allowed, error) in
            //This callback does not trigger on main loop be careful
            if allowed {
                os_log(.debug, "Allowed")
            } else {
                os_log(.debug, "Error")
            }
        }
    }

    func setLocalNotification(title: String, subtitle: String, body: String, when: Double) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: when, repeats: false)
        let request = UNNotificationRequest.init(identifier: "localNotificatoin", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

    }
}
/*
 struct LocalNotificationDemoView: View {
 @StateObject var localNotification = LocalNotification()
 @ObservedObject var notificationCenter: NotificationCenter
 var body: some View {
 VStack {
 Button("schedule Notification") {
 localNotification.setLocalNotification(title: "title",
 subtitle: "Subtitle",
 body: "this is nody",
 when: 10)
 }

 if let dumbData = notificationCenter.dumbData  {
 Text("Old Notification Payload:")
 Text(dumbData.actionIdentifier)
 Text(dumbData.notification.request.content.body)
 Text(dumbData.notification.request.content.title)
 Text(dumbData.notification.request.content.subtitle)
 }
 }
 }
 }
 */
extension UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for notifications!")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
}
