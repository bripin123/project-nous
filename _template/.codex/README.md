---
created: 2026-04-13
type: guide
tags:
  - codex
  - adapter
  - maintenance
aliases: [Codex Adapter Guide]
---

# Codex Adapter Guide

## Purpose

This directory holds Codex-only routing shims for reserved inputs such as `start` and `sync`.

## Rules

- Keep shared procedure details in `AGENTS.md` and `docs/protocols/*.md`.
- Use `.codex/commands/*.md` only for Codex-specific routing and execution obligations.
- If protocol behavior changes, update the shared protocol first, then adjust `.codex` references.
- Do not mirror or fork Claude settings here.
- Use slashless Codex triggers when the Codex CLI would otherwise intercept an unknown slash command before model dispatch.
