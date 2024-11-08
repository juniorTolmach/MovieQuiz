import UIKit

final class AlertPresenter: AlertPresentProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate?) {
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Alert"
        let button = UIAlertAction(title: model.buttonText, style: .default, handler: model.completion)
        alert.addAction(button)
        delegate?.didShowResultAlert(view: alert)
    }
}
