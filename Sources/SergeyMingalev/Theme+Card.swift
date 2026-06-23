import Foundation
import Publish
import Plot

extension Theme where Site == SergeyMingalev {
    /// Тема-визитка: шапка-навигация, hero, карточки проектов и лента блога.
    /// Двуязычная: RU в корне `/`, EN под `/en/`.
    static var card: Self {
        Theme(htmlFactory: CardHTMLFactory())
    }
}

// MARK: - Язык и локализованные строки

private enum Lang {
    case ru, en

    var plotLanguage: Language { self == .ru ? .russian : .english }

    var homePath: String { self == .ru ? "/" : "/en/" }
    var blogPath: String { self == .ru ? "/posts/" : "/en/posts/" }
    var portfolioPath: String { self == .ru ? "/projects/" : "/en/projects/" }

    var navHome: String { self == .ru ? "Главная" : "Home" }
    var navBlog: String { self == .ru ? "Блог" : "Blog" }
    var navPortfolio: String { self == .ru ? "Портфолио" : "Portfolio" }

    var featuredProjects: String { self == .ru ? "Избранные проекты" : "Featured projects" }
    var recentPosts: String { self == .ru ? "Последние записи" : "Recent posts" }
    var allProjects: String { self == .ru ? "Все проекты →" : "All projects →" }
    var allPosts: String { self == .ru ? "Все записи →" : "All posts →" }
    var viewPortfolio: String { self == .ru ? "Смотреть портфолио" : "View portfolio" }
    var readBlog: String { self == .ru ? "Читать блог" : "Read the blog" }
    var openProject: String { self == .ru ? "Открыть проект ↗" : "Open project ↗" }

    var dateLocale: String { self == .ru ? "ru_RU" : "en_US" }
    var dateFormat: String { self == .ru ? "d MMMM yyyy" : "MMMM d, yyyy" }
}

private struct CardHTMLFactory: HTMLFactory {
    // MARK: - Главная RU (визитка)

    func makeIndexHTML(for index: Index,
                       context: PublishingContext<SergeyMingalev>) throws -> HTML {
        let site = context.site
        let lang = Lang.ru
        let projects = context.sections[.projects].items.sorted { $0.date > $1.date }
        let posts = context.sections[.posts].items.sorted { $0.date > $1.date }

        let cards = projects.prefix(3).map {
            card(title: $0.title, description: $0.description, url: $0.path,
                 tech: $0.metadata.tech, lang: lang)
        }
        let rows: [Node<HTML.ListContext>] = posts.prefix(3).map {
            .li(postRow(title: $0.title, date: $0.date, description: $0.description,
                        url: $0.path, lang: lang))
        }

        return page(
            lang: lang, relative: "", bodyClass: "home",
            title: "\(site.name) — \(site.tagline)", description: site.description,
            site: site,
            main: .main(
                hero(site: site, lang: lang),
                .section(.class("about container"), .contentBody(index.body)),
                featuredSection(cards: cards, lang: lang),
                recentSection(rows: rows, lang: lang)
            )
        )
    }

    // MARK: - Секция RU (Блог / Портфолио)

    func makeSectionHTML(for section: Section<SergeyMingalev>,
                         context: PublishingContext<SergeyMingalev>) throws -> HTML {
        let site = context.site
        let lang = Lang.ru
        let items = section.items.sorted { $0.date > $1.date }

        let listing: Node<HTML.BodyContext>
        if section.id == .projects {
            let cards = items.map {
                card(title: $0.title, description: $0.description, url: $0.path,
                     tech: $0.metadata.tech, lang: lang)
            }
            listing = .div(.class("container"), .div(.class("cards"), .group(cards)))
        } else {
            let rows: [Node<HTML.ListContext>] = items.map {
                .li(postRow(title: $0.title, date: $0.date, description: $0.description,
                            url: $0.path, lang: lang))
            }
            listing = .div(.class("container"), .ul(.class("post-list"), .group(rows)))
        }

        return page(
            lang: lang, relative: rel(section.path), bodyClass: nil,
            title: "\(section.title) | \(site.name)", description: site.description,
            site: site,
            main: .main(
                .section(.class("container page-head"),
                         .h1(.text(section.title)),
                         bodyAfterTitle(section.body)),
                listing
            )
        )
    }

    // MARK: - Запись RU (пост / проект)

