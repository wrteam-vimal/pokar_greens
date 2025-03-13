import UIKit
import Flutter
import GoogleMaps
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Firebase if not already initialized
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // Set up notifications delegate for iOS 10+
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        // Initialize Google Maps
        GMSServices.provideAPIKey("AIzaSyDv4wCwczMMTsbLqXvftfz6NBRgzG5Z6sk")

        // Register Flutter plugins only once
        let registry = self as FlutterPluginRegistry
        GeneratedPluginRegistrant.register(with: registry)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}