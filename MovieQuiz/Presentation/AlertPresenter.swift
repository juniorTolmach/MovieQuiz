import UIKit

class AlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?
    
    func setup(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        let button = UIAlertAction(title: model.buttonText, style: .default, handler: model.completion)
        alert.addAction(button)
        delegate?.showResultAlert(view: alert)
    }
}