    func makeItemHTML(for item: Item<SergeyMingalev>,
                      context: PublishingContext<SergeyMingalev>) throws -> HTML {
        let site = context.site
        let lang = Lang.ru

        return page(
            lang: lang, relative: rel(item.path), bodyClass: "item-page",
            title: "\(item.title) | \(site.name)", description: item.description,
            site: site,
            main: .main(
                .article(
                    .class("container article"),
                    .h1(.text(item.title)),
                    .p(.class("meta"), .text(Self.dateString(item.date, lang: lang))),
                    .unwrap(item.metadata.tech) { .p(.class("tech"), .text($0)) },
                    .unwrap(item.metadata.link) {
                        .p(.a(.class("btn btn-secondary"), .href($0), .text(lang.openProject)))
                    },
                    bodyAfterTitle(item.body)
                )
            )
        )
    }

    // MARK: - Страницы EN (`/en/...`)

    func makePageHTML(for page: Page,
                      context: PublishingContext<SergeyMingalev>) throws -> HTML {
        let site = context.site
        let lang = Lang.en
        let relative = enRelative(page)

        switch relative {
        case "":
            // Главная EN (визитка)
            let cards = enItems(in: "projects", context).prefix(3).map {
                card(title: $0.title, description: $0.description, url: $0.path, tech: nil, lang: lang)
            }
            let rows: [Node<HTML.ListContext>] = enItems(in: "posts", context).prefix(3).map {
                .li(postRow(title: $0.title, date: $0.date, description: $0.description,
                            url: $0.path, lang: lang))
            }
            return self.page(
                lang: lang, relative: "", bodyClass: "home",
                title: "\(site.name) — \(site.tagline)", description: page.description,
                site: site,
                main: .main(
                    hero(site: site, lang: lang),
                    .section(.class("about container"), .contentBody(page.body)),
                    featuredSection(cards: Array(cards), lang: lang),
                    recentSection(rows: rows, lang: lang)
                )
            )

        case "projects":
            // Листинг портфолио EN
            let cards = enItems(in: "projects", context).map {
                card(title: $0.title, description: $0.description, url: $0.path, tech: nil, lang: lang)
            }
            return self.page(
                lang: lang, relative: relative, bodyClass: nil,
                title: "\(page.title) | \(site.name)", description: page.description,
                site: site,
                main: .main(
                    .section(.class("container page-head"),
                             .h1(.text(page.title)),
                             bodyAfterTitle(page.body)),
                    .div(.class("container"), .div(.class("cards"), .group(cards)))
                )
            )

        case "posts":
            // Листинг блога EN
            let rows: [Node<HTML.ListContext>] = enItems(in: "posts", context).map {
                .li(postRow(title: $0.title, date: $0.date, description: $0.description,
                            url: $0.path, lang: lang))
            }
            return self.page(
                lang: lang, relative: relative, bodyClass: nil,
                title: "\(page.title) | \(site.name)", description: page.description,
                site: site,
                main: .main(
                    .section(.class("container page-head"),
                             .h1(.text(page.title)),
                             bodyAfterTitle(page.body)),
                    .div(.class("container"), .ul(.class("post-list"), .group(rows)))
                )
            )

        default:
            // Отдельная запись EN (пост или проект)
            return self.page(
                lang: lang, relative: relative, bodyClass: "item-page",
                title: "\(page.title) | \(site.name)", description: page.description,
                site: site,
                main: .main(
                    .article(
                        .class("container article"),
                        .h1(.text(page.title)),
                        .p(.class("meta"), .text(Self.dateString(page.date, lang: lang))),
                        bodyAfterTitle(page.body)
                    )
                )
            )
        }
    }

    // MARK: - Теги (не используем)

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<SergeyMingalev>) throws -> HTML? { nil }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<SergeyMingalev>) throws -> HTML? { nil }
}

// MARK: - Каркас страницы

private extension CardHTMLFactory {
    /// Общая обёртка: <html> + <head> + <body> с шапкой, контентом и подвалом.
    func page(lang: Lang, relative: String, bodyClass: String?,
              title: String, description: String,
              site: SergeyMingalev,
              main: Node<HTML.BodyContext>) -> HTML {
        HTML(
            .lang(lang.plotLanguage),
            head(title: title, description: description, site: site),
            .body(
                .class(bodyClass ?? ""),
                siteHeader(site: site, lang: lang, relative: relative),
                main,
                siteFooter(site: site, lang: lang)
            )
        )
    }

