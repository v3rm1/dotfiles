#!/usr/bin/env python3
"""Generate the Cyberpunk icon theme (Tokyo Night Night palette).

Each icon shares the kitty icon's look: dark near full-bleed tile,
synthwave floor grid, glitch bars, a neon glyph with glow and a
chromatic-aberration ghost. Glyphs are drawn in a 512px space.

Usage: python3 icons/generate.py   (writes into icons/.local/share/icons/Cyberpunk)
kitty.svg is hand-drawn and not touched by this script. Folder and file icons
(places, mimetypes, devices) have no tile and cover every name listed in icons/names/,
frozen from the Tela-circle-dracula theme this one used to inherit from.
"""
import math
import random
import re
import shutil
from pathlib import Path

OUT = Path(__file__).resolve().parent / ".local/share/icons/Cyberpunk/scalable/apps"

C, B, T, M, P = "#7dcfff", "#7aa2f7", "#2ac3de", "#ff007c", "#bb9af7"
G, Y, O, R, W = "#9ece6a", "#e0af68", "#ff9e64", "#f7768e", "#c0caf5"
FONT = "'InputMono Nerd Font', monospace"


def S(d, c, w=14):
    return f'<path d="{d}" fill="none" stroke="{c}" stroke-width="{w}" stroke-linecap="round" stroke-linejoin="round"/>'


def F(d, c):
    return f'<path d="{d}" fill="{c}"/>'


def Ci(cx, cy, r, c, w=14):
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{c}" stroke-width="{w}"/>'


def Cf(cx, cy, r, c):
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{c}"/>'


def Rr(x, y, w, h, rx, c, sw=14):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="none" stroke="{c}" stroke-width="{sw}" stroke-linejoin="round"/>'


def Tx(x, y, txt, size, c):
    return f'<text x="{x}" y="{y}" font-family="{FONT}" font-weight="700" font-size="{size}" text-anchor="middle" fill="{c}">{txt}</text>'


def gear(cx, cy, r_out, r_in, teeth, c, w=12):
    pts = []
    step = 2 * math.pi / (teeth * 4)
    for i in range(teeth * 4):
        r = r_out if i % 4 in (1, 2) else r_in
        a = i * step
        pts.append(f"{cx + r * math.cos(a):.1f} {cy + r * math.sin(a):.1f}")
    return S("M" + "L".join(pts) + "Z", c, w) + Ci(cx, cy, r_in * 0.42, c, w)


def chrome(cx, cy, r_out, r_in, colours, w=12):
    """Chromium mark: three outer arcs split by tangent lines off a centre disc."""
    out = []
    l = math.sqrt(r_out ** 2 - r_in ** 2)
    ends = []
    for k in range(3):
        a = math.radians(-90 + 120 * k)
        px, py = cx + r_in * math.cos(a), cy + r_in * math.sin(a)
        ex, ey = px + l * math.cos(a + math.pi / 2), py + l * math.sin(a + math.pi / 2)
        out.append(S(f"M{px:.1f} {py:.1f}L{ex:.1f} {ey:.1f}", colours[k], w))
        ends.append((ex, ey))
    for k in range(3):
        (sx, sy), (ex, ey) = ends[k], ends[(k + 1) % 3]
        out.append(S(f"M{sx:.1f} {sy:.1f}A{r_out} {r_out} 0 0 1 {ex:.1f} {ey:.1f}", colours[k], w + 2))
    return "".join(out) + Cf(cx, cy, r_in - 14, C) + Ci(cx, cy, r_in, B, 8)


def doc(c, fold=True):
    out = S("M170 120H300L350 170V392H170Z", c)
    return out + (S("M300 120V170H350", c, 10) if fold else "")


def lo(letter, c, size=130):
    return doc(c) + Tx(260, 340, letter, size, c)


def wine_glass(c, fill):
    return (F("M204 190H308Q302 248 256 256Q210 248 204 190Z", fill)
            + S("M196 130H316Q326 250 256 270Q186 250 196 130Z M256 270V370M200 380H312", c))


