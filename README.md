# Foldable Cardboard Drones

Static one-page website. Open `index.html` in a browser; no build step.

Photo and video spots are dashed placeholder boxes. Each one has an HTML comment
naming the file it expects (for example `media/hero.mp4`, `media/step-1.jpg`).
Put the files in `media/` and replace the placeholder `<div class="ph ...">` with an
`<img>` or `<video>` tag.

## Request-a-quote page

`quote.html` is the sourcing request form (linked as "Get a quote" in the nav). There is
no backend: submitting opens the visitor's email app with a pre-filled RFQ addressed to
suhoindustries@gmail.com. The page tells visitors not to email ITAR-controlled or CUI
drawings; those need a secure transfer arranged separately.