    func head(title: String, description: String, site: SergeyMingalev) -> Node<HTML.DocumentContext> {
        .head(
            .encoding(.utf8),
            .meta(.name("viewport"), .content("width=device-width, initial-scale=1")),
            .meta(.name("author"), .content(site.name)),
            .title(title),
            .meta(.name("description"), .content(description)),
            .style(Self.css)
        )
    }

    func siteHeader(site: SergeyMingalev, lang: Lang, relative: String) -> Node<HTML.BodyContext> {
        .header(
            .class("site-header"),
            .div(
                .class("container nav-inner"),
                .a(.class("brand"), .href(lang.homePath), .text(site.name)),
                .div(
                    .class("nav-right"),
                    .nav(
                        .class("nav-links"),
                        .a(.href(lang.homePath), .text(lang.navHome)),
                        .a(.href(lang.blogPath), .text(lang.navBlog)),
                        .a(.href(lang.portfolioPath), .text(lang.navPortfolio))
                    ),
                    langSwitch(current: lang, relative: relative)
                )
            )
        )
    }

    /// Переключатель RU ↔ EN. Ведёт на тот же логический путь в другом языке.
    func langSwitch(current: Lang, relative: String) -> Node<HTML.BodyContext> {
        let ruURL = relative.isEmpty ? "/" : "/\(relative)/"
        let enURL = relative.isEmpty ? "/en/" : "/en/\(relative)/"
        return .div(
            .class("lang-switch"),
            .a(.class(current == .ru ? "active" : ""), .href(ruURL), .text("RU")),
            .span(.text("/")),
            .a(.class(current == .en ? "active" : ""), .href(enURL), .text("EN"))
        )
    }

    func siteFooter(site: SergeyMingalev, lang: Lang) -> Node<HTML.BodyContext> {
        .footer(
            .class("site-footer"),
            .div(.class("container"),
                 socialLinks(site: site),
                 .p(.class("copyright"), .text("© \(site.name)")))
        )
    }
}

// MARK: - Компоненты

private extension CardHTMLFactory {
    /// Тело страницы без первого `<h1>` — заголовок мы выводим отдельно,
    /// а Publish оставляет его и в body, поэтому здесь его срезаем.
    func bodyAfterTitle(_ body: Content.Body) -> Node<HTML.BodyContext> {
        let html = body.html
        guard html.hasPrefix("<h1>"), let range = html.range(of: "</h1>") else {
            return .raw(html)
        }
        return .raw(String(html[range.upperBound...]))
    }

    func hero(site: SergeyMingalev, lang: Lang) -> Node<HTML.BodyContext> {
        .section(
            .class("hero container"),
            .h1(.text(site.name)),
            .p(.class("tagline"), .text(site.tagline)),
            socialLinks(site: site),
            .div(
                .class("hero-cta"),
                .a(.class("btn"), .href(lang.portfolioPath), .text(lang.viewPortfolio)),
                .a(.class("btn btn-secondary"), .href(lang.blogPath), .text(lang.readBlog))
            )
        )
    }

    func socialLinks(site: SergeyMingalev) -> Node<HTML.BodyContext> {
        var links = [Node<HTML.BodyContext>]()
        if let gh = site.githubURL { links.append(.a(.class("social"), .href(gh), .text("GitHub"))) }
        if let tg = site.telegramURL { links.append(.a(.class("social"), .href(tg), .text("Telegram"))) }
        if let li = site.linkedInURL { links.append(.a(.class("social"), .href(li), .text("LinkedIn"))) }
        if let mail = site.email { links.append(.a(.class("social"), .href("mailto:\(mail)"), .text(mail))) }
        return .div(.class("socials"), .group(links))
    }

    func featuredSection(cards: [Node<HTML.BodyContext>], lang: Lang) -> Node<HTML.BodyContext> {
        guard !cards.isEmpty else { return .empty }
        return .section(
            .class("section container"),
            .div(.class("section-head"),
                 .h2(.text(lang.featuredProjects)),
                 .a(.class("see-all"), .href(lang.portfolioPath), .text(lang.allProjects))),
            .div(.class("cards"), .group(cards))
        )
    }

