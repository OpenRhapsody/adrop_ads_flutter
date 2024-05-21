import Foundation
import AdropAds

class PageTracker {
    
    private let key = "adrop_external_key"
    
    private var currentPage = ""
    private var backgroundAt: Int64 = 0
    
    private var sizeOfRoutes = 0
    private var pivotIdxOfPrevSession = 0
    
    init() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            let backgroundAt = self?.backgroundAt ?? 0
            if (backgroundAt > 0 && Date().currentTimeMillis - backgroundAt > 30_000) {
                self?.track(self?.currentPage ?? "")
                self?.pivotIdxOfPrevSession = self?.sizeOfRoutes ?? 0
            }
            self?.backgroundAt = 0
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] _ in
            self?.backgroundAt = Date().currentTimeMillis
        }
    }
    
    // MARK: - public functions
    
    func track(page: String, sizeOfRoutes: Int) {
        let pushed = sizeOfRoutes >= self.sizeOfRoutes
        self.sizeOfRoutes = sizeOfRoutes
        currentPage = page
        
        let isTrackable = pushed || isTrackablePopPageIfSessionRestarted()
        if (!isTrackable) {
            return
        }
        
        track(page)
    }
    
    func attach(unitId: String, page: String) {
        AdropPageTracker.attach(key: key, unitId: unitId, screen: page)
    }
    
    // MARK: - private functions
    
    private func track(_ page: String) {
        AdropPageTracker.track(key: key, screen: page)
    }
    
    private func isTrackablePopPageIfSessionRestarted() -> Bool {
        if (sizeOfRoutes >= pivotIdxOfPrevSession) {
            return false
        }
        
        pivotIdxOfPrevSession = sizeOfRoutes
        return true
    }
}
