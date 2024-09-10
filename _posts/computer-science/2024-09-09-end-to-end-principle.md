---
layout: post
title:  "End-to-end principle (don't mess with my layers)"
date:   2024-09-09 22:50:00
categories: ["Computer Science"]
---

This concept was firstly find in [packet switching](https://en.wikipedia.org/wiki/Packet_switching) by Donald Davies, 
it's a network/software architecture design paradigm that says: 
"Specific functions in a distributed system should be implemented at endpoints rather than in network layer”.
In other words, we should specify or functions in application layer whenever possible.

Supposing you are a developer, you can see this every were you look at, since every web framework follows this. 
Even smart people avoid creating unnecessary middle layers. Why are you deliberately adding complexity? 
This approach is reckless and counterproductive ~~(also, you're not so smart—I'm included in that.)~~

This is satisfied in security, when we need to encrypt or decrypt something, we rely on endpoints, 
see the HTTPS or SSL/TLS. Lesgo deeper! TCP works that way, just remember the network classes, it depends on sender and receiver. 

Thanks, bye!

### References

https://en.wikipedia.org/wiki/End-to-end_principle
