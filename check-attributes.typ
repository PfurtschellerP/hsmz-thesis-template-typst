#import "utils.typ": final-thesis-level, is-missing

#let check-attributes(
  thesis-type: none,
  title: none,
  faculty: none,
  degree-program: none,
  submission-date: none,
  confidentiality-period: none,
  ai-declaration-option: none,
  language: none,
  acronyms: none,
  symbols: none,
  bibliography: none,
  appendix: none,
  author: none,
  company: none,
  supervisor: none,
  font: none,
  citation-style: none,
  print-only-used-acronyms: none,
  show-full-bibliography: none,
  show-restriction-notice: none,
  show-management-summary: none,
  show-abstract: none,
  show-word-count: none,
  draft: none,
) = {
  // check thesis-type
  if is-missing(thesis-type) {
    panic("Thesis type is missing")
  }

  // check title
  if is-missing(title) {
    panic("Title is missing")
  }

  // check faculty
  if is-missing(faculty) {
    panic("Faculty is missing")
  }

  // check degree program
  if is-missing(degree-program) {
    panic("Degree program is missing")
  }

  // check submission date
  if is-missing(submission-date) {
    panic("Submission date is missing")
  }

  for (name, date) in (("submission-date", submission-date), ("confidentiality-period", confidentiality-period)) {
    if date != none and type(date) not in (str, content, datetime) {
      panic(name + " must be a date, e.g. datetime(year: 2026, month: 3, day: 31), or a string")
    }
  }

  // check ai declaration option
  if ai-declaration-option not in (1, 2, 3) {
    panic("AI declaration option is missing or out of bounds. Please provide 1, 2 or 3.")
  }

  // check language
  if is-missing(language) {
    panic("Language is missing")
  }

  if language not in ("de", "en") {
    panic("Invalid language. Please use 'de' for German or 'en' for English.")
  }

  // check acronyms
  if type(acronyms) != dictionary {
    panic("Acronyms dictionary is missing or not a dictionary")
  }

  // check symbols
  if type(symbols) != array or symbols.any(it => type(it) != array or it.len() != 2) {
    panic("Symbols must be a list of (symbol, description) pairs, e.g. (($alpha$, [Signifikanzniveau]),)")
  }

  // check literature file
  if is-missing(bibliography) {
    panic("Bibliography is missing")
  }

  // check appendix
  if appendix != none and type(appendix) != content {
    panic("Appendix must be content or none")
  }

  // check author
  if type(author) != dictionary {
    panic("Author is missing or not a dictionary")
  }

  for key in ("name", "matriculation-number", "address") {
    if is-missing(author.at(key, default: none)) {
      panic("Author attribute '" + key + "' is missing")
    }
  }

  if type(author.address) != dictionary {
    panic("Author address must be a dictionary with the keys 'street', 'zip' and 'city'")
  }

  for key in ("street", "zip", "city") {
    if is-missing(author.address.at(key, default: none)) {
      panic("Author address attribute '" + key + "' is missing")
    }
  }

  // check supervisor
  if is-missing(supervisor) {
    panic("Supervisor is missing")
  }

  // check font
  if is-missing(font) or font == () {
    panic("Font is missing")
  }

  // check citation style
  if is-missing(citation-style) {
    panic("Citation style is missing")
  }

  // Check, if settings are boolean
  if type(print-only-used-acronyms) != bool {
    panic("print-only-used-acronyms must be a boolean value")
  }

  if type(show-full-bibliography) != bool {
    panic("show-full-bibliography must be a boolean value")
  }

  if type(show-restriction-notice) != bool {
    panic("show-restriction-notice must be a boolean value")
  }

  if type(show-management-summary) != bool {
    panic("show-management-summary must be a boolean value")
  }

  if type(show-abstract) != bool {
    panic("show-abstract must be a boolean value")
  }

  if type(show-word-count) != bool {
    panic("show-word-count must be a boolean value")
  }

  if type(draft) != bool {
    panic("draft must be a boolean value")
  }

  // final theses need a Management Summary or an Abstract, or both (Leitfaden, Section 2.3)
  if final-thesis-level(thesis-type) != none and not show-management-summary and not show-abstract {
    panic(
      "A "
        + thesis-type
        + " needs a Management Summary or an Abstract (or both). Set show-abstract: true or show-management-summary: true.",
    )
  }

  // company and confidentiality period are only needed for the restriction notice
  if show-restriction-notice {
    if is-missing(company) {
      panic("Company is missing (required for the restriction notice; set show-restriction-notice: false to hide it)")
    }

    if is-missing(confidentiality-period) {
      panic(
        "Confidentiality period is missing (required for the restriction notice; set show-restriction-notice: false to hide it)",
      )
    }
  }
}
