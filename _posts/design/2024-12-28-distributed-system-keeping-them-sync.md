---
layout: post
title:  "Distributed Systems - Keeping them sync"
date:   2024-12-28 20:50:00
categories: ["Design"]
---

# Write-Ahead Logging

Or WAL, this is a technique to achieve consistency and durability in distributed systems. 
Also, you see this every day, every single database use this, to keep tracking of the changes. 

## How it works

The simplest examples focus on a database—a basic one, without sharding. Before making any changes to the data on the disk, 
you write the changes to a log file. If the database crashes in the middle of a transaction, 
it can recover the actions by referring to the log file.

<img src="{{ site.base_image_path }}wal-sequence.svg" alt="Site Logo">
