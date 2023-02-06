//
//  AppDelegate.swift
//  ChatNotification
//
//  Created by estech on 6/2/23.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window:UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // Vamos a pedir permiso al usuario para notificaciones push
        
        registerForPushNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        
        return true
    }
    
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    //Esta funcion se crea con el nombre que queremos tras dar de alta Notificaciones
    func registerForPushNotifications(){
        
        //pedimos permiso al usuario para recibir notificaciones push
        UNUserNotificationCenter.current().requestAuthorization(options:[.alert, .sound, .badge] ){ granted, error in
            print("Permiso concedido: \(granted)")
            
            guard granted else {return}
            
            self.getNotificationSettings()
        }
        //las opciones más comunes que tenemos son: .badge, .sound. .alert
        //otras opciones menos comunes: .carPlay(en el coche), .provisional, .providesAppNotificationSettins
        //tenemos otra opcion: .criticalAlert
    }
    func getNotificationSettings(){
        UNUserNotificationCenter.current().getNotificationSettings {
            settings in
       //     print("configuracion push: \(settings)")
            
            //Comprobamos que el usuario nios ha autorizado a enviarle notificaciones
            guard settings.authorizationStatus == .authorized else {return}
            
            
            //Registrarlo en APNs
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
        }
    }
    
//si se ha completado el registro se va ajecutar esta función
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map{data in String(format: "%02.2hhx", data)}  // este format es siempre el mismo , copiar y pegar siempre lo mismo
        let token = tokenParts.joined()
        print("Device token: \(token)")
        
    }
    
    //Si se produce un error al tratar de registrar el dispositivo
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) { print("Failed to register: \(error)")
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        guard let aps = userInfo["aps"] as? [String:AnyObject] else {
            completionHandler(.failed)
            return
            
        }
        
        guard let alert = aps["alert"] as? [String:String] else {
            return
        }
        print(alert["title"])
        
        
        print(aps)
        
        guard let notif = userInfo as? [String:AnyObject] else {
            completionHandler(.failed)
            return
        }
        
        //Mostrar la notificación en un alert
//
//        var alertController = UIAlertController(title: aps["alert"]?["title"] as! String, message: aps["alert"]?["body"]as! String, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "ok", style: .default))
//
//        self.window?.rootViewController?.present(alertController, animated:true)
                
                if let pushBadgeNumber:Int = aps["bagde"] as? Int {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BadgeChanged"), object: nil)
                    UIApplication.shared.applicationIconBadgeNumber = pushBadgeNumber
                }
        
    }
    
}

