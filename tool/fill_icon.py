#!/usr/bin/env python3
import math
import re
import sys
from pathlib import Path

from shapely.geometry import LineString, MultiPolygon, Point, Polygon
from shapely.ops import unary_union

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets/icons/nav"

USAGE = """usage: fill_icon.py [icon ...]
       fill_icon.py --list

Regenerates assets/icons/nav/<icon>.svg from the Hugeicons free (MIT) stroke
paths in SOURCES. With no icon names, rebuilds every recipe. Needs shapely:
python3 -m venv .venv && .venv/bin/pip install shapely"""

SOURCES = {
    "pin_body": "M13.2574 17.4936C12.9201 17.8184 12.4693 18 12.0002 18C11.531 18 11.0802 17.8184 10.7429 17.4936C7.6543 14.5008 3.51519 11.1575 5.53371 6.30373C6.6251 3.67932 9.24494 2 12.0002 2C14.7554 2 17.3752 3.67933 18.4666 6.30373C20.4826 11.1514 16.3536 14.5111 13.2574 17.4936Z",
    "pin_base": "M7 18C5.17107 18.4117 4 19.0443 4 19.7537C4 20.9943 7.58172 22 12 22C16.4183 22 20 20.9943 20 19.7537C20 19.0443 18.8289 18.4117 17 18",
    "grid_a": "M3.88884 9.66294C4.39329 10 5.09552 10 6.49998 10C7.90445 10 8.60668 10 9.11113 9.66294C9.32951 9.51702 9.51701 9.32952 9.66292 9.11114C9.99998 8.60669 9.99998 7.90446 9.99998 6.5C9.99998 5.09554 9.99998 4.39331 9.66292 3.88886C9.51701 3.67048 9.32951 3.48298 9.11113 3.33706C8.60668 3 7.90445 3 6.49998 3C5.09552 3 4.39329 3 3.88884 3.33706C3.67046 3.48298 3.48296 3.67048 3.33705 3.88886C2.99998 4.39331 2.99998 5.09554 2.99998 6.5C2.99998 7.90446 2.99998 8.60669 3.33705 9.11114C3.48296 9.32952 3.67046 9.51702 3.88884 9.66294Z",
    "grid_b": "M14.8888 9.66294C15.3933 10 16.0955 10 17.5 10C18.9044 10 19.6067 10 20.1111 9.66294C20.3295 9.51702 20.517 9.32952 20.6629 9.11114C21 8.60669 21 7.90446 21 6.5C21 5.09554 21 4.39331 20.6629 3.88886C20.517 3.67048 20.3295 3.48298 20.1111 3.33706C19.6067 3 18.9044 3 17.5 3C16.0955 3 15.3933 3 14.8888 3.33706C14.6705 3.48298 14.483 3.67048 14.337 3.88886C14 4.39331 14 5.09554 14 6.5C14 7.90446 14 8.60669 14.337 9.11114C14.483 9.32952 14.6705 9.51702 14.8888 9.66294Z",
    "grid_c": "M3.88884 20.6629C4.39329 21 5.09552 21 6.49998 21C7.90445 21 8.60668 21 9.11113 20.6629C9.32951 20.517 9.51701 20.3295 9.66292 20.1111C9.99998 19.6067 9.99998 18.9045 9.99998 17.5C9.99998 16.0955 9.99998 15.3933 9.66292 14.8889C9.51701 14.6705 9.32951 14.483 9.11113 14.3371C8.60668 14 7.90445 14 6.49998 14C5.09552 14 4.39329 14 3.88884 14.3371C3.67046 14.483 3.48296 14.6705 3.33705 14.8889C2.99998 15.3933 2.99998 16.0955 2.99998 17.5C2.99998 18.9045 2.99998 19.6067 3.33705 20.1111C3.48296 20.3295 3.67046 20.517 3.88884 20.6629Z",
    "grid_d": "M14.8888 20.6629C15.3933 21 16.0955 21 17.5 21C18.9044 21 19.6067 21 20.1111 20.6629C20.3295 20.517 20.517 20.3295 20.6629 20.1111C21 19.6067 21 18.9045 21 17.5C21 16.0955 21 15.3933 20.6629 14.8889C20.517 14.6705 20.3295 14.483 20.1111 14.3371C19.6067 14 18.9044 14 17.5 14C16.0955 14 15.3933 14 14.8888 14.3371C14.6705 14.483 14.483 14.6705 14.337 14.8889C14 15.3933 14 16.0955 14 17.5C14 18.9045 14 19.6067 14.337 20.1111C14.483 20.3295 14.6705 20.517 14.8888 20.6629Z",
    "pin_head": "M13.2585 18.8714C9.51516 18.0215 5.97844 14.4848 5.12853 10.7415C4.99399 10.1489 4.92672 9.85266 5.12161 9.37197C5.3165 8.89129 5.55457 8.74255 6.03071 8.44509C7.10705 7.77265 8.27254 7.55888 9.48209 7.66586C11.1793 7.81598 12.0279 7.89104 12.4512 7.67048C12.8746 7.44991 13.1622 6.93417 13.7376 5.90269L14.4664 4.59604C14.9465 3.73528 15.1866 3.3049 15.7513 3.10202C16.316 2.89913 16.6558 3.02199 17.3355 3.26771C18.9249 3.84236 20.1576 5.07505 20.7323 6.66449C20.978 7.34417 21.1009 7.68401 20.898 8.2487C20.6951 8.8134 20.2647 9.05346 19.4039 9.53358L18.0672 10.2792C17.0376 10.8534 16.5229 11.1406 16.3024 11.568C16.0819 11.9955 16.162 12.8256 16.3221 14.4859C16.4399 15.7068 16.2369 16.88 15.5555 17.9697C15.2577 18.4458 15.1088 18.6839 14.6283 18.8786C14.1477 19.0733 13.8513 19.006 13.2585 18.8714Z",
    "pin_stem": "M3 21L8 16",
    "heart": "M2 8.69444C2 13.0348 7.58942 17.858 10.4107 19.9677C11.3601 20.6776 12.6399 20.6776 13.5893 19.9677C16.4106 17.858 22 13.0348 22 8.69444C22 5.82563 19.8947 3.5 17 3.5C15.5 3.5 14 4 12 6C10 4 8.5 3.5 7 3.5C4.10526 3.5 2 5.82563 2 8.69444Z",
    "milk_body": "M8.71946 4.91465C7.09893 7.88562 5.99219 10.3773 5.99219 13.7771V16C5.99219 18.8284 5.99219 20.2426 6.87087 21.1213C7.74955 22 9.16376 22 11.9922 22C14.8206 22 16.2348 22 17.1135 21.1213C17.9922 20.2426 17.9922 18.8284 17.9922 16V13.7771C17.9922 10.3773 16.8586 7.89408 15.2381 4.92311",
    "milk_cap": "M15.2381 4.92311C15.8876 4.7243 16.3558 4.16227 16.3558 3.5C16.3558 2.67157 15.6232 2 14.7195 2H9.26491C8.36118 2 7.62855 2.67157 7.62855 3.5C7.62855 4.15311 8.0839 4.70873 8.71946 4.91465C8.89007 4.96992 9.99219 5 9.99219 5",
    "milk_label": "M5.99219 12L17.9922 15",
    "sticky": "M12.5 5H11.5C7.72876 5 5.84315 5 4.67157 6.17157C3.5 7.34315 3.5 9.22876 3.5 13V14C3.5 17.7712 3.5 19.6569 4.67157 20.8284C5.84315 22 7.72876 22 11.5 22L12.5 22C16.2712 22 18.1569 22 19.3284 20.8284C20.5 19.6569 20.5 17.7712 20.5 14V13C20.5 9.22876 20.5 7.34315 19.3284 6.17157C18.1569 5 16.2712 5 12.5 5Z",
    "clip": "M11 7.5C11 8.32843 11.6716 9 12.5 9C13.3284 9 14 8.32843 14 7.5V4C14 2.89543 13.1046 2 12 2C10.8954 2 10 2.89543 10 4V5",
    "line_short": "M7.5 17.5H12.5",
    "line_long": "M7.5 13.5H16.5",
    "basket": "M8 7H16C17.8856 7 18.8284 7 19.4142 7.58579C20 8.17157 20 9.11438 20 11V15C20 18.2998 20 19.9497 18.9749 20.9749C17.9497 22 16.2998 22 13 22H11C7.70017 22 6.05025 22 5.02513 20.9749C4 19.9497 4 18.2998 4 15V11C4 9.11438 4 8.17157 4.58579 7.58579C5.17157 7 6.11438 7 8 7Z",
    "basket_handle": "M16 9.5C16 5.63401 14.2091 2 12 2C9.79086 2 8 5.63401 8 9.5",
    "clear_x1": "M14.9994 15L9 9",
    "clear_x2": "M9.00064 15L15 9",
    "circle": "M22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715 2 12C2 17.5228 6.47715 22 12 22C17.5228 22 22 17.5228 22 12Z",
}

