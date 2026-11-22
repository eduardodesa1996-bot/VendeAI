# VendeAI v2 — backend-ready starter

This update builds on the v1 demo and adds an authentication configuration screen and a starter schema for Supabase.

## V3 additions\n- Automatically creates a profile record on signup using a Supabase trigger.\n- Campaign drafts are saved to the signed-in user account when Supabase is connected, otherwise stored locally in the browser.\n- Completed agent simulation runs are recorded to the signed-in user account when connected.\n\n## What is new
- Supabase URL and public anon key configuration stored in this browser only.
- Email signup, email/password login, and logout starter flow using Supabase JS v2.
- SQL schema for profiles, products, campaigns, agent runs, commission events, withdrawals, and subscriptions.
- Row Level Security (RLS) policies in `schema.sql`.
- The prototype UI remains demo-only for sales/commissions; no real sales, affiliate API, payments, or payouts are integrated.

## Setup from a phone/browser
1. Create a Supabase account and a project.
2. Open Supabase SQL Editor, paste `schema.sql`, and run it.
3. From Supabase project settings, copy the project URL and public anon key (never service-role key).
4. Deploy this folder as a static site (GitHub Pages is suitable for this demo).
5. Open the site, Settings, paste URL/key, save, then test signup/login.
6. Configure Supabase Auth email confirmation and redirect URLs for your deployed site.

## Security / production notes
- This is a starter, not production-ready financial software.
- Do not keep service-role keys in frontend code.
- Financial events, withdrawals, balances, affiliate conversions and subscriptions must be validated server-side/webhooks, not trusted from client input.
- Before production, add server/Edge Functions, secure payout integration, privacy policy, terms, rate limiting, abuse protection, and tests.
- Withdrawal threshold is R$10 shown as a policy concept; it is not a promise of earnings or a simulated lock/unlock mechanism.
\n\n## V3 deployment note\nAfter replacing the files in your GitHub repository, run the updated `schema.sql` in Supabase SQL Editor. If you already ran the earlier schema, this file is designed to add the profile trigger; existing tables/policies remain. Test sign-up, campaign saving and simulation history.\n