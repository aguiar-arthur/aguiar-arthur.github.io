---
layout: post
title:  "Datomic - Ident"
date:   2026-03-23 00:30:00
categories: ["Programming"]
tags: ["Clojure"]
---

<img width="600" src="{{ '/assets/images/annotations/programming/clojure/2026-03-23-datomic-ident.jpeg' | relative_url }}" alt="Handwritten notes on Datomic idents (transcription below)">

<details markdown="1">
<summary>Transcription of the handwritten notes</summary>

**Datomic ident**

Ident gives to a machine, a readable name to an entity. Like a unique tag or keyword that maps a human-friendly name to a numeric entity ID.

Everything in Datomic is an entity with a numeric `db/id`, that way we can attribute a keyword for the ID.

- Under the hood: Datomic keeps a lookup table for idents.
  - The mapping of ident to ID is kept in memory.
  - The resolution is made by a long integer being logged and attached to a keyword.
- We can bind it to an enum: `[{:db/ident :tier/gold}]`

</details>
