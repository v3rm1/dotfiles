#!/usr/bin/env python3
"""Check BibTeX entries against Crossref and Semantic Scholar; report wrong metadata and published preprints.

For each entry (optionally only those cited in the given .tex files):
  - DOI present: fetch the Crossref record; compare title, year, first author, venue.
  - No DOI: search Crossref by title and author; flag a confident match whose DOI is missing from the entry.
  - arXiv preprint: ask Semantic Scholar whether a peer-reviewed version exists (cite that instead).
Writes a Markdown report; changes nothing in the .bib.

Usage:
  check_bib.py refs.bib                        # every entry
  check_bib.py refs.bib --tex main.tex sec/*.tex  # only cited entries
  check_bib.py refs.bib --out bib-check.md
"""
from __future__ import annotations

import argparse
import difflib
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

UA = {"User-Agent": "bib-check/1.0 (citation metadata verification)"}
if os.environ.get("S2_API_KEY"):  # optional; raises the Semantic Scholar rate limit
    UA["x-api-key"] = os.environ["S2_API_KEY"]
S2_FIELDS = "title,year,venue,publicationVenue,externalIds,publicationTypes"


def get_json(url: str, retries: int = 3):
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=25) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code == 404:
                return None
            if e.code == 429:
                time.sleep(3 * (attempt + 1))
                continue
            return None
        except Exception:
            time.sleep(1)
    return None


# ---------------------------------------------------------------- bib parsing

def parse_bib(text: str) -> list[dict]:
    entries = []
    for m in re.finditer(r"@(\w+)\s*\{\s*([^,\s]+)\s*,", text):
        kind, key = m.group(1).lower(), m.group(2)
        if kind in ("comment", "string", "preamble"):
            continue
        i, depth = m.end(), 1
        while i < len(text) and depth:
            depth += {"{": 1, "}": -1}.get(text[i], 0)
            i += 1
        body = text[m.end():i - 1]
        fields = {}
        for f in re.finditer(r"(\w+)\s*=\s*", body):
            j = f.end()
            if j < len(body) and body[j] == "{":
                d, k = 1, j + 1
                while k < len(body) and d:
                    d += {"{": 1, "}": -1}.get(body[k], 0)
                    k += 1
                value = body[j + 1:k - 1]
            elif j < len(body) and body[j] == '"':
                k = body.index('"', j + 1)
                value = body[j + 1:k]
            else:
                value = re.match(r"[^,\n]*", body[j:]).group(0)
            fields.setdefault(f.group(1).lower(), value.strip())
        entries.append({"type": kind, "key": key, **fields})
    return entries


def cited_keys(tex_files: list[Path]) -> set[str]:
    keys = set()
    for p in tex_files:
        for m in re.finditer(r"\\(?:[a-zA-Z]*cite[a-zA-Z]*)\*?(?:\[[^\]]*\]){0,2}\{([^}]*)\}", p.read_text(errors="ignore")):
            keys |= {k.strip() for k in m.group(1).split(",") if k.strip()}
    return keys


def clean(s: str) -> str:
    s = re.sub(r"\\[a-zA-Z]+\s*", "", s or "")
    return re.sub(r"[^a-z0-9 ]", "", re.sub(r"[{}]", "", s).lower()).strip()


def similar(a: str, b: str) -> float:
    return difflib.SequenceMatcher(None, clean(a), clean(b)).ratio()


def first_surname(authors: str) -> str:
    first = re.split(r"\s+and\s+", authors or "")[0]
    name = first.split(",")[0] if "," in first else (first.split() or [""])[-1]
    return clean(name)


# ---------------------------------------------------------------- lookups

def crossref_doi(doi: str):
    d = get_json(f"https://api.crossref.org/works/{urllib.parse.quote(doi)}")
    return d["message"] if d and "message" in d else None


def crossref_search(title: str, author: str):
    q = urllib.parse.urlencode({"query.bibliographic": title, "query.author": author, "rows": 3})
    d = get_json(f"https://api.crossref.org/works?{q}")
    items = (d or {}).get("message", {}).get("items", [])
    best = max(items, key=lambda it: similar(title, (it.get("title") or [""])[0]), default=None)
    return best if best and similar(title, (best.get("title") or [""])[0]) > 0.9 else None


def arxiv_id(e: dict) -> str | None:
    for field in ("eprint", "journal", "url", "note", "doi", "howpublished"):
        m = re.search(r"(\d{4}\.\d{4,5})(v\d+)?", e.get(field, ""))
        if m and (field == "eprint" or "arxiv" in e.get(field, "").lower() or "arxiv" in e.get("archiveprefix", "").lower()):
            return m.group(1)
    return None


