import UIKit

final class MovieQuizPresenter {
    
    // MARK: Private Properties
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let questionsAmount = 10
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactory?
    private var resultAlert: AlertPresenter?
    private var statisticService: StatisticServiceImplementation?
    
    // MARK: Init
    
    init(viewController: MovieQuizViewControllerProtocol, alertDelegate: AlertPresenterDelegate? = nil) {
        self.viewController = viewController
        
        resultAlert = AlertPresenter(delegate: alertDelegate)
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        
        questionFactory?.loadData()
        
        viewController.showLoadingIndicator()
    }
    
    // MARK: Public Method
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                             question: model.text,
                                             questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
    }
    
    
    // MARK: Private Functions
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            guard let statisticService = statisticService else {
                print("statisticService = nil")
                return
            }
            
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let text = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов:  \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
            
            let viewModel = AlertModel(title: "Этот раунд окончен", message: text, buttonText: "Сыграть еще раз") { [weak self] _ in
                guard let self = self else { return }
                viewController?.showLoadingIndicator()
                restartGame()
            }
            resultAlert?.showAlert(model: viewModel)
        } else {
            switchToNextQuestion()
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.changeButtonState(isEnabled: false)
        
        didAnswer(isCorrect: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            viewController?.showLoadingIndicator()
            proceedToNextQuestionOrResults()
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

// MARK: QuestionFactoryDelegate

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        viewController?.hideLoadingIndicator()
        viewController?.changeButtonState(isEnabled: true)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        if (questionFactory?.moviesIsEmpty() ?? true) {
            let model = AlertModel(title: "Ошибка загрузки",
                                   message: "Проблемы с API key\nПопробуйте позже",
                                   buttonText: "Ok") { [weak self] _ in
                self?.questionFactory?.loadData()
            }
            
            viewController?.showLoadingIndicator()
            resultAlert?.showAlert(model: model)
            return
        }
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        viewController?.hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: error.localizedDescription,
                               buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self = self else { return }
            
            restartGame()
        }
        resultAlert?.showAlert(model: model)
    }
    
    func didFailToLoadImage(with error: any Error) {
        let model = AlertModel(title: "Ошибка загрузки",
                               message: "Невозможно загрузить постер",
                               buttonText: "Начать тест заново") { [weak self] _ in
            guard let self = self else { return }
            questionFactory?.loadData()
        }
        resultAlert?.showAlert(model: model)
    }
}