RECIPES = {
    "stores": {
        "body": "pin_body",
        "add": [("pin_base", 1.5)],
        "cut_dots": [(12, 9, 2.5)],
    },
    "products": {
        "body": "milk_body",
        "union": ["milk_cap"],
        "cut": [("milk_label", 1.5)],
    },
    "lists": {
        "body": "sticky",
        "cut": [("clip", 2.9), ("line_short", 1.5), ("line_long", 1.5)],
        "add": [("clip", 1.5)],
    },
    "basket": {
        "dir": "assets/icons",
        "body": "basket",
        "add": [("basket_handle", 1.5)],
    },
    "clear": {
        "dir": "assets/icons",
        "body": "circle",
        "cut": [("clear_x1", 1.5), ("clear_x2", 1.5)],
    },
    "favourite": {
        "dir": "assets/icons",
        "body": "heart",
    },
    "pin": {
        "dir": "assets/icons",
        "body": "pin_head",
        "add": [("pin_stem", 1.5)],
    },
    "grid": {
        "dir": "assets/icons",
        "body": "grid_a",
        "union": ["grid_b", "grid_c", "grid_d"],
    },
    "more": {
        "body": "circle",
        "cut_dots": [(7, 12, 1.25), (12, 12, 1.25), (17, 12, 1.25)],
    },
}