    func recentSection(rows: [Node<HTML.ListContext>], lang: Lang) -> Node<HTML.BodyContext> {
        guard !rows.isEmpty else { return .empty }
        return .section(
            .class("section container"),
            .div(.class("section-head"),
                 .h2(.text(lang.recentPosts)),
                 .a(.class("see-all"), .href(lang.blogPath), .text(lang.allPosts))),
            .ul(.class("post-list"), .group(rows))
        )
    }

    /// Карточка проекта. `tech` опционально (у EN-страниц типизированных метаданных нет).
    func card(title: String, description: String, url: Path,
              tech: String?, lang: Lang) -> Node<HTML.BodyContext> {
        .article(
            .class("card"),
            .h3(.a(.href(url), .text(title))),
            .p(.class("card-desc"), .text(description)),
            .unwrap(tech) { .p(.class("tech"), .text($0)) }
        )
    }

    func postRow(title: String, date: Date, description: String,
                 url: Path, lang: Lang) -> Node<HTML.BodyContext> {
        .group(
            .h3(.a(.href(url), .text(title))),
            .p(.class("meta"), .text(Self.dateString(date, lang: lang))),
            .p(.class("post-desc"), .text(description))
        )
    }
}

// MARK: - Работа с путями EN

private extension CardHTMLFactory {
    /// Путь без ведущего слэша: "/posts/x" → "posts/x".
    func rel(_ path: Path) -> String {
        var string = path.string
        while string.hasPrefix("/") { string.removeFirst() }
        return string
    }

    /// Логический путь EN-страницы без префикса языка: "en/posts/x" → "posts/x", "en" → "".
    func enRelative(_ page: Page) -> String {
        let string = rel(page.path)
        if string == "en" { return "" }
        if string.hasPrefix("en/") { return String(string.dropFirst(3)) }
        return string
    }

    /// Все EN-страницы внутри папки ("posts"/"projects"), кроме самой индексной, по дате убыв.
    func enItems(in folder: String, _ context: PublishingContext<SergeyMingalev>) -> [Page] {
        let prefix = "en/\(folder)/"
        return context.pages.values
            .filter { rel($0.path).hasPrefix(prefix) }
            .sorted { $0.date > $1.date }
    }
}

// MARK: - Форматирование дат

private extension CardHTMLFactory {
    static func dateString(_ date: Date, lang: Lang) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: lang.dateLocale)
        formatter.dateFormat = lang.dateFormat
        return formatter.string(from: date)
    }
}

// MARK: - Стили (встроены, чтобы не зависеть от копирования ресурсов)

