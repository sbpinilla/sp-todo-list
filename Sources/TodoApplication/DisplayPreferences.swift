/// Port for user display preferences that must survive relaunch.
@MainActor
public protocol DisplayPreferences: AnyObject {
    var showOnlyToday: Bool { get set }
}
