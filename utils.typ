// helper: true if a value is missing (none or an empty string)
#let is-missing(value) = value == none or value == ""

// "bachelor" or "master" for final theses (Abschlussarbeiten), none for other papers (e.g. Hausarbeit, Praxisbericht).
// The Leitfaden has additional requirements for final theses, e.g. a Management Summary or Abstract and a guideline for
// the number of words.
#let final-thesis-level(thesis-type) = {
  let type = lower(thesis-type)
  if type.contains("bachelor") { "bachelor" } else if type.contains("master") { "master" } else { none }
}
