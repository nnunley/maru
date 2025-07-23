# Maru Metacircular Compiler - Detailed Technical Documentation

## Overview

This document provides a deep technical understanding of Maru's metacircular compiler loop, focusing on the bootstrap process, compilation stages, and the relationships between key files. This supplements the general architecture documentation with specific implementation details relevant to the current development work.

## Development Guidelines

### Key Practices
- Don't modify c files - they generated artifacts

## The Metacircular Compiler Loop

### What is a Metacircular Compiler?

A metacircular compiler is a self-hosting compiler written in the language it compiles. Maru achieves this through a carefully orchestrated bootstrap process that progressively builds more sophisticated versions of itself.

[... rest of the existing content remains unchanged ...]