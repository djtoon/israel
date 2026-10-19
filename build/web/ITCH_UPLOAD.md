# Uploading the web version to itch.io

The file to upload is `build/web/release/IsraelBirthOfANation_Web.zip`. It is made by `build/web/package_web.py`, and `index.html` sits at the root of the zip.

## itch.io limits (checked 2026-10-18, https://itch.io/docs/creators/html5)
| limit | itch.io | this build |
|---|---|---|
| files after unzipping | ≤ 1,000 | 12 |
| total unzipped size | ≤ 500 MB | 235 MB (the zip itself is 205 MB) |
| largest single file | ≤ 200 MB | `index.pck` 184 MB |
| path length | ≤ 240 characters, case sensitive | short names only |

If a later build pushes `index.pck` over 200 MB, itch rejects the zip. Run the asset diet in `build/web/refresh_src.sh` again before uploading. itch's CDN gzips `.pck`, `.wasm`, `.js` and `.html` automatically, so don't pre-compress anything.

## The new name (2026-10-18)
The game is now called **Israel**. On the itch page, change the game's **Title** to "Israel" under Edit game. Also replace the cover image and screenshots that show the old title "The Birth of a Nation". The zip file name still says IsraelBirthOfANation; players never see it in the browser.

## Option A: add the web version to the existing game page (recommended)
On the game's **Edit game** page:
1. **Uploads → Upload files:** choose `IsraelBirthOfANation_Web.zip`. Then tick **"This file will be played in the browser"**.
   - Keep the Windows and macOS zips as downloads. Tick their platform boxes (Windows / macOS) and leave "played in the browser" unticked.
2. **Kind of project:** set it to **HTML**, so the page shows the playable embed. The downloads stay available under it.
3. **Embed options:**
   - **Viewport dimensions:** 1280 × 720. The game is laid out for 1280×720 and up.
   - **Automatically start on page load:** OFF. Leave "Click to play" on: browsers only allow sound after a click, and the roughly 230 MB first load shouldn't start before the player wants it.
   - **Fullscreen button:** ON. The game also has its own fullscreen button in Settings → Display.
   - **Mobile friendly:** OFF. This is a desktop-only build; phones and tablets aren't supported.
   - **Scrollbars:** OFF.
   - **SharedArrayBuffer support:** OFF. The build uses Godot's no-threads web template, so it doesn't need it, and turning it on can break embeds from other sites.
4. **Frame options:** none needed.
5. Save, then open the page in a private window and play the first turn to check it.

## Option B: a separate page just for the browser version
Create a new project with Kind = HTML. Use the same zip and the same embed options as in A, and link the two pages to each other in their descriptions.

## Text to add to the page
- Under the play button: "Play in your browser (desktop Chrome, Edge or Firefox). The first load is about 230 MB, about 40 seconds on a fast connection, and the first start compiles graphics for up to a minute while the intro plays. After that, the browser caches it."
- "Saves are kept in this browser. In the Save window, use **Export** on a save to download it as a file, and **Import a save file...** to put it back, in any browser."
- "The browser version uses the standard (SD) graphics. For HD and HD+ graphics, download the Windows or macOS version."
- "Phones and tablets are not supported."

## Things players may ask about
- **Black screen or "WebGL 2 not supported":** update the browser or graphics driver. In Chrome, check that hardware acceleration is on (Settings → System).
- **Slow on a laptop:** on built-in graphics the game starts in a lighter mode ("Web, lighter": no shadows, softer resolution, 30 fps cap). On the test laptop's Radeon 610M that runs at about 30 fps, against 50–60 fps with full effects on the gaming GPU. Many laptops run the browser on the built-in graphics chip, not the gaming GPU. In Windows go to Settings → System → Display → Graphics, set the browser (Chrome, Edge or Firefox) to "High performance", and restart the browser.
- **Lost progress:** browser saves are cleared if the player clears site data or uses a private window. The Save window's Export button keeps a file copy.
- **Keys:** F5, Ctrl+S and Ctrl+L work in the game, because the page stops the browser from acting on them. Ctrl+W and Ctrl+T can't be blocked by any web page.
- **Firefox:** Firefox hides the graphics chip's name, so the game starts in "Web, lighter" there. Players with a gaming GPU can switch to "Web" under Graphics in Settings → Display.
