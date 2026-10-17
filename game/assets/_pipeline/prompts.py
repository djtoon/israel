"""Single source of truth for the art-direction prompt templates (see ../ART_DIRECTION.md)."""

STYLE = ("Game asset for a Civilization VI style strategy game: stylised-realistic hand-crafted 3D render, "
         "warm golden Mediterranean late-afternoon sunlight from the upper left, soft warm shadows, "
         "rich saturated colours (honey limestone, terracotta, olive and sage greens, turquoise accents), "
         "clean chunky readable silhouette with slightly exaggerated proportions, fine but not noisy detail")

NEG = ("No text, no letters, no numbers, no logos, no signage, no UI, no frame, no border, "
       "no cast shadow on the background")

TILE_BASE = ("Everything stands on one thin flat pointy-top hexagonal ground slab (a single map tile; the slab edge "
             "is only as thick as a kerb stone, no soil cross-section) covered with {ground}; "
             "nothing overhangs the hexagon edge")


def tile(subject, ground="sun-baked sandy earth with a little dry grass"):
    return (f"{subject}. {TILE_BASE.format(ground=ground)}. {STYLE}. Isometric three-quarter view from about "
            f"35 degrees above. One single isolated tile centred and filling about 85% of the frame on a plain pure "
            f"white background. {NEG}.")


def prop(subject):
    return (f"{subject}. {STYLE}. Three-quarter view from about 25 degrees above. One single isolated object, "
            f"no base, no ground patch, centred and filling about 80% of the frame on a plain pure white "
            f"background. {NEG}.")


def unit(subject):
    return (f"{subject}. {STYLE}; looks like a painted tabletop miniature as seen in Civilization VI, "
            f"slightly chunky heroic proportions, clean readable shape at small size. Three-quarter view from "
            f"about 25 degrees above, facing front-left. One single isolated unit, no base, no ground, "
            f"centred and filling about 80% of the frame on a plain pure white background. {NEG}.")


def terrain(subject):
    return (f"Seamless tileable ground texture, perfectly straight top-down orthographic view looking straight "
            f"down (no perspective, no horizon, no sky), of {subject}. Map terrain texture for a Civilization VI "
            f"style strategy game: stylised-realistic painterly look, warm sunlit Mediterranean palette, rich "
            f"saturated but natural colour, soft even overhead lighting, uniform density across the whole image "
            f"with no focal point, no vignette, no single large feature, no objects, no buildings, no roads. "
            f"Area shown is about 20 metres across. {NEG}.")


ICON = ("Game HUD icon of {glyph}. Drawn as a bold clean line-art glyph in warm polished gold (#E2B65A) with a "
        "subtle bevel highlight, centred inside a round deep-navy (#0F1E3F) medallion with a thin gold rim ring "
        "and a faint inner glow, flat front view, simple bold shapes that stay readable at 32 pixels, consistent "
        "medium line weight, {accent}. Transparent background outside the medallion. One icon only, centred, "
        "filling the frame. No text, no letters, no numbers.")


def icon(glyph, accent="gold only"):
    return ICON.format(glyph=glyph, accent=accent)


PIN = ("Map resource pin icon of {glyph}. A round deep-navy (#0F1E3F) badge with a thin gold (#E2B65A) rim and a "
       "small downward point at the bottom like a map marker; inside, the resource drawn as a bold simple "
       "slightly stylised illustration in its natural colours ({colours}) with a gold outline. Flat front view, "
       "readable at 32 pixels. Transparent background outside the badge. One pin only, centred, filling the "
       "frame. No text, no letters, no numbers.")


def pin(glyph, colours):
    return PIN.format(glyph=glyph, colours=colours)


def building(subject):
    """Single building / structure for the renderer's city layout: no base, no plinth, cropped at the ground line."""
    return (f"{subject}. {STYLE}. One single isolated building standing directly on the ground line, with no base, "
            f"no plinth, no slab, no ground patch, no lawn, no pavement, no trees around it; the image is cut off "
            f"exactly at the bottom of the walls. Three-quarter view from about 30 degrees above. Centred and filling "
            f"about 80% of the frame on a plain pure white background. {NEG}.")


def piece(subject):
    """Metre-scale modular kit piece (quay, wall, crane, stall...): no base, no surroundings."""
    return (f"{subject}. {STYLE}. One single isolated modular game piece standing directly on the ground line, with "
            f"no base, no plinth, no ground patch, no water, no surroundings, no people; the image is cut off exactly "
            f"at the bottom of the object. Three-quarter view from about 30 degrees above. Centred and filling about "
            f"80% of the frame on a plain pure white background. {NEG}.")


def obj(subject):
    """Boats, rocks: a free object with no base, no water."""
    return (f"{subject}. {STYLE}. One single isolated object with no base, no ground, no water, no reflection, no "
            f"surroundings, no people. Three-quarter view from about 30 degrees above. Centred and filling about 80% "
            f"of the frame on a plain pure white background. {NEG}.")


def plant(subject):
    """Real-scale vegetation: varied natural silhouette, chunky solid foliage masses that survive image-to-3D."""
    return (f"{subject}. {STYLE}; foliage built from chunky solid clumps so the silhouette reads clearly, natural "
            f"irregular asymmetric shape, not a round lollipop. One single isolated plant, no pot, no ground, no grass, "
            f"cut off exactly at the base of the trunk. Side three-quarter view from about 15 degrees above, the whole "
            f"plant visible, centred and filling about 85% of the frame on a plain pure white background. {NEG}.")


ROOF = ("flat roof clearly visible and full of typical Israeli rooftop clutter: several solar water heaters (a tilted "
        "dark-blue panel with a white horizontal cylinder tank), small water tanks, AC units, antennas, a low parapet")


def roofbld(subject, roof=True):
    """Round 3: building recognisable from above at game zoom. Steeper view so the roof reads."""
    r = f"; {ROOF}" if roof else ""
    return (f"{subject}{r}. {STYLE}; bold readable massing and silhouette, distinct proportions. One single isolated "
            f"building standing directly on the ground line, with no base, no plinth, no ground patch, no lawn, no "
            f"pavement, no trees, no cars, no people; the image is cut off exactly at the bottom of the walls. "
            f"Three-quarter view from about 45 degrees above so both the roof and two facades are visible. Centred and "
            f"filling about 80% of the frame on a plain pure white background. {NEG}.")
