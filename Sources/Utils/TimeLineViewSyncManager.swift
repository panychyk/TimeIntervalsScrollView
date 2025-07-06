import UIKit

final public class ScrollSynchronizer {
    
    // MARK: - Private props
    private var scrollViews: [Weak<UIScrollView>] = []
    private(set) var currentOffset: CGPoint = .zero
    
    public init() {
        
    }
    
    // MARK: - Public funcs
    @MainActor public func register(scrollView: UIScrollView) {
        guard !scrollViews.contains(where: { $0.value === scrollView }) else { return }
        
        scrollViews.append(Weak(scrollView))
        scrollView.setContentOffset(currentOffset, animated: false)
        cleanUp()
    }
    
    public func unregister(scrollView: UIScrollView) {
        scrollViews.removeAll { $0.value === scrollView }
    }
    
    public func reset() {
        scrollViews.removeAll()
        currentOffset = .zero
    }
    
    @MainActor public func sync(from source: UIScrollView) {
        let newOffset = source.contentOffset
        guard currentOffset != newOffset else { return }
        
        currentOffset = newOffset
        
        scrollViews.forEach {
            guard let scrollView = $0.value, scrollView !== source else { return }
            
            if scrollView.contentOffset != newOffset {
                scrollView.setContentOffset(newOffset, animated: false)
            }
        }
    }
    
    // MARK: - Private funcs
    private func cleanUp() {
        scrollViews.removeAll { $0.value == nil }
    }
}
