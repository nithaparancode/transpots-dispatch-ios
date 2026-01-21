import SwiftUI

public struct AppSymbols {
    
    // MARK: - Tab Bar Icons
    public static var tabHome: Image { Image(systemName: "house.fill") }
    public static var tabHomeOutline: Image { Image(systemName: "house") }
    public static var tabOrders: Image { Image(systemName: "list.bullet.clipboard.fill") }
    public static var tabOrdersOutline: Image { Image(systemName: "list.bullet.clipboard") }
    public static var tabProfile: Image { Image(systemName: "person.fill") }
    public static var tabProfileOutline: Image { Image(systemName: "person") }
    
    public static let tabHomeName = "house.fill"
    public static let tabOrdersName = "list.bullet.clipboard.fill"
    public static let tabProfileName = "person.fill"
    
    // MARK: - Launch Screen
    public static var launchTruck: Image { Image(systemName: "truck.box.fill") }
    
    // MARK: - Navigation
    public static var navBack: Image { Image(systemName: "chevron.left") }
    public static var navForward: Image { Image(systemName: "chevron.right") }
    public static var navClose: Image { Image(systemName: "xmark") }
    public static var navMenu: Image { Image(systemName: "line.3.horizontal") }
    
    // MARK: - Actions
    public static var actionAdd: Image { Image(systemName: "plus") }
    public static var actionEdit: Image { Image(systemName: "pencil") }
    public static var actionDelete: Image { Image(systemName: "trash") }
    public static var actionSave: Image { Image(systemName: "checkmark") }
    public static var actionCancel: Image { Image(systemName: "xmark") }
    public static var actionSearch: Image { Image(systemName: "magnifyingglass") }
    public static var actionFilter: Image { Image(systemName: "line.3.horizontal.decrease.circle") }
    public static var actionRefresh: Image { Image(systemName: "arrow.clockwise") }
    public static var actionShare: Image { Image(systemName: "square.and.arrow.up") }
    public static var actionSettings: Image { Image(systemName: "gear") }
    
    // MARK: - Status
    public static var statusSuccess: Image { Image(systemName: "checkmark.circle.fill") }
    public static var statusError: Image { Image(systemName: "xmark.circle.fill") }
    public static var statusWarning: Image { Image(systemName: "exclamationmark.triangle.fill") }
    public static var statusInfo: Image { Image(systemName: "info.circle.fill") }
    public static var statusPending: Image { Image(systemName: "clock.fill") }
    
    // MARK: - Orders
    public static var ordersList: Image { Image(systemName: "list.bullet.clipboard.fill") }
    public static var ordersDetail: Image { Image(systemName: "doc.text.fill") }
    public static var ordersDelivered: Image { Image(systemName: "checkmark.seal.fill") }
    public static var ordersInProgress: Image { Image(systemName: "shippingbox.fill") }
    public static var ordersCancelled: Image { Image(systemName: "xmark.seal.fill") }
    
    // MARK: - Profile
    public static var profileUser: Image { Image(systemName: "person.fill") }
    public static var profileSettings: Image { Image(systemName: "gear") }
    public static var profileLogout: Image { Image(systemName: "rectangle.portrait.and.arrow.right") }
    public static var profileEdit: Image { Image(systemName: "person.crop.circle.badge.pencil") }
    public static var profileNotifications: Image { Image(systemName: "bell.fill") }
    
    // MARK: - Communication
    public static var commPhone: Image { Image(systemName: "phone.fill") }
    public static var commMessage: Image { Image(systemName: "message.fill") }
    public static var commEmail: Image { Image(systemName: "envelope.fill") }
    public static var commChat: Image { Image(systemName: "bubble.left.and.bubble.right.fill") }
    
    // MARK: - Location
    public static var locationPin: Image { Image(systemName: "mappin.circle.fill") }
    public static var locationMap: Image { Image(systemName: "map.fill") }
    public static var locationNavigation: Image { Image(systemName: "location.fill") }
    public static var locationRoute: Image { Image(systemName: "arrow.triangle.turn.up.right.diamond.fill") }
    
    // MARK: - Time
    public static var timeClock: Image { Image(systemName: "clock.fill") }
    public static var timeCalendar: Image { Image(systemName: "calendar") }
    public static var timeTimer: Image { Image(systemName: "timer") }
    
    // MARK: - Media
    public static var mediaCamera: Image { Image(systemName: "camera.fill") }
    public static var mediaPhoto: Image { Image(systemName: "photo.fill") }
    public static var mediaVideo: Image { Image(systemName: "video.fill") }
}
