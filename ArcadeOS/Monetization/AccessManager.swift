import Foundation

// MARK: - Game Access State
struct GameAccess: Codable {
    var tempUnlockUntil: Date?
    var unlocksToday: Int = 0
    var lastUnlockAt: Date?
    var lastUnlockDayKey: String = ""
}

// MARK: - Access Manager
class AccessManager: ObservableObject {
    static let shared = AccessManager()

    @Published var gameAccessData: [String: GameAccess] = [:]

    private let maxUnlocksPerDay = 2
    private let unlockDuration: TimeInterval = 30 * 60 // 30 minutes
    private let cooldownDuration: TimeInterval = 60 * 60 // 60 minutes

    private init() {
        loadAccessData()
    }

    // MARK: - Persistence

    private func loadAccessData() {
        if let data = UserDefaults.standard.data(forKey: "gameAccessData"),
           let decoded = try? JSONDecoder().decode([String: GameAccess].self, from: data) {
            gameAccessData = decoded
        }
    }

    private func saveAccessData() {
        if let encoded = try? JSONEncoder().encode(gameAccessData) {
            UserDefaults.standard.set(encoded, forKey: "gameAccessData")
        }
    }

    // MARK: - Check Access

    func hasTempAccess(_ gameID: String) -> Bool {
        guard let access = gameAccessData[gameID] else { return false }

        // Check if temp unlock is still valid
        if let unlockUntil = access.tempUnlockUntil, Date() < unlockUntil {
            return true
        }

        return false
    }

    func hasAccess(_ game: GameMeta, isSubscriber: Bool) -> Bool {
        !game.isPremium || isSubscriber || hasTempAccess(game.id)
    }

    // MARK: - Grant Temp Access

    func grantTempAccess(_ gameID: String) {
        let now = Date()
        let todayKey = dayKey(for: now)

        var access = gameAccessData[gameID] ?? GameAccess()

        // Reset daily count if new day
        if access.lastUnlockDayKey != todayKey {
            access.unlocksToday = 0
            access.lastUnlockDayKey = todayKey
        }

        // Grant access
        access.tempUnlockUntil = now.addingTimeInterval(unlockDuration)
        access.unlocksToday += 1
        access.lastUnlockAt = now

        gameAccessData[gameID] = access
        saveAccessData()

        print("✅ Granted temp access to \(gameID) until \(access.tempUnlockUntil!)")
    }

    // MARK: - Check Eligibility

    func canWatchAd(for gameID: String) -> Bool {
        let now = Date()
        let todayKey = dayKey(for: now)

        guard let access = gameAccessData[gameID] else {
            // No access data, user can watch ad
            return true
        }

        // Check if new day (reset counter)
        if access.lastUnlockDayKey != todayKey {
            return true
        }

        // Check daily limit
        if access.unlocksToday >= maxUnlocksPerDay {
            return false
        }

        // Check cooldown
        if let lastUnlock = access.lastUnlockAt {
            let timeSinceLastUnlock = now.timeIntervalSince(lastUnlock)
            if timeSinceLastUnlock < cooldownDuration {
                return false
            }
        }

        return true
    }

    // MARK: - Next Available Time

    func nextAvailableTime(for gameID: String) -> Date? {
        let now = Date()
        let todayKey = dayKey(for: now)

        guard let access = gameAccessData[gameID] else { return now }

        // If new day, available now
        if access.lastUnlockDayKey != todayKey {
            return now
        }

        // If daily limit reached, next available tomorrow
        if access.unlocksToday >= maxUnlocksPerDay {
            let calendar = Calendar.current
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
            return tomorrow
        }

        // If in cooldown, return cooldown end time
        if let lastUnlock = access.lastUnlockAt {
            let cooldownEnd = lastUnlock.addingTimeInterval(cooldownDuration)
            if cooldownEnd > now {
                return cooldownEnd
            }
        }

        return now
    }

    // MARK: - Remaining Time

    func remainingUnlockTime(for gameID: String) -> TimeInterval? {
        guard let access = gameAccessData[gameID],
              let unlockUntil = access.tempUnlockUntil,
              Date() < unlockUntil else {
            return nil
        }

        return unlockUntil.timeIntervalSince(Date())
    }

    // MARK: - Helpers

    private func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
