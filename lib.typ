// External package imports
#import "@preview/acrostiche:0.7.0": acr, acrf, acrfpl, acrpl, init-acronyms, print-index // Acronyms - https://typst.app/universe/package/acrostiche/
#import "@preview/wordometer:0.1.6": word-count-of // Word count - https://typst.app/universe/package/wordometer/

// static pages, locale and helper functions
#import "static-pages.typ": declaration-of-originality, restriction-notice, title-page
#import "locale.typ": (
  ABSTRACT, APPENDIX, BIBLIOGRAPHY, FORMULA, LIST_OF_ABBREVIATIONS, LIST_OF_APPENDICES, LIST_OF_FIGURES,
  LIST_OF_FORMULAS, LIST_OF_TABLES, MANAGEMENT_SUMMARY, NOTE, WORD_COUNT,
)
#import "check-attributes.typ": check-attributes

// outlined outline for figures, tables, etc. that itself is outlined in the table of contents
#let outlined-outline(..args) = {
  show outline: set heading(outlined: true)
  outline(..args)
}

// note below a figure or table, e.g. for the source ("Anmerkung. Eigene Darstellung.")
// usage: #figure(table(...) + figure-note[Eigene Darstellung.], caption: [...])
#let figure-note(body) = context block(width: 100%, above: 0.65em, align(left, text(size: 0.9em)[
  #emph(NOTE.at(text.lang, default: NOTE.en)). #body
]))

