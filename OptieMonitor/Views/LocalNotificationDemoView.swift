//
//  LocalNotificationDemoView.swift
//  OptieMonitor
//
//  Created by André Hartman on 27/10/2020.
//

import SwiftUI

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
/*
struct LocalNotificationDemoView_Previews: PreviewProvider {
    static var previews: some View {
        LocalNotificationDemoView()
    }
}
 */
