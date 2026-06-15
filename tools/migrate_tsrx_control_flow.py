#!/usr/bin/env python3
"""
Best-effort TSRX control-flow migration.
Only touches .tsrx files. Intended to be followed by `bun --filter website build`
to catch anything it misses.
"""
import re
import sys
from pathlib import Path

def find_matching_brace(source, open_idx):
    if source[open_idx] != "{":
        return -1
    i = open_idx + 1
    depth = 1
    n = len(source)
    string_char = None
    while i < n:
        c = source[i]
        if string_char:
            if c == "\\":
                i += 2
                continue
            if c == string_char:
                string_char = None
            i += 1
            continue
        if c in "\"'`":
            string_char = c
            i += 1
            continue
        if c == "/" and source[i + 1 : i + 2] == "//":
            while i < n and source[i] != "\n":
                i += 1
            continue
        if c == "/" and source[i + 1 : i + 2] == "*":
            while i < n and not (source[i] == "*" and source[i + 1 : i + 2] == "/"):
                i += 1
            i += 2
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1

def body_contains_jsx(body):
    """Return True if body contains a real JSX element/fragment (not just a
    bare '<', which also appears in comparisons like `i <= 0` and generics like
    `Map<K, V>`). JSX is recognized by its structural markers — a closing
    tag/fragment `</`, an empty fragment `<>`, or a self-closing `/>` — none of
    which occur in comparison or generic syntax. Strings/comments are skipped.
    Limitation: a regex literal containing `/>` could still trip this; the AST
    checker (tools/check-tsrx-directives.mjs) is the authoritative verification."""
    n = len(body)
    i = 0
    string_char = None
    while i < n:
        c = body[i]
        if string_char:
            if c == "\\":
                i += 2
                continue
            if c == string_char:
                string_char = None
            i += 1
            continue
        if c in "\"'`":
            string_char = c
            i += 1
            continue
        if c == "/" and body[i + 1 : i + 2] == "//":
            while i < n and body[i] != "\n":
                i += 1
            continue
        if c == "/" and body[i + 1 : i + 2] == "*":
            while i < n and not (body[i] == "*" and body[i + 1 : i + 2] == "/"):
                i += 1
            i += 2
            continue
        # JSX structural markers only — a bare `<` (comparison/generic) is not
        # enough; requiring `</`, `<>`, or `/>` is what stops plain loops like
        # `for (...) { if (i <= 0) ... }` from being mis-converted to `@for`.
        nxt = body[i + 1 : i + 2]
        if (c == "<" and nxt in (">", "/")) or (c == "/" and nxt == ">"):
            return True
        i += 1
    return False

def is_guard_return_body(body):
    """Heuristic: body is only `return <JSX>;` possibly with parentheses."""
    stripped = body.strip()
    if not stripped.startswith("return"):
        return False
    after = stripped[6:].strip()
    if after.startswith("(") and after.endswith(");"):
        inner = after[1:-2].strip()
        return inner.startswith("<")
    if after.endswith(";"):
        inner = after[:-1].strip()
        return inner.startswith("<")
    return after.startswith("<")

def find_opening_brace(source, start):
    """Find the first '{' after start, skipping strings/comments/parentheses."""
    i = start
    n = len(source)
    string_char = None
    while i < n:
        c = source[i]
        if string_char:
            if c == "\\":
                i += 2
                continue
            if c == string_char:
                string_char = None
            i += 1
            continue
        if c in "\"'`":
            string_char = c
            i += 1
            continue
        if c == "/" and source[i + 1 : i + 2] == "//":
            while i < n and source[i] != "\n":
                i += 1
            continue
        if c == "/" and source[i + 1 : i + 2] == "*":
            while i < n and not (source[i] == "*" and source[i + 1 : i + 2] == "/"):
                i += 1
            i += 2
            continue
        if c == "{":
            return i
        i += 1
    return -1

def convert_dynamic_tags(source):
    source = re.sub(r"<@([A-Za-z_$][\w$]*)\b", r"<{\1.value}", source)
    source = re.sub(r"</@([A-Za-z_$][\w$]*)\b", r"</{\1.value}", source)
    return source

