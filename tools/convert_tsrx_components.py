#!/usr/bin/env python3
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

def find_jsx_end(source, start):
    n = len(source)
    i = start
    stack = []
    while i < n:
        if source[i] != "<":
            i += 1
            continue
        if source[i + 1 : i + 2] == ">":
            stack.append("")
            i += 2
        elif source[i + 1 : i + 2] == "/":
            j = i + 2
            name = ""
            while j < n and source[j] not in ">":
                name += source[j]
                j += 1
            if j >= n or source[j] != ">":
                return -1
            if stack:
                stack.pop()
            i = j + 1
            if not stack:
                return i
        else:
            j = i + 1
            name = ""
            while j < n and source[j] not in ">/ \t\n":
                name += source[j]
                j += 1
            self_closing = False
            while j < n:
                c = source[j]
                if c == "{":
                    depth = 1
                    j += 1
                    while j < n and depth > 0:
                        qc = source[j]
                        if qc in "\"'`":
                            j += 1
                            while j < n and source[j] != qc:
                                if source[j] == "\\":
                                    j += 2
                                else:
                                    j += 1
                            continue
                        if source[j] == "{":
                            depth += 1
                        elif source[j] == "}":
                            depth -= 1
                        j += 1
                    continue
                if c in "\"'":
                    qc = c
                    j += 1
                    while j < n and source[j] != qc:
                        if source[j] == "\\":
                            j += 2
                        else:
                            j += 1
                    if j < n:
                        j += 1
                    continue
                if c == ">":
                    j += 1
                    break
                if c == "/" and source[j + 1 : j + 2] == ">":
                    self_closing = True
                    j += 2
                    break
                j += 1
            if not self_closing:
                stack.append(name)
            i = j
        if not stack:
            return i
    return -1

def find_final_jsx_return(body):
    n = len(body)
    i = 0
    depth = 0
    string_char = None
    last_return = None
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
        if c == "{":
            depth += 1
            i += 1
            continue
        if c == "}":
            depth -= 1
            i += 1
            continue
        if depth == 0 and body.startswith("return", i):
            after = i + 6
            if after < n and (body[after].isalnum() or body[after] == "_"):
                i += 1
                continue
            last_return = (i, after)
            i = after
            continue
        i += 1
    if last_return is None:
        return None
    ret_start, expr_start = last_return
    while expr_start < n and body[expr_start].isspace():
        expr_start += 1
    paren = False
    if expr_start < n and body[expr_start] == "(":
        paren = True
        expr_start += 1
        while expr_start < n and body[expr_start].isspace():
            expr_start += 1
    if expr_start >= n or body[expr_start] != "<":
        return None
    expr_end = find_jsx_end(body, expr_start)
    if expr_end == -1:
        return None
    if paren:
        while expr_end < n and body[expr_end].isspace():
            expr_end += 1
        if expr_end < n and body[expr_end] == ")":
            expr_end += 1
    while expr_end < n and body[expr_end].isspace():
        expr_end += 1
    if expr_end < n and body[expr_end] == ";":
        expr_end += 1
    return (ret_start, expr_end)

def find_functions(source):
    results = []
    n = len(source)
    i = 0
    while i < n:
        m = re.match(r"(export\s+)?function\b", source[i:])
        if m:
            line_start = source.rfind("\n", 0, i) + 1
            if re.fullmatch(r"(?:export\s+)?", source[line_start:i]):
                j = i + m.end()
                while j < n and source[j].isspace():
                    j += 1
                name_m = re.match(r"[A-Za-z_$][\w$]*", source[j:])
                if name_m:
                    j += name_m.end()
                    # skip generics <...>
                    if j < n and source[j] == "<":
                        depth = 1
                        j += 1
                        while j < n and depth > 0:
                            if source[j] == "<":
                                depth += 1
                            elif source[j] == ">":
                                depth -= 1
                            j += 1
                    if j < n and source[j] == "(":
                        depth = 1
                        j += 1
                        while j < n and depth > 0:
                            if source[j] == "(":
                                depth += 1
                            elif source[j] == ")":
                                depth -= 1
                            j += 1
                        # optional return type
                        while j < n and source[j].isspace():
                            j += 1
                        if j < n and source[j] == ":":
                            depth = 0
                            while j < n:
                                c = source[j]
                                if c in "([{<":
                                    depth += 1
                                elif c in ")}]>":
                                    depth -= 1
                                elif c == "{" and depth == 0:
                                    break
                                j += 1
                        if j < n and source[j] == "{":
                            body_end = find_matching_brace(source, j)
                            if body_end != -1:
                                results.append((j, body_end))
                                i = body_end + 1
                                continue
            i = i + m.end()
            continue
        i += 1
    return results

def convert_file(path):
    source = path.read_text(encoding="utf-8")
    original = source
    funcs = find_functions(source)
    replacements = []
    for body_start, body_end in funcs:
        body = source[body_start + 1 : body_end]
        ret = find_final_jsx_return(body)
        if ret is None:
            continue
        ret_start, expr_end = ret
        before = body[:ret_start]
        expr = body[ret_start + 6 : expr_end].lstrip()
        after = body[expr_end:]
        new_body = before + expr + after
        replacements.append((body_start, body_end + 1, "@{" + new_body + "}"))
    replacements.sort(reverse=True)
    for start, end, text in replacements:
        source = source[:start] + text + source[end:]
    if source != original:
        path.write_text(source, encoding="utf-8")
        return True
    return False

for arg in sys.argv[1:]:
    p = Path(arg)
    if p.is_dir():
        for f in p.rglob("*.tsrx"):
            if convert_file(f):
                print(f)
    else:
        if convert_file(p):
            print(p)
