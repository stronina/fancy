import Foundation

final class UserDefaultsProgressStore: ProgressStoreProtocol {
    private let key = "fancy_completedLevels"
    private let defaults = UserDefaults.standard

    var completedLevels: Set<Int> {
        get {
            let array = defaults.array(forKey: key) as? [Int] ?? []
            return Set(array)
        }
        set {
            defaults.set(Array(newValue), forKey: key)
        }
    }

    func synchronize() {
        defaults.synchronize()
    }
}