def convert_try_blocks(source):
    """Convert try/pending/catch blocks that contain JSX to template directives."""
    n = len(source)
    # Find `try {` not already `@try {`
    replacements = []
    for m in re.finditer(r"(?s)(?<!@)\btry\s*\{", source):
        # The match ends at the opening brace. Find matching brace.
        open_idx = m.end() - 1
        close_idx = find_matching_brace(source, open_idx)
        if close_idx == -1:
            continue
        body = source[open_idx + 1 : close_idx]
        if not body_contains_jsx(body):
            continue
        # prefix try
        try_start = m.start()
        replacements.append((try_start, try_start + 3, "@try"))
        # scan after close_idx for pending/catch
        i = close_idx + 1
        while i < n:
            # skip whitespace
            while i < n and source[i].isspace():
                i += 1
            if source.startswith("pending", i):
                pend_start = i
                pend_open = find_opening_brace(source, pend_start + 7)
                if pend_open != -1 and source[pend_open] == "{":
                    replacements.append((pend_start, pend_start + 7, "@pending"))
                    i = find_matching_brace(source, pend_open) + 1
                    continue
            if source.startswith("catch", i):
                catch_start = i
                catch_open = find_opening_brace(source, catch_start + 5)
                if catch_open != -1 and source[catch_open] == "{":
                    replacements.append((catch_start, catch_start + 5, "@catch"))
                    i = find_matching_brace(source, catch_open) + 1
                    continue
            break
    replacements.sort(reverse=True)
    for start, end, text in replacements:
        source = source[:start] + text + source[end:]
    return source

def convert_if_for_blocks(source):
    """Convert if/for blocks whose body contains JSX and aren't lone guard returns."""
    n = len(source)
    replacements = []
    for pattern in [r"(?s)(?<!@)\bif\s*\(", r"(?s)(?<!@)\bfor\s*\("]:
        for m in re.finditer(pattern, source):
            # find the opening brace of the block
            open_idx = find_opening_brace(source, m.end() - 1)
            if open_idx == -1 or source[open_idx] != "{":
                continue
            close_idx = find_matching_brace(source, open_idx)
            if close_idx == -1:
                continue
            body = source[open_idx + 1 : close_idx]
            if not body_contains_jsx(body):
                continue
            if pattern.startswith(r"(?s)(?<!@)\bif") and is_guard_return_body(body):
                continue
            # prefix keyword
            kw_start = m.start()
            if pattern.startswith(r"(?s)(?<!@)\bif"):
                replacements.append((kw_start, kw_start + 2, "@if"))
            else:
                replacements.append((kw_start, kw_start + 3, "@for"))
            # For if blocks, also convert else/else-if continuations that contain JSX
            if pattern.startswith(r"(?s)(?<!@)\bif"):
                i = close_idx + 1
                while i < n:
                    while i < n and source[i].isspace():
                        i += 1
                    if source.startswith("else", i):
                        else_start = i
                        # else if?
                        after_else = i + 4
                        while after_else < n and source[after_else].isspace():
                            after_else += 1
                        if source.startswith("if", after_else):
                            # leave else-if alone for now; compiler will complain if unsupported
                            break
                        else_open = find_opening_brace(source, else_start + 4)
                        if else_open != -1 and source[else_open] == "{":
                            else_close = find_matching_brace(source, else_open)
                            if else_close != -1:
                                else_body = source[else_open + 1 : else_close]
                                if body_contains_jsx(else_body):
                                    replacements.append((else_start, else_start + 4, "@else"))
                                    i = else_close + 1
                                    continue
                    break
    replacements.sort(reverse=True)
    for start, end, text in replacements:
        source = source[:start] + text + source[end:]
    return source

def migrate_file(path):
    source = path.read_text(encoding="utf-8")
    original = source
    source = convert_dynamic_tags(source)
    source = convert_try_blocks(source)
    source = convert_if_for_blocks(source)
    if source != original:
        path.write_text(source, encoding="utf-8")
        return True
    return False

for arg in sys.argv[1:]:
    p = Path(arg)
    if p.is_dir():
        for f in p.rglob("*.tsrx"):
            if migrate_file(f):
                print(f)
    else:
        if migrate_file(p):
            print(p)
