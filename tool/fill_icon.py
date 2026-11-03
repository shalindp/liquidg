#!/usr/bin/env python3
import math
import re
import sys
from pathlib import Path

from shapely.geometry import LineString, MultiPolygon, Point, Polygon
from shapely.ops import unary_union

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets/icons/nav"

SOURCES = {
    "bag": "M3.32352 13.0113C3.6739 10.009 4.18586 7.75784 4.66063 6.15851C5.04994 4.84711 5.24459 4.19141 6.04283 3.5957C6.84107 3 7.65697 3 9.28876 3H14.7113C16.3431 3 17.159 3 17.9572 3.5957C18.7554 4.19141 18.9501 4.84711 19.3394 6.15851C19.8142 7.75784 20.3261 10.009 20.6765 13.0113C21.0895 16.5497 21.2959 18.3189 20.1027 19.6594C18.9095 21 16.9758 21 13.1084 21H10.8916C7.02422 21 5.09052 21 3.89731 19.6594C2.70411 18.3189 2.91058 16.5497 3.32352 13.0113Z",
    "bag_handle": "M9 7C9 8.65685 10.3431 10 12 10C13.6569 10 15 8.65685 15 7",
    "apple": "M8 5C5.23858 5 3 8.0139 3 11.0278C3 14.544 3.5 17.0556 5.5 20.0695C7.02044 22.1062 9.05026 22.6168 11.2139 21.1903C11.6757 20.8859 12.3243 20.8859 12.7861 21.1903C14.9497 22.6168 16.9796 22.1062 18.5 20.0695C20.5 17.0556 21 14.544 21 11.0278C21 8.0139 18.7614 5 16 5C14.5746 5 13.2885 5.7849 12.3777 6.63254C12.166 6.82949 11.834 6.82949 11.6223 6.63254C10.7115 5.7849 9.42542 5 8 5Z",
    "apple_stem": "M12 6C12 4.66667 12.6 2 15 2",
    "apple_shine": "M6 12C6 10.3665 6.82273 8.73298 8 8",
    "sticky": "M12.5 5H11.5C7.72876 5 5.84315 5 4.67157 6.17157C3.5 7.34315 3.5 9.22876 3.5 13V14C3.5 17.7712 3.5 19.6569 4.67157 20.8284C5.84315 22 7.72876 22 11.5 22L12.5 22C16.2712 22 18.1569 22 19.3284 20.8284C20.5 19.6569 20.5 17.7712 20.5 14V13C20.5 9.22876 20.5 7.34315 19.3284 6.17157C18.1569 5 16.2712 5 12.5 5Z",
    "clip": "M11 7.5C11 8.32843 11.6716 9 12.5 9C13.3284 9 14 8.32843 14 7.5V4C14 2.89543 13.1046 2 12 2C10.8954 2 10 2.89543 10 4V5",
    "line_short": "M7.5 17.5H12.5",
    "line_long": "M7.5 13.5H16.5",
    "circle": "M22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715 2 12C2 17.5228 6.47715 22 12 22C17.5228 22 22 17.5228 22 12Z",
}

RECIPES = {
    "stores": {
        "body": "bag",
        "cut": [("bag_handle", 2.0)],
    },
    "products": {
        "body": "apple",
        "add": [("apple_stem", 1.6)],
        "cut": [("apple_shine", 1.5)],
    },
    "lists": {
        "body": "sticky",
        "cut": [("clip", 2.9), ("line_short", 1.5), ("line_long", 1.5)],
        "add": [("clip", 1.5)],
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
    return out


def to_path(geom):
    return "".join(
        "M" + " ".join(f"{x:.2f} {y:.2f}" for x, y in ring) + "Z"
        for ring in rings(geom))


def build(recipe):
    geom = area(SOURCES[recipe["body"]])
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
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / f"{name}.svg"
    path.write_text(
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
        f'viewBox="0 0 24 24" fill="none"><path fill-rule="evenodd" '
        f'd="{to_path(geom)}" fill="currentColor"/></svg>\n')
    return path


def main(argv):
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