def padlock(c, y=240):
    return (Rr(176, y, 160, 130, 18, c)
            + S(f"M206 {y}V{y - 40}Q206 {y - 90} 256 {y - 90}Q306 {y - 90} 306 {y - 40}V{y}", c))


GLYPHS = {
    "amarok": S("M210 340V170L350 140V310", C) + Cf(180, 340, 32, C) + Cf(320, 310, 32, C)
              + S("M130 210Q150 190 170 210Q190 230 210 210", M, 8),
    "network-wired": Rr(206, 130, 100, 70, 12, C) + S("M256 200V260M156 260H356M156 260V300M356 260V300", T, 10)
                     + Rr(106, 300, 100, 70, 12, C) + Rr(306, 300, 100, 70, 12, C),
    "blender": Ci(290, 250, 72, O) + Cf(290, 250, 28, B) + S("M240 196L130 130M226 270L110 330M232 236H120", O),
    "blueman": S("M196 190L316 300L256 360V150L316 210L196 320", T),
    "btop": Rr(166, 166, 180, 180, 20, G) + S("M200 136V166M256 136V166M312 136V166M200 346V376M256 346V376M312 346V376"
                                              "M136 200H166M136 256H166M136 312H166M346 200H376M346 256H376M346 312H376", G, 10)
            + S("M126 256H200L226 200L262 320L292 236L310 256H386", M),
    "chromium": chrome(256, 256, 124, 50, (B, T, P)),
    "CMakeSetup": S("M256 130L390 380H122Z", B) + S("M256 130V380", R) + S("M256 380L190 260", C, 10),
    "digikam": Ci(256, 256, 120, C) + S("M256 136L300 250M360 196L270 256M360 316L250 300M256 376L212 262"
                                        "M152 316L242 256M152 196L262 212", C, 10),
    "discord": S("M150 190Q256 140 362 190L390 330Q340 370 310 350L290 320Q256 330 222 320L202 350Q172 370 122 330Z", P)
               + Cf(210, 270, 22, P) + Cf(302, 270, 22, P),
    "com.github.wwmm.easyeffects": S("M176 140V372M256 140V372M336 140V372", T, 8)
                                   + Cf(176, 300, 24, M) + Cf(256, 190, 24, C) + Cf(336, 260, 24, G),
    "org.gnome.Nautilus": S("M130 180H220L246 206H382V350H130Z", B) + S("M170 300H230L250 280H300", C, 8)
                          + Cf(300, 280, 10, C) + Cf(170, 300, 10, C),
    "gimp": S("M360 140L240 290", Y) + F("M240 290Q200 300 196 340Q190 370 150 372Q200 400 240 360Q262 330 252 302Z", O),
    "hwloc": Rr(216, 130, 80, 50, 10, G) + S("M256 180V230M156 230H356M156 230V270M256 230V270M356 230V270", T, 10)
             + Rr(126, 270, 60, 44, 8, G, 10) + Rr(226, 270, 60, 44, 8, G, 10) + Rr(326, 270, 60, 44, 8, G, 10)
             + Cf(156, 360, 10, C) + Cf(256, 360, 10, C) + Cf(356, 360, 10, C),
    "heroic": S("M256 130L370 170V260Q370 340 256 390Q142 340 142 260V170Z", Y) + S("M266 190L226 270H286L246 340", O),
    "org.gnome.Loupe": Rr(140, 160, 232, 192, 20, C) + S("M160 330L230 250L280 300L310 270L352 330", G, 10)
                       + Cf(320, 210, 18, Y),
    "keepassxc": padlock(G) + Cf(256, 295, 14, G) + S("M256 305V335", G, 10),
    "libreoffice-writer": lo("W", B),
    "libreoffice-calc": lo("C", G),
    "libreoffice-impress": lo("I", O),
    "libreoffice-draw": lo("D", Y),
    "libreoffice-math": lo("M", P),
    "libreoffice-base": lo("B", R),
    "libreoffice-startcenter": lo("LO", C, 90),
    "localsend": S("M130 250L382 140L300 380L240 280Z M240 280L382 140", T),
    "nvim": S("M160 140V372", G, 24) + S("M352 140V372", B, 24) + S("M160 140L352 372", C, 18),
    "md.obsidian.Obsidian": S("M256 120L350 200L320 380L192 380L162 200Z M256 120L230 260L192 380"
                              "M230 260L320 380M230 260L350 200", P, 10),
    "org.openrgb.OpenRGB": Ci(220, 220, 70, R, 10) + Ci(292, 220, 70, G, 10) + Ci(256, 290, 70, B, 10),
    "wine": wine_glass(R, M),
    "net.davidotek.pupgui2": S("M256 360V150M180 226L256 150L332 226", C) + S("M170 380H342", M),
    "qbittorrent": Ci(256, 256, 120, B) + Tx(256, 300, "qb", 130, C),
    "preferences-desktop-theme": S("M256 130Q380 130 380 250Q380 310 320 300Q280 295 290 340Q300 380 250 380"
                                   "Q130 380 130 255Q130 130 256 130Z", P)
                                 + Cf(200, 220, 18, M) + Cf(256, 180, 18, C) + Cf(316, 210, 18, G) + Cf(190, 290, 18, Y),
    "assistant": S("M140 160Q200 140 256 170Q312 140 372 160V370Q312 350 256 380Q200 350 140 370Z M256 170V380", G)
                 + Tx(198, 300, "?", 90, C),
    "qdbusviewer": S("M176 256H336M256 230V166M256 282V346", C, 10) + Ci(150, 256, 26, C) + Ci(256, 256, 26, M)
                   + Ci(362, 256, 26, C) + Ci(256, 140, 20, T) + Ci(256, 372, 20, T),
    "linguist": S("M140 160H372V320H230L180 370V320H140Z", C) + Tx(256, 285, "A", 110, M),
    "qv4l2": Ci(256, 230, 90, C) + Ci(256, 230, 36, M) + S("M206 330L180 380H332L306 330", C),
    "qvidcap": Rr(140, 170, 232, 172, 16, P) + S("M140 210H372M140 302H372", P, 8)
               + F("M236 226L296 256L236 286Z", M),
    "designer": Rr(130, 150, 252, 212, 16, B) + S("M130 190H382", B, 10) + Rr(160, 215, 80, 50, 8, C, 8)
                + Rr(260, 215, 92, 110, 8, M, 8) + S("M160 300H240M160 325H220", G, 8),
    "showfoto": Rr(170, 140, 200, 160, 14, P, 10) + Rr(140, 180, 200, 160, 14, C)
                + S("M155 325L205 270L245 305L290 260L325 300", G, 10),
    "solaar": Rr(196, 140, 120, 232, 60, G) + S("M256 140V210", G, 10) + Cf(256, 250, 10, Y)
              + S("M140 180L160 190M372 180L352 190M130 256H156M382 256H356", Y, 8),
    "steam": Ci(320, 200, 60, B) + Cf(320, 200, 24, C) + Ci(190, 320, 40, B) + S("M270 230L215 300", B, 20),
    "org.mozilla.Thunderbird": Rr(140, 190, 232, 160, 14, B) + S("M140 190L256 280L372 190", B)
                               + S("M150 160Q230 100 320 150", C, 10),
    "applications-system": gear(256, 256, 130, 100, 8, C),
    "virt-manager": Rr(130, 150, 252, 180, 16, C) + S("M256 330V370M200 375H312", C) + Rr(180, 190, 152, 100, 10, M, 8),
    "vlc": S("M256 130L330 350H182Z", O) + S("M226 220H286M210 280H302", W, 12) + S("M150 365H362", O),
    "org.pulseaudio.pavucontrol": S("M150 220H200L260 170V342L200 292H150Z", T)
                                  + S("M300 210Q330 256 300 302M330 180Q380 256 330 332", C, 10),
    "webapp-manager": Ci(256, 256, 120, C) + S("M136 256H376M256 136Q200 256 256 376M256 136Q312 256 256 376"
                                               "M156 196H356M156 316H356", C, 8),
    "winetricks": wine_glass(P, B) + F("M350 130L360 160L390 170L360 180L350 210L340 180L310 170L340 160Z", Y),
    "org.pwmt.zathura": doc(C) + S("M200 210H320M200 250H320M200 290H280M200 330H310", Y, 10),
    "zotero": S("M160 160H352L160 352H352", R, 24),
    "brave-origin-beta": S("M196 130H316L350 170L370 230L330 360L256 392L182 360L142 230L162 170Z", O)
                         + S("M196 240L236 260M316 240L276 260", C, 12) + S("M236 320L256 340L276 320", O, 10),
    "org.gnome.Papers": S("M190 140H310L350 180V360H190Z", B) + S("M160 170V390H320", C, 10)
                        + S("M220 220H320M220 260H320M220 300H290", W, 8),
    "nvtop": Rr(120, 180, 272, 140, 14, G) + Ci(200, 250, 40, G, 10) + Ci(312, 250, 40, G, 10)
             + S("M150 320V350M190 320V350M230 320V350", G, 8) + S("M130 150L200 120L260 140L330 100L390 120", M, 8),
    "org.nickvision.tubeconverter": Rr(150, 150, 212, 140, 30, R) + F("M236 185L286 220L236 255Z", R)
                                    + S("M256 300V380M216 345L256 385L296 345", C),
    "brave-kajebgjangihfbkjfejcanhanjmmbcfd-Default": padlock(O, 200) + Tx(256, 320, "***", 70, C),
    "overleaf": S("M150 370Q150 170 370 140Q350 360 150 370Z M150 370L300 220", G),
    "xdvi": doc(W) + Tx(260, 310, "dvi", 80, C),
    "danklogo": S("M256 120L374 188V324L256 392L138 324V188Z", P)
                + S("M210 190H262Q322 190 322 256Q322 322 262 322H210Z", C) + S("M210 256H250", M, 10),
}

