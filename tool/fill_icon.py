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
    "navigation_needle": "M15.7078 8.33055C16.6507 9.26482 15.1422 16.8628 13.5942 16.9967C12.2957 17.109 11.891 14.5478 11.6175 13.7361C11.3476 12.9349 11.0472 12.6465 10.2527 12.3836C8.23415 11.7159 7.22489 11.382 7.02507 10.8533C6.49595 9.45337 14.5036 7.13731 15.7078 8.33055Z",
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
        "body": "circle",
        "gap": [("navigation_needle", 0.4)],
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