// main entrypoint for this template
#let hsmz-thesis-unofficial(
  // thesis data
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
  management-summary: [],
  abstract: [],
  // people
  author: (:),
  company: none,
  supervisor: none,
  // settings
  font: ("Arial", "Liberation Sans", "Arimo"),
  citation-style: "apa",
  print-only-used-acronyms: true,
  show-full-bibliography: false,
  show-restriction-notice: true,
  show-management-summary: false,
  show-abstract: true,
  show-word-count: true,
  body,
) = {
  check-attributes(
    thesis-type: thesis-type,
    title: title,
    faculty: faculty,
    degree-program: degree-program,
    submission-date: submission-date,
    confidentiality-period: confidentiality-period,
    ai-declaration-option: ai-declaration-option,
    language: language,
    acronyms: acronyms,
    bibliography: bibliography,
    appendix: appendix,
    author: author,
    company: company,
    supervisor: supervisor,
    font: font,
    citation-style: citation-style,
    print-only-used-acronyms: print-only-used-acronyms,
    show-full-bibliography: show-full-bibliography,
    show-restriction-notice: show-restriction-notice,
    show-management-summary: show-management-summary,
    show-abstract: show-abstract,
    show-word-count: show-word-count,
  )

  // global page and text settings (Leitfaden, Section 2.4)
  set text(
    font: font,
    size: 11pt,
    lang: language,
  )
  set document(
    title: title,
    author: author.name,
  )
  set page(
    paper: "a4",
    margin: (top: 2cm, bottom: 2cm, left: 4.5cm, right: 1.5cm),
  )
  // Typst's `leading` is the gap between two lines, not the line pitch: with Arial, a leading of 1em results in a
  // baseline-to-baseline distance of ~1.7em, which matches 1.5 line spacing in word processors.
  set par(
    leading: 1em,
    spacing: 2em,
    justify: true,
  )

  // footnotes at the bottom of the page, justified with a hanging indent (Leitfaden, Section 2.4)
  show footnote.entry: it => {
    let loc = it.note.location()
    let number = numbering(it.note.numbering, ..counter(footnote).at(loc))
    grid(
      columns: (1.5em, 1fr),
      link(loc, super(number)), par(justify: true, it.note.body),
    )
  }

  // formulas are numbered on the right and listed in the list of formulas (Leitfaden, Section 2.3). To leave out a
  // single formula, use `#math.equation(block: true, numbering: none, $ ... $)`.
  set math.equation(numbering: "(1)", supplement: FORMULA.at(language))

  // pre-text
  if show-restriction-notice {
    restriction-notice(title, company, confidentiality-period)
  }

  title-page(
    thesis-type,
    title,
    faculty,
    degree-program,
    submission-date,
    supervisor,
    author,
    language,
  )

  declaration-of-originality(
    ai-declaration-option,
    author,
    title,
    degree-program,
    supervisor,
    submission-date,
  )

  // Styling of individual elements
  // Margin for headings to make them more visually pleasing
  show heading.where(level: 1): set block(below: 1em)
  show heading.where(level: 2): set block(above: 1.5em, below: 1.5em)
  show heading.where(level: 3): set block(above: 1.5em, below: 1.5em)

  // Captions above figures and tables in APA style (Leitfaden, Section 3.10):
  // bold label ("Abbildung 1") followed by the title in italics on the next line
  set figure.caption(position: top)
  show figure.caption: it => block(width: 100%, align(left, [
    #text(weight: "bold")[#it.supplement #context it.counter.display(it.numbering)]\
    #emph(it.body)
  ]))

  if show-management-summary {
    heading(MANAGEMENT_SUMMARY.at(language), outlined: false, level: 1)
    management-summary
    pagebreak()
  }

  if show-abstract {
    heading(ABSTRACT.at(language), outlined: false, level: 1)
    abstract
    pagebreak()
  }

  // reset heading and page numbers for listings
  counter(heading).update(0)
  counter(page).update(1)

  // adjust page numbering and headings for the listings
  set page(
    numbering: "I",
  )
  set heading(
    numbering: none,
  )

  show table: set par(
    leading: 0.8em,
    justify: true,
  )
  set table(stroke: 0.5pt, align: left)
  show table.cell.where(y: 0): set text(weight: "bold")
  set table(
    fill: (_, y) => if y == 0 { rgb("#e7e6e6") },
  )

  // listings
  outline()
  pagebreak()

  // the lists of figures and tables are only required if figures or tables are used (Leitfaden, Section 2.3)
  context if query(figure.where(kind: image)).len() > 0 {
    outlined-outline(
      title: [#LIST_OF_FIGURES.at(language)],
      target: figure.where(kind: image),
    )
    pagebreak()
  }

  context if query(figure.where(kind: table)).len() > 0 {
    outlined-outline(
      title: [#LIST_OF_TABLES.at(language)],
      target: figure.where(kind: table),
    )
    pagebreak()
  }

  init-acronyms(
    acronyms,
  )
  print-index(
    title: [#LIST_OF_ABBREVIATIONS.at(language)],
    outlined: true,
    used-only: print-only-used-acronyms,
    sorted: "up",
    row-gutter: 10pt,
  )

  // the list of formulas is only required if formulas are used (Leitfaden, Section 2.3); it lists every numbered
  // formula with its number, the formula itself and the page
  context if query(math.equation.where(block: true)).any(it => it.numbering != none) {
    pagebreak()
    show outline.entry: it => {
      let formula = it.element
      if formula.numbering == none { return none }
      let number = numbering(formula.numbering, ..counter(math.equation).at(formula.location()))
      link(formula.location(), it.indented(number, [
        #math.equation(block: false, formula.body) #box(width: 1fr, it.fill) #it.page()
      ]))
    }
    outlined-outline(
      title: [#LIST_OF_FORMULAS.at(language)],
      target: math.equation.where(block: true),
    )
  }

  [#metadata(none) <hsmz-end-of-listings>] // last page of the listings, see below

  pagebreak()

  // reset counters and switch to numeric numbering for the content
  counter(heading).update(0)
  counter(page).update(1)
  set heading(
    numbering: "1.1",
  )
  set page(
    numbering: "1",
  )

  // content
  body

  // word count of the main text (Leitfaden, Section 2.3). Figures, tables and citations are not counted; any other
  // content can be excluded by attaching the label <no-wc> to it.
  if show-word-count {
    let count = word-count-of(body, exclude: (figure, table, <no-wc>)).words
    block(above: 2em, [#WORD_COUNT.at(language): #count])
  }

  // post-text

  // switch back to roman numbering, continuing after the listings
  set heading(
    numbering: none,
  )

  // (changing the page settings starts a new page)
  set page(
    numbering: "I",
  )
  // retrieve last page before the content started from labels using context
  context counter(page).update(counter(page).at(<hsmz-end-of-listings>).first() + 1)

  set std.bibliography(
    title: BIBLIOGRAPHY.at(language),
    style: citation-style,
    full: show-full-bibliography,
  )
  bibliography

  // If appendix is provided, show it here
  if appendix != none {
    pagebreak()

    let appendix-supplement = [#APPENDIX.at(language)]

    outlined-outline(
      title: [#LIST_OF_APPENDICES.at(language)],
      target: heading.where(supplement: appendix-supplement),
    )

    pagebreak()

    set heading(numbering: "A.1", supplement: appendix-supplement)
    counter(heading).update(0)

    appendix
  }
}