TOKEN = re.compile(
    r"[MLHVCSQAZmlhvcsqaz]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?")


def parse_path(d):
    toks = TOKEN.findall(d)
    i = 0
    segs = []
    cmd = None
    x = y = 0.0
    start = None

    def number():
        nonlocal i
        value = float(toks[i])
        i += 1
        return value

    while i < len(toks):
        if not re.match(r"[-+.\d]", toks[i]):
            cmd = toks[i]
            i += 1
        rel = cmd.islower()
        upper = cmd.upper()
        if upper == "M":
            nx, ny = number(), number()
            if rel:
                nx, ny = x + nx, y + ny
            x, y = nx, ny
            start = (x, y)
            segs.append(("M", x, y))
            cmd = "l" if rel else "L"
        elif upper == "L":
            nx, ny = number(), number()
            if rel:
                nx, ny = x + nx, y + ny
            segs.append(("L", x, y, nx, ny))
            x, y = nx, ny
        elif upper == "H":
            nx = number()
            if rel:
                nx = x + nx
            segs.append(("L", x, y, nx, y))
            x = nx
        elif upper == "V":
            ny = number()
            if rel:
                ny = y + ny
            segs.append(("L", x, y, x, ny))
            y = ny
        elif upper == "C":
            a, b, c, dd, e, f = (number() for _ in range(6))
            if rel:
                a, b, c, dd, e, f = x + a, y + b, x + c, y + dd, x + e, y + f
            segs.append(("C", x, y, a, b, c, dd, e, f))
            x, y = e, f
        elif upper == "A":
            _, _, _, _, _, nx, ny = (number() for _ in range(7))
            if rel:
                nx, ny = x + nx, y + ny
            segs.append(("L", x, y, nx, ny))
            x, y = nx, ny
        elif upper == "Z":
            segs.append(("L", x, y, start[0], start[1]))
            x, y = start
        else:
            raise ValueError(cmd)
    return segs