TEMPLATE = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <!-- Cyberpunk icon theme: {name}. Generated by icons/generate.py, do not edit by hand. -->
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#16161e"/><stop offset="1" stop-color="#0c0e14"/>
    </linearGradient>
    <linearGradient id="floor" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#bb9af7" stop-opacity="0"/><stop offset="1" stop-color="#bb9af7" stop-opacity="0.55"/>
    </linearGradient>
    <filter id="glow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur stdDeviation="6" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <filter id="ghost" x="-10%" y="-10%" width="120%" height="120%">
      <feFlood flood-color="{ghost}"/><feComposite in2="SourceGraphic" operator="in"/>
    </filter>
    <clipPath id="tile"><rect x="32" y="32" width="448" height="448" rx="96"/></clipPath>
  </defs>
  <!-- Linux launchers expect near full-bleed icons: 496px tile in 512px canvas -->
  <g transform="translate(-27.429 -27.429) scale(1.107143)">
    <rect x="32" y="32" width="448" height="448" rx="96" fill="url(#bg)"/>
    <g clip-path="url(#tile)">
      <g stroke="url(#floor)" stroke-width="2" fill="none">
        <path d="M32 400H480M32 428H480M32 460H480"/>
        <path d="M256 372L256 480M256 372L160 480M256 372L352 480M256 372L64 480M256 372L448 480M256 372L-32 480M256 372L544 480"/>
      </g>
{bars}
    </g>
    <g filter="url(#ghost)" opacity="0.5" transform="translate(9 -5)">{glyph}</g>
    <g filter="url(#glow)">{glyph}</g>
  </g>
