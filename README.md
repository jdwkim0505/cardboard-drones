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

## Team dashboard (`dashboard.html`)

A sign-in-only page at `suhoindustries.com/dashboard.html` for the founders to track
quote requests and the supplier list. It isn't linked from the public site and is marked
`noindex`. Data lives in Supabase (Postgres plus email sign-in). Once it's set up, the
public quote form saves each request straight into the dashboard; until then it falls
back to opening an email.

Not yet set up for controlled data: don't store ITAR drawings or CUI here.

### One-time setup (about 15 minutes)

1. Create a free project at https://supabase.com (any region in the US).
2. **SQL Editor → New query**: paste `supabase/schema.sql`, replace the two example
   emails in the `insert into public.team` line with your real ones, and click **Run**.
3. **Authentication → Users → Invite user**: invite both of those emails. Only invited
   users can sign in.
4. **Authentication → URL Configuration**: set Site URL to `https://suhoindustries.com`
   and add `https://suhoindustries.com/dashboard.html` to Redirect URLs.
5. **Project Settings → API**: copy the Project URL and the `anon` `public` key into
   `js/config.js`, commit and push. (The anon key is safe to publish; the database's
   row-level security keeps everything private to the team.)

To add a teammate later: invite them in Authentication and add their email to the
`team` table.
