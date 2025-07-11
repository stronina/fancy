import Foundation

final class DateLockService {
    /// Жёстко прописанная дата разблокировки — замени на свою jhb
    private let unlockDate: Date = {
        var comps = DateComponents()
        comps.year = 2025   // год
        comps.month = 7     // месяц
        comps.day = 7      // день
        comps.timeZone = .current
        return Calendar.current.date(from: comps)!
    }()

    /// Проверяет, открывать ли хаб
    func isUnlocked() -> Bool {
        Date() >= unlockDate
    }
}