</svg>
"""


def bars(name):
    rnd = random.Random(name)
    out = []
    for colour in (M, C, T):
        w = rnd.randint(60, 140)
        x = rnd.choice([rnd.randint(50, 110), rnd.randint(330, 470 - w)])
        y = rnd.randint(80, 340)
        out.append(f'      <rect x="{x}" y="{y}" width="{w}" height="{rnd.randint(4, 6)}" fill="{colour}" opacity="0.6"/>')
    return "\n".join(out)


FILE_TEMPLATE = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <!-- Cyberpunk icon theme: file manager icon. Generated by icons/generate.py, do not edit by hand. -->
  <defs>
    <filter id="glow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur stdDeviation="7" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <filter id="ghost" x="-10%" y="-10%" width="120%" height="120%">
      <feFlood flood-color="{ghost}"/><feComposite in2="SourceGraphic" operator="in"/>
    </filter>
  </defs>
  <g filter="url(#ghost)" opacity="0.5" transform="translate(9 -5)">{glyph}</g>
  <g filter="url(#glow)">{glyph}</g>
</svg>
"""

# Folder and file emblems, drawn around (0, 0) within roughly +-55px.
EMBLEMS = {
    "home": lambda c: S("M-50 5L0 -40L50 5M-35 -8V45H35V-8", c, 10),
    "desktop": lambda c: Rr(-50, -38, 100, 64, 8, c, 10) + S("M0 26V44M-25 46H25", c, 10),
    "documents": lambda c: S("M-40 -35H40M-40 -10H40M-40 15H40M-40 40H15", c, 10),
    "download": lambda c: S("M0 -45V30M-30 0L0 30L30 0M-45 48H45", c, 10),
    "music": lambda c: S("M-15 35V-40L40 -50V25", c, 10) + Cf(-30, 35, 16, c) + Cf(25, 25, 16, c),
    "pictures": lambda c: Rr(-50, -40, 100, 80, 8, c, 10) + S("M-40 30L-10 -5L15 20L30 5L45 25", c, 8),
    "video": lambda c: Rr(-50, -38, 100, 76, 10, c, 10) + F("M-12 -20L22 0L-12 20Z", c),
    "templates": lambda c: S("M-40 -45H40V45H-40Z", c, 10).replace("/>", ' stroke-dasharray="14 10"/>'),
    "publicshare": lambda c: (Ci(-30, 0, 14, c, 10) + Ci(30, -30, 14, c, 10) + Ci(30, 30, 14, c, 10)
                              + S("M-17 -6L17 -24M-17 6L17 24", c, 8)),
    "git": lambda c: (Ci(-25, -35, 12, c, 9) + Ci(-25, 40, 12, c, 9) + Ci(30, -10, 12, c, 9)
                      + S("M-25 -23V28M30 2Q30 25 -15 32", c, 9)),
    "remote": lambda c: S("M-45 25Q-60 25 -55 0Q-50 -20 -25 -15Q-15 -45 15 -40Q45 -35 42 -5Q62 0 55 20Q50 30 35 25Z", c, 10),
    "locked": lambda c: Rr(-35, -5, 70, 50, 8, c, 10) + S("M-20 -5V-25Q-20 -45 0 -45Q20 -45 20 -25V-5", c, 10),
    "unlocked": lambda c: Rr(-35, -5, 70, 50, 8, c, 10) + S("M-20 -5V-25Q-20 -45 0 -45Q20 -45 20 -30", c, 10),
    "recent": lambda c: Ci(0, 0, 45, c, 10) + S("M0 -25V0L20 15", c, 10),
    "search": lambda c: Ci(-10, -10, 30, c, 10) + S("M12 12L45 45", c, 12),
    "script": lambda c: S("M-20 -30L-50 0L-20 30M20 -30L50 0L20 30", c, 10),
    "games": lambda c: (S("M-50 -15Q-50 -30 -35 -30H35Q50 -30 50 -15L55 25Q55 40 40 35L25 20H-25L-40 35"
                          "Q-55 40 -55 25Z", c, 9) + S("M-30 -10V10M-40 0H-20", c, 8) + Cf(25, -5, 6, c) + Cf(35, 8, 6, c)),
    "system": lambda c: gear(0, 0, 45, 34, 8, c, 9),
    "mail": lambda c: Rr(-50, -32, 100, 64, 8, c, 10) + S("M-50 -32L0 8L50 -32", c, 10),
    "star": lambda c: S("M0 -48L14 -15L50 -15L21 7L32 42L0 21L-32 42L-21 7L-50 -15L-14 -15Z", c, 9),
    "tar": lambda c: Rr(-45, -25, 90, 65, 6, c, 10) + S("M-50 -40H50V-25H-50Z M-15 -5H15", c, 10),
    "print": lambda c: Rr(-50, -15, 100, 45, 8, c, 10) + S("M-30 -15V-45H30V-15M-30 30V48H30V30", c, 10),
}