def s2_published_version(aid: str):
    time.sleep(1.1)  # unauthenticated Semantic Scholar: about 1 request per second
    d = get_json(f"https://api.semanticscholar.org/graph/v1/paper/arXiv:{aid}?fields={S2_FIELDS}")
    if not d:
        return None
    venue = (d.get("publicationVenue") or {}).get("name") or d.get("venue") or ""
    doi = (d.get("externalIds") or {}).get("DOI")
    if venue and "arxiv" not in venue.lower() and (doi is None or "arxiv" not in doi.lower()):
        return {"venue": venue, "year": d.get("year"), "doi": doi}
    return None


def s2_match(title: str):
    time.sleep(1.1)  # unauthenticated Semantic Scholar: about 1 request per second
    q = urllib.parse.quote(title)
    d = get_json(f"https://api.semanticscholar.org/graph/v1/paper/search/match?query={q}&fields={S2_FIELDS}")
    hit = ((d or {}).get("data") or [None])[0]
    return hit if hit and similar(title, hit.get("title", "")) > 0.9 else None


def s2_venue(hit: dict) -> str:
    venue = (hit.get("publicationVenue") or {}).get("name") or hit.get("venue") or ""
    return "" if "arxiv" in venue.lower() else venue


def cr_year(rec: dict):
    for k in ("published-print", "published-online", "issued"):
        parts = (rec.get(k) or {}).get("date-parts") or [[None]]
        if parts[0][0]:
            return parts[0][0]
    return None


# ---------------------------------------------------------------- checks

def check(e: dict) -> list[str]:
    issues = []
    title, year = e.get("title", ""), e.get("year", "")
    doi = re.sub(r"^https?://(dx\.)?doi\.org/", "", e.get("doi", "")).strip()
    rec = None
    if doi and "arxiv" not in doi.lower():
        rec = crossref_doi(doi)
        if rec is None:
            issues.append(f"DOI `{doi}` does not resolve in Crossref")
    elif title and not arxiv_id(e):
        rec = crossref_search(title, first_surname(e.get("author", "")))
        if rec:
            issues.append(f"missing DOI; Crossref match `{rec.get('DOI')}`")
    if rec:
        rtitle = (rec.get("title") or [""])[0]
        if title and similar(title, rtitle) < 0.85:
            issues.append(f"title differs from Crossref: \"{rtitle}\"")
        ry = cr_year(rec)
        if ry and year and str(ry) != str(year).strip("{}"):
            issues.append(f"year {year} vs Crossref {ry}")
        rauth = (rec.get("author") or [{}])[0].get("family", "")
        if rauth and e.get("author") and clean(rauth) not in clean(e["author"]):
            issues.append(f"first author \"{rauth}\" (Crossref) not found in author field")
    aid = arxiv_id(e)
    if aid:
        pub = s2_published_version(aid)
        if pub:
            issues.append(f"arXiv {aid} is published: {pub['venue']} {pub['year']}"
                          + (f", DOI `{pub['doi']}`" if pub["doi"] else "") + "; cite the published version")
    if not rec and title:
        # No Crossref record (conference papers often have no DOI): check year and venue with Semantic Scholar.
        hit = s2_match(title)
        if hit:
            if hit.get("year") and year and str(hit["year"]) != str(year).strip("{}"):
                issues.append(f"year {year} vs Semantic Scholar {hit['year']} ({s2_venue(hit) or 'preprint'})")
            if aid and s2_venue(hit) and not any("published" in i for i in issues):
                issues.append(f"cited as arXiv but published in {s2_venue(hit)} {hit.get('year')}; cite the published version")
    if not title:
        issues.append("no title field")
    return issues


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("bib", type=Path)
    ap.add_argument("--tex", type=Path, nargs="*", help="only check keys cited in these .tex files")
    ap.add_argument("--out", type=Path, help="write the Markdown report here (default: stdout)")
    a = ap.parse_args()

    entries = parse_bib(a.bib.read_text(errors="ignore"))
    if a.tex:
        keys = cited_keys(a.tex)
        missing = sorted(keys - {e["key"] for e in entries})
        entries = [e for e in entries if e["key"] in keys]
    else:
        missing = []
    lines = [f"# Bibliography check: {a.bib.name}", "", f"{len(entries)} entries checked against Crossref and Semantic Scholar.", ""]
    if missing:
        lines += ["## Cited but not in the .bib", "", *[f"- `{k}`" for k in missing], ""]
    flagged = 0
    body = []
    for n, e in enumerate(entries, 1):
        print(f"\r{n}/{len(entries)} {e['key'][:40]:<40}", end="", file=sys.stderr)
        issues = check(e)
        if issues:
            flagged += 1
            body += [f"### `{e['key']}`", "", f"{e.get('title', '')[:120]}", "", *[f"- {i}" for i in issues], ""]
    print(file=sys.stderr)
    lines += [f"## Flagged entries: {flagged}", "", *body] if flagged else ["No problems found."]
    report = "\n".join(lines) + "\n"
    if a.out:
        a.out.write_text(report)
        print(f"Report written to {a.out} ({flagged} flagged)", file=sys.stderr)
    else:
        print(report)


if __name__ == "__main__":
    main()
