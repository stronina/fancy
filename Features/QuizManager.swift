import Foundation

struct QuizQuestion: Identifiable {
    let id = UUID()
    let text: String
    let answers: [String]
    let correctAnswerIndex: Int
}

final class QuizManager: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var lives: Int = 3

    /// Заглушки для 5 вопросов
    let questions: [QuizQuestion] = [
        QuizQuestion(
            text: "Вопрос 1: Заглушка",
            answers: ["Вариант A", "Вариант B", "Вариант C", "Вариант D"],
            correctAnswerIndex: 0
        ),
        QuizQuestion(
            text: "Вопрос 2: Заглушка",
            answers: ["A", "B", "C", "D"],
            correctAnswerIndex: 1
        ),
        QuizQuestion(
            text: "Вопрос 3: Заглушка",
            answers: ["1", "2", "3", "4"],
            correctAnswerIndex: 2
        ),
        QuizQuestion(
            text: "Вопрос 4: Заглушка",
            answers: ["Alpha", "Beta", "Gamma", "Delta"],
            correctAnswerIndex: 3
        ),
        QuizQuestion(
            text: "Вопрос 5: Заглушка",
            answers: ["Первый", "Второй", "Третий", "Четвёртый"],
            correctAnswerIndex: 0
        )
    ]

    var currentQuestion: QuizQuestion {
        questions[currentQuestionIndex]
    }

    /// Проверяет ответ; возвращает true, если правильный
    func submit(answer index: Int) -> Bool {
        if index == currentQuestion.correctAnswerIndex {
            // правильный
            return true
        } else {
            // неправильный
            lives -= 1
            return false
        }
    }

    /// Переход к следующему вопросу (без проверки границ)
    func advance() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        }
    }

    /// Сбрасывает игру
    func reset() {
        currentQuestionIndex = 0
        lives = 3
    }
}