def flatten(d, step=0.03):
    points = []
    for seg in parse_path(d):
        if seg[0] == "M":
            points.append((seg[1], seg[2]))
        elif seg[0] == "L":
            x0, y0, x1, y1 = seg[1:]
            count = max(1, int(math.hypot(x1 - x0, y1 - y0) / step))
            for k in range(1, count + 1):
                t = k / count
                points.append((x0 + (x1 - x0) * t, y0 + (y1 - y0) * t))
        else:
            x0, y0, a, b, c, dd, x1, y1 = seg[1:]
            length = (math.dist((x0, y0), (a, b))
                      + math.dist((a, b), (c, dd))
                      + math.dist((c, dd), (x1, y1)))
            count = max(2, int(length / step))
            for k in range(1, count + 1):
                t = k / count
                mt = 1 - t
                points.append((
                    mt**3 * x0 + 3 * mt * mt * t * a + 3 * mt * t * t * c + t**3 * x1,
                    mt**3 * y0 + 3 * mt * mt * t * b + 3 * mt * t * t * dd + t**3 * y1,
                ))
    return dedupe(points)


def dedupe(points, eps=1e-4):
    out = [points[0]]
    for point in points[1:]:
        if math.dist(point, out[-1]) > eps:
            out.append(point)
    return out


def area(d):
    return Polygon(flatten(d)).buffer(0)


def band(d, width):
    return LineString(flatten(d)).buffer(width / 2, cap_style=1, join_style=1)


def rings(geom, tol=0.008):
    if geom.is_empty:
        return []
    geom = geom.simplify(tol, preserve_topology=True)
    polys = geom.geoms if isinstance(geom, MultiPolygon) else [geom]
    out = []
    for poly in polys:
        out.append(list(poly.exterior.coords))
        out.extend(list(ring.coords) for ring in poly.interiors)
    out.sort(key=lambda r: (round(r[0][0], 2), round(r[0][1], 2), len(r)))
    return out


def to_path(geom):
    return "".join(
        "M" + " ".join(f"{x:.2f} {y:.2f}" for x, y in ring) + "Z"
        for ring in rings(geom))


def build(recipe):
    geom = area(SOURCES[recipe["body"]])
    for name, margin in recipe.get("gap", []):
        geom = geom.difference(area(SOURCES[name]).buffer(margin))
    for name in recipe.get("union", []):
        geom = unary_union([geom, area(SOURCES[name])])
    for name, width in recipe.get("add", []):
        geom = unary_union([geom, band(SOURCES[name], width)])
    for name, width in recipe.get("cut", []):
        geom = geom.difference(band(SOURCES[name], width))
    dots = recipe.get("cut_dots", [])
    if dots:
        geom = geom.difference(
            unary_union([Point(x, y).buffer(r) for x, y, r in dots]))
    return geom


def write(name, geom):
    out = ROOT / RECIPES[name].get("dir", "assets/icons/nav")
    out.mkdir(parents=True, exist_ok=True)
    path = out / f"{name}.svg"
    path.write_text(
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
        f'viewBox="0 0 24 24" fill="none"><path fill-rule="evenodd" '
        f'd="{to_path(geom)}" fill="currentColor"/></svg>\n')
    return path


def main(argv):
    if "--help" in argv or "-h" in argv:
        print(USAGE)
        return 0
    if "--list" in argv:
        print("\n".join(RECIPES))
        return 0
    names = [a for a in argv if not a.startswith("-")] or list(RECIPES)
    unknown = [n for n in names if n not in RECIPES]
    if unknown:
        print(f"unknown icon: {', '.join(unknown)}", file=sys.stderr)
        return 1
    for name in names:
        path = write(name, build(RECIPES[name]))
        print(f"{path.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