EMBLEM_COLOURS = {
    "home": Y, "desktop": C, "documents": B, "download": G, "music": P, "pictures": G, "video": M,
    "templates": W, "publicshare": T, "git": O, "remote": C, "locked": R, "unlocked": G, "recent": Y,
    "search": C, "script": G, "games": P, "system": C, "mail": B, "star": Y, "tar": Y, "print": W,
}

# Order matters: the first keyword hit wins.
FOLDER_KEYWORDS = [
    (("home",), "home"), (("desktop",), "desktop"), (("download",), "download"),
    (("document", "text", "txt"), "documents"), (("music", "sound", "podcast"), "music"),
    (("picture", "image", "photo", "camera"), "pictures"), (("video",), "video"), (("template",), "templates"),
    (("public", "share"), "publicshare"), (("git",), "git"),
    (("remote", "cloud", "dropbox", "gdrive", "onedrive", "owncloud", "network"), "remote"),
    (("unlocked", "decrypted"), "unlocked"), (("locked", "encrypted", "private", "certificate"), "locked"),
    (("recent",), "recent"), (("search",), "search"), (("script", "development", "html", "build", "gradle"), "script"),
    (("games",), "games"), (("system", "root"), "system"), (("mail",), "mail"),
    (("important", "favorite", "bookmark"), "star"), (("tar",), "tar"), (("print",), "print"),
]

