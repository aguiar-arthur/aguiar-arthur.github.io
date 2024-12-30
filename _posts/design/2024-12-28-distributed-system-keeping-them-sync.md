---
layout: post
title:  "Distributed Systems - Keeping them sync"
date:   2024-12-28 20:50:00
categories: ["Design"]
tags: ["Distributed Systems"]
---

# Write-Ahead Logging and syncrhony

Or WAL, this is a technique to achieve consistency and durability in distributed systems. 
Also, you see this every day, every single database use this, to keep tracking of the changes. 

## How it works

The simplest examples focus on a database—a basic one, without sharding. Before making any changes to the data on the disk, 
you write the changes to a log file. If the database crashes in the middle of a transaction, 
it can recover the actions by referring to the log file.

<img src="{{ site.url }}{{ site.base_image_path }}wal-sequence.svg" alt="WAL Sequence">

## Multiple nodes

But I'm talking about DISTRIBUTED systems, our first examples is pretty simple. 
Let's imagine that we have distributed nodes, and they need to be in sync. 

### Leadership

First of all, you will need a main node. The main node is responsible for the system changes, ordering, and the replication. 

### To mantain the leadership

The principal strategies to keep the leadership is the heartbeats and health checks, the lead node send periodic signal to the other nodes, 
basically saying "I'm alive!". 
If followers stop receiving heartbeats within a predefined timeout, they assume the leader has failed. 
This triggers a leader election to ensure continued operation of the system.

Each time the followers receive a heartbeat, they reset their election timers upon receiving a heartbeat, avoiding unnecessary elections.

**Note:** Each signal send a metadata, with a index pointing the commited changes. 

<img src="{{ site.url }}{{ site.base_image_path }}heartbeat-sequence.svg" alt="Heartbeat Sequence">

### Quorum 

A quorum is a mechanism used to ensure consistency and coordination across multiple nodes when processing operations.
A subset of nodes must agree on an operation before it is considered valid or complete. The quorum is the trashhold, on how much nodes need to have the data commited, 
or in a election, how much votes a node need to be the leader.

### Election 

Every time a leader node is down, an election is made.
Every up and running node broadcasts vote requests to all other nodes, asking for their support in the current term.
A term is a counter, used to track the the timeline of the leadership, it is helpful to differentiate the nodes. 
Another block of the broadcast data, is the index of the last log entry in the candidate's log. 

**There are some rules to vote in a node:** 
- If the candidate's term is lower than the node's current term:
    - Reject the request.
- If the candidate's term is equal to or greater than the node's term:
    - Proceed to the next checks.
- Each node can only vote once per term.
- If the candidate's log is at least as complete as the node's log:
    - Grant the vote.

<img src="{{ site.url }}{{ site.base_image_path }}election-sequence.svg" alt="Election Sequence">

### Thanks, bye!

## References

- FORD, Brendan. Patterns of Distributed Systems. Addison-Wesley Signature Series (Fowler). Boston: Addison-Wesley, 2023.
