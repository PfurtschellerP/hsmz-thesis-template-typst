#import "lib.typ": *


#show: hsmz-thesis.with(
  thesis-type: "Master's Thesis",
  title: "Typst Template",
  faculty: "Wirtschaft",
  degree-program: "IT-Management",
  submission-date: "01.01.2026",
  confidentiality-period: "01.01.2036",
  ai-declaration-option: 1,
  language: "en",
  acronyms: (
    "IT": "Information Technology",
  ),
  literature-file: "./literature.bib",
  author: (
    name: "Max Musterman",
    matriculation-number: "12345",
    address: (street: "Musterstraße 1", zip: "12345", city: "Musterstadt"),
    signature-file: "./sample-signature.png",
  ),
  company: "Musterfirma",
  supervisor: "Prof. Dr. Muster",
  citation-style: "apa",
  print-only-used-acronyms: true,
  show-full-bibliography: false,
)



= Einleitung

lalalalalalal

== Forschungsfrage

#acr("IT")

Forschungsmethoden von @wildeForschungsmethodenWirtschaftsinformatikEmpirische2007.

= Theorie

= Praxis

= Diskussion

= Zusammenfassung
