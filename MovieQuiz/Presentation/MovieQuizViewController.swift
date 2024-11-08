import UIKit

import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public Properties
    
    // MARK: - Private Properties
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        setupImageView()
    }
    
    // MARK: - IBActions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    // MARK: - Public Method

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Private Method
    private func setupImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderColor = UIColor.clear.cgColor
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
            let message = presenter.makeResultsMessage()

            let alert = UIAlertController(
                title: result.title,
                message: message,
                preferredStyle: .alert)

                let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                    guard let self = self else { return }

                    self.presenter.restartGame()
                }

            alert.addAction(action)

            self.present(alert, animated: true, completion: nil)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func changeButtonState(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    func showNetworkError(message: String) {
          hideLoadingIndicator()

          let alert = UIAlertController(
              title: "Ошибка",
              message: message,
              preferredStyle: .alert)

              let action = UIAlertAction(title: "Попробовать ещё раз",
              style: .default) { [weak self] _ in
                  guard let self = self else { return }

                  self.presenter.restartGame()
              }

          alert.addAction(action)
      }
}

