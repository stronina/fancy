import Foundation

protocol ProgressStoreProtocol {
    /// Метка пройденных уровней: 1…5
    var completedLevels: Set<Int> { get set }
    /// Сохраняет изменения
    func synchronize()
}