private extension CardHTMLFactory {
    static let css = """
    :root {
      --bg: #0f1115;
      --surface: #171a21;
      --surface-2: #1e222b;
      --text: #e7e9ee;
      --muted: #9aa3b2;
      --accent: #4f8cff;
      --border: #262b36;
      --radius: 14px;
      --maxw: 880px;
    }
    * { box-sizing: border-box; }
    html { scroll-behavior: smooth; }
    body {
      margin: 0;
      background: var(--bg);
      color: var(--text);
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      line-height: 1.65;
      -webkit-font-smoothing: antialiased;
    }
    a { color: var(--accent); text-decoration: none; }
    a:hover { text-decoration: underline; }
    .container { max-width: var(--maxw); margin: 0 auto; padding: 0 20px; }

    /* Шапка */
    .site-header {
      border-bottom: 1px solid var(--border);
      background: rgba(15, 17, 21, 0.85);
      backdrop-filter: saturate(180%) blur(10px);
      position: sticky; top: 0; z-index: 10;
    }
    .nav-inner {
      display: flex; align-items: center; justify-content: space-between;
      height: 60px; gap: 16px;
    }
    .brand { font-weight: 700; color: var(--text); font-size: 1.05rem; }
    .nav-right { display: flex; align-items: center; gap: 18px; }
    .nav-links a { color: var(--muted); margin-left: 22px; font-size: 0.95rem; }
    .nav-links a:first-child { margin-left: 0; }
    .nav-links a:hover { color: var(--text); text-decoration: none; }

    /* Переключатель языка */
    .lang-switch { display: flex; align-items: center; gap: 6px; font-size: 0.85rem; }
    .lang-switch a { color: var(--muted); }
    .lang-switch a.active { color: var(--text); font-weight: 700; }
    .lang-switch span { color: var(--border); }

    /* Hero */
    .hero { padding: 72px 20px 32px; text-align: center; }
    .hero h1 { font-size: 2.6rem; margin: 0 0 8px; letter-spacing: -0.5px; }
    .tagline { font-size: 1.25rem; color: var(--accent); margin: 0 0 18px; font-weight: 500; }
    .socials { display: flex; flex-wrap: wrap; gap: 14px; justify-content: center; margin: 16px 0; }
    .social { color: var(--muted); font-size: 0.95rem; }
    .hero-cta { margin-top: 26px; display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }

    /* Кнопки */
    .btn {
      display: inline-block; padding: 11px 20px; border-radius: 10px;
      background: var(--accent); color: #fff; font-weight: 600; font-size: 0.95rem;
    }
    .btn:hover { text-decoration: none; opacity: 0.92; }
    .btn-secondary { background: var(--surface-2); color: var(--text); border: 1px solid var(--border); }

    /* Секции */
    .about { padding: 28px 20px; color: var(--muted); }
    .about p { margin: 0 auto; max-width: 640px; text-align: center; }
    .section { padding: 36px 20px; }
    .section-head { display: flex; align-items: baseline; justify-content: space-between; margin-bottom: 18px; }
    .section-head h2 { margin: 0; font-size: 1.5rem; }
    .see-all { font-size: 0.9rem; color: var(--muted); }
    .page-head { padding: 48px 20px 8px; }
    .page-head h1 { font-size: 2rem; margin: 0 0 8px; }

    /* Карточки проектов */
    .cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 18px; }
    .card {
      background: var(--surface); border: 1px solid var(--border);
      border-radius: var(--radius); padding: 22px; transition: border-color .15s, transform .15s;
    }
    .card:hover { border-color: var(--accent); transform: translateY(-2px); }
    .card h3 { margin: 0 0 8px; font-size: 1.15rem; }
    .card h3 a { color: var(--text); }
    .card-desc { color: var(--muted); margin: 0 0 12px; font-size: 0.95rem; }
    .tech { color: var(--accent); font-size: 0.82rem; font-family: ui-monospace, "SF Mono", Menlo, monospace; margin: 0 0 10px; }
    .card-link { font-size: 0.9rem; font-weight: 600; }

    /* Лента блога */
    .post-list { list-style: none; padding: 0; margin: 0; }
    .post-list li {
      padding: 20px 0; border-bottom: 1px solid var(--border);
    }
    .post-list li:last-child { border-bottom: none; }
    .post-list h3 { margin: 0 0 4px; font-size: 1.2rem; }
    .post-list h3 a { color: var(--text); }
    .meta { color: var(--muted); font-size: 0.85rem; margin: 0 0 6px; }
    .post-desc { color: var(--muted); margin: 0; }

    /* Статья */
    .article { padding: 36px 20px 56px; max-width: 720px; }
    .article h1 { font-size: 2rem; margin: 0 0 6px; }
    .article img { max-width: 100%; border-radius: 10px; }
    .article p code, .article li code {
      background: var(--surface-2); padding: 2px 6px; border-radius: 6px;
      font-family: ui-monospace, "SF Mono", Menlo, monospace; font-size: 0.88em;
    }
    .article pre {
      background: #16181f; border: 1px solid var(--border);
      padding: 16px 18px; border-radius: 12px; overflow-x: auto; line-height: 1.5;
    }
    .article pre code {
      font-family: ui-monospace, "SF Mono", Menlo, monospace; font-size: 0.86rem;
      color: #c8ccd4; background: none; padding: 0;
    }
    /* Splash — подсветка синтаксиса Swift */
    .article pre .keyword { color: #ff6482; font-weight: 600; }
    .article pre .type { color: #b88cff; }
    .article pre .call { color: #4f8cff; }
    .article pre .property { color: #2ec4b6; }
    .article pre .number { color: #e8985e; }
    .article pre .string { color: #f08d5b; }
    .article pre .comment { color: #6b7682; font-style: italic; }
    .article pre .dotAccess { color: #9bc53d; }
    .article pre .preprocessing { color: #d9a441; }

    /* Подвал */
    .site-footer {
      border-top: 1px solid var(--border); margin-top: 40px;
      padding: 30px 20px; text-align: center;
    }
    .copyright { color: var(--muted); font-size: 0.85rem; margin: 12px 0 0; }

    @media (max-width: 600px) {
      .hero h1 { font-size: 2rem; }
      .nav-links a { margin-left: 14px; }
      .nav-right { gap: 10px; }
    }
    """
}
