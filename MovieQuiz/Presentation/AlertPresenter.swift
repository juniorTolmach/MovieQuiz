import UIKit

class AlertPresenter: AlertPresentProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        let button = UIAlertAction(title: model.buttonText, style: .default, handler: model.completion)
        alert.addAction(button)
        delegate?.didShowResultAlert(view: alert)
    }
}