NETWORK_KEYWORDS = ("network", "server", "smb", "nfs", "samba", "knetattach", "workgroup", "repository", "dav",
                    "ftp", "ssh", "web", "share")

NAMES = Path(__file__).resolve().parent / "names"


def emblem(key, cx, cy, scale):
    return f'<g transform="translate({cx} {cy}) scale({scale})">{EMBLEMS[key](EMBLEM_COLOURS[key])}</g>'


def folder(key=None):
    out = S("M60 130H200L236 166H452V412H60Z", C) + S("M60 206H452", C, 8)
    return out + (emblem(key, 256, 306, 1.3) if key else "")


def trash(full):
    out = S("M166 140H346M226 140V116H286V140M182 140L200 410H312L330 140", T) + S("M236 190V360M276 190V360", T, 10)
    if full:
        out += S("M200 110Q230 70 260 100Q290 60 320 100", M, 10)
    return out


def place_glyph(name):
    if "trash" in name:
        return trash("full" in name)
    if "folder" not in name and "directory" not in name and any(k in name for k in NETWORK_KEYWORDS):
        return GLYPHS["network-wired"]
    for keywords, key in FOLDER_KEYWORDS:
        if any(k in name for k in keywords):
            return folder(key)
    return folder()


LABELS = {
    "python": "PY", "javascript": "JS", "typescript": "TS", "rust": "RS", "csrc": "C", "chdr": "H",
    "c++src": "C++", "c++hdr": "HPP", "cpp": "C++", "markdown": "MD", "json": "JSON", "html": "HTML",
    "css": "CSS", "shellscript": "SH", "tex": "TEX", "plain": "TXT", "generic": "TXT", "xml": "XML",
    "yaml": "YAML", "toml": "TOML", "java": "JAVA", "go": "GO", "lua": "LUA", "executable": "EXE",
    "sharedlib": "SO", "makefile": "MAKE", "cmake": "CMAK", "patch": "DIFF", "diff": "DIFF", "log": "LOG",
    "csv": "CSV", "sql": "SQL", "ruby": "RB", "perl": "PL", "php": "PHP", "haskell": "HS", "kotlin": "KT",
    "swift": "SWFT", "julia": "JL", "bibtex": "BIB", "x509-ca-cert": "CERT", "pgp-keys": "KEY",
}

ARCHIVE = ("zip", "tar", "compress", "archive", "rar", "7z", "gzip", "bzip", "xz", "zstd", "lzma", "lzip",
           "cpio", "cab", "arj", "lha", "stuffit")
