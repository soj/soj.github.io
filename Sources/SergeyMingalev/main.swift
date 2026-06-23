import Foundation
import Publish
import Plot
import SplashPublishPlugin

// Конфигурация сайта-визитки.
struct SergeyMingalev: Website {
    enum SectionID: String, WebsiteSectionID {
        case posts     // Блог
        case projects  // Портфолио
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Дополнительные поля во front matter markdown-файлов.
        var tech: String?  // стек технологий проекта
        var link: String?  // ссылка на проект / репозиторий
    }

    // Основные настройки — правьте под себя:
    var url = URL(string: "https://sergeymingalev.dev")!
    var name = "Sergey Mingalev"
    var description = "iOS / Swift разработчик — блог и портфолио"
    var language: Language { .russian }
    var imagePath: Path? { nil }

    // Поля визитки:
    var tagline = "iOS / Swift Developer"

    // Контакты и соцсети. Впишите свои; ненужные оставьте nil.
    var email: String? = "you@example.com"
    var githubURL: String? = "https://github.com/your-handle"
    var telegramURL: String? = nil
    var linkedInURL: String? = nil
}

// Генерация сайта с собственной темой `card`.
// Плагин Splash подсвечивает синтаксис Swift в блоках кода.
try SergeyMingalev().publish(
    withTheme: .card,
    plugins: [.splash(withClassPrefix: "")]
)
