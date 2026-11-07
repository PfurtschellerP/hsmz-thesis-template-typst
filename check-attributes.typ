// helper: true if a value is missing (none or an empty string)
#let is-missing(value) = value == none or value == ""

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

  // check confidentiality period
  if is-missing(confidentiality-period) {
    panic("Confidentiality period is missing")
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
}