PACKAGE = ("deb", "rpm", "apk", "flatpak", "appimage", "snap", "package")
OFFICE = ("libreoffice", "wps", "office", "opendocument", "msword", "ms-excel", "powerpoint", "spreadsheet",
          "presentation", "wordprocessing", "document")
EXEC = ("executable", "sharedlib", "script", "desktop", "x-sh", "batch", "msdos-program", "ms-dos")


def label_for(name):
    rest = re.sub(r"^(gnome-mime-|application-|text-|x-|vnd\.)+", "", name)
    if rest in LABELS:
        return LABELS[rest]
    for key, label in LABELS.items():
        if name.endswith(key):
            return label
    token = re.split(r"[-.+_]", rest)[-1] or rest
    return token.upper()[:4]


def mime_style(name):
    """Return (colour, label, emblem key) for a mimetype icon name."""
    if name.startswith("image") or "-image" in name:
        return G, None, "pictures"
    if name.startswith("audio") or "-audio" in name:
        return P, None, "music"
    if name.startswith("video") or "-video" in name:
        return M, None, "video"
    if "font" in name:
        return W, "Aa", None
    if "pdf" in name:
        return R, "PDF", None
    if any(k in name for k in ARCHIVE):
        return Y, None, "tar"
    if any(k in name for k in PACKAGE):
        return O, label_for(name), None
    if any(k in name for k in OFFICE):
        if any(k in name for k in ("spreadsheet", "excel", "calc", "sheet")):
            return G, "XLS", None
        if any(k in name for k in ("presentation", "powerpoint", "impress", "slide")):
            return O, "PPT", None
        return B, "DOC", None
    if any(k in name for k in EXEC):
        return O, label_for(name), None
    if name.startswith(("text", "source")):
        return C, label_for(name), None
    return W, label_for(name), None


