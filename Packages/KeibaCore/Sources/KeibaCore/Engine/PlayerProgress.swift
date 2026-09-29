import Foundation

/// 仕様追補 v1.0.1: 残高の称号
public enum PlayerTitle: Int, CaseIterable, Sendable {
    case apprentice, regular, skilled, master, legend

    public var label: String {
        switch self {
        case .apprentice: return "見習い予想家"
        case .regular: return "一人前の予想家"
        case .skilled: return "腕利き予想家"
        case .master: return "名予想家"
        case .legend: return "伝説の予想家"
        }
    }

    public var threshold: Int {
        switch self {
        case .apprentice: return 0
        case .regular: return 20_000
        case .skilled: return 50_000
        case .master: return 200_000
        case .legend: return 1_000_000
        }
    }

    public static func title(for balance: Int) -> PlayerTitle {
        allCases.last { balance >= $0.threshold } ?? .apprentice
    }
}

/// 仕様追補 v1.0.1: 残高が尽きたときの救済（再スタート）
public enum RescuePolicy {
    public static let restartBalance = SampleRaceData.initialBalance

    /// 最低購入額を下回り、未精算の馬券がないときだけ再スタート可能
    public static func canRestart(balance: Int, hasOpenBets: Bool) -> Bool {
        balance < BetEngine.unit && !hasOpenBets
    }
}
