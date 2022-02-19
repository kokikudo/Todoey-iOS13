import UIKit
import RealmSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Realmデータのファイルパス
        //print(Realm.Configuration.defaultConfiguration.fileURL)

        do {
            let _ = try Realm()
        } catch {
            print("Error initialaizing Realm: \(error)")
        }

        return true
    }

}