def mime_glyph(name):
    colour, label, key = mime_style(name)
    out = S("M130 56H320L400 136V456H130Z", colour) + S("M320 56V136H400", colour, 10)
    if key:
        return out + emblem(key, 265, 300, 1.4)
    size = {1: 150, 2: 130, 3: 110}.get(len(label), 86)
    return out + Tx(265, 300 + size // 3, label, size, colour if colour != W else C)


def device_glyph(name):
    """Device icon by keyword; first match wins."""
    rules = [
        (("optical", "cdrom", "dvd", "cdr", "disc", "blu-ray", "media-cd"),
         lambda: Ci(256, 256, 130, P) + Ci(256, 256, 30, C) + S("M256 160Q330 160 350 230", C, 10)),
        (("usb", "pendrive", "removable", "flash", "sdmmc", "memory", "stick", "floppy", "media-cf", "media-ms", "media-sm"),
         lambda: Rr(196, 190, 120, 220, 16, Y) + Rr(216, 110, 80, 80, 6, Y, 10) + S("M236 140H246M266 140H276", C, 10)),
        (("harddisk", "drive", "blockdev", "multidisk", "tape", "database", "mount"),
         lambda: Rr(110, 170, 292, 172, 24, C) + S("M110 280H402", C, 8) + Cf(360, 311, 10, G) + S("M150 311H250", T, 8)),
        (("phone", "smart", "cell", "handheld", "pda", "ipod", "multimedia-player", "kdeconnect"),
         lambda: Rr(186, 96, 140, 320, 24, G) + S("M236 130H276", G, 10) + Cf(256, 380, 10, C)),
        (("tablet",), lambda: Rr(140, 110, 232, 292, 24, G) + Cf(256, 375, 10, C)),
        (("laptop",), lambda: Rr(146, 140, 220, 150, 12, C) + S("M106 330H406L386 360H126Z", C)),
        (("keyboard", "dialpad"),
         lambda: Rr(100, 180, 312, 150, 18, B) + S("M140 225H160M200 225H220M240 225H260M280 225H300M320 225H340"
                                                    "M150 265H170M210 265H230M250 265H270M290 265H310M180 300H330", C, 12)),
        (("mouse", "pointing", "pointer", "touchpad"),
         lambda: Rr(196, 140, 120, 232, 60, B) + S("M256 140V210", B, 10) + Cf(256, 250, 10, C)),
        (("gaming", "joystick", "wiimote"), lambda: emblem("games", 256, 256, 2.6)),
        (("headphone", "headset", "handsfree"),
         lambda: S("M150 300V250Q150 140 256 140Q362 140 362 250V300", P) + Rr(130, 280, 50, 90, 14, P) + Rr(332, 280, 50, 90, 14, P)),
        (("microphone",),
         lambda: Rr(216, 110, 80, 160, 40, P) + S("M176 230Q176 320 256 320Q336 320 336 230M256 320V390M206 390H306", P)),
        (("speaker", "audio-card", "loudspeaker"), lambda: GLYPHS["org.pulseaudio.pavucontrol"]),
        (("camera-web", "webcam"), lambda: GLYPHS["qv4l2"]),
        (("camera",), lambda: Rr(116, 170, 280, 190, 20, M) + Ci(256, 265, 60, C) + S("M196 170L216 140H296L316 170", M)),
        (("printer", "scanner"), lambda: emblem("print", 256, 256, 2.6)),
        (("bluetooth", "blueman"), lambda: GLYPHS["blueman"]),
        (("wireless", "wavelan", "hotspot"),
         lambda: S("M150 230Q256 140 362 230M186 272Q256 212 326 272M222 314Q256 286 290 314", T) + Cf(256, 350, 14, T)),
        (("network", "ethernet", "wired", "modem", "vpn", "firewall", "server", "workgroup"), lambda: GLYPHS["network-wired"]),
        (("battery", "power-supply"),
         lambda: Rr(130, 190, 232, 132, 16, G) + Rr(362, 230, 20, 52, 6, G, 10) + F("M160 220H220V292H160Z", G)
                 + F("M236 220H296V292H236Z", G)),
        (("display", "television", "computer", "desktop", "system", "monitor"),
         lambda: Rr(120, 130, 272, 180, 16, C) + S("M256 310V360M196 370H316", C)),
    ]
    for keywords, draw in rules:
        if any(k in name for k in keywords):
            return draw()
    # Fallback: a bare chip.
    return Rr(166, 166, 180, 180, 20, G) + S("M200 136V166M256 136V166M312 136V166M200 346V376M256 346V376M312 346V376"
                                            "M136 200H166M136 256H166M136 312H166M346 200H376M346 256H376M346 312H376", G, 10)


def names_for(context):
    """Icon names to cover, frozen from Tela-circle-dracula into icons/names/<context>.txt."""
    return (NAMES / f"{context}.txt").read_text().split()


def write_context(context, names, glyph_for):
    """Write one SVG per distinct icon; names that would duplicate an existing icon become symlinks."""
    out_dir = OUT.parent / context
    if out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True)
    first_by_svg = {}
    for name in names:
        glyph = glyph_for(name)
        main_colour = re.search(r'(?:stroke|fill)="(#[0-9a-f]{6})"', glyph).group(1)
        svg = FILE_TEMPLATE.format(ghost=C if main_colour == M else M, glyph=glyph)
        target = out_dir / f"{name}.svg"
        if svg in first_by_svg:
            target.symlink_to(first_by_svg[svg])
        else:
            target.write_text(svg)
            first_by_svg[svg] = target.name
    print(f"wrote {len(names)} {context} icons ({len(first_by_svg)} distinct) to {out_dir}")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, glyph in GLYPHS.items():
        # A glyph whose main colour is magenta gets a cyan ghost so the aberration stays visible.
        main_colour = re.search(r'(?:stroke|fill)="(#[0-9a-f]{6})"', glyph).group(1)
        ghost = C if main_colour == M else M
        svg = TEMPLATE.format(name=name, ghost=ghost, bars=bars(name), glyph=glyph)
        (OUT / f"{name}.svg").write_text(svg)
    print(f"wrote {len(GLYPHS)} icons to {OUT}")
    # File manager icons: cover every place and mimetype name the parent theme ships, so none leak through.
    write_context("places", names_for("places"), place_glyph)
    write_context("mimetypes", names_for("mimetypes"), mime_glyph)
    write_context("devices", names_for("devices"), device_glyph)


if __name__ == "__main__":
    main()
