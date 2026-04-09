# SEO Audit — Lindy.ai

**URL:** https://www.lindy.ai
**Date:** 2026-03-02
**Overall Health:** Needs Work (strong content strategy, weak technical foundations)

## Technical SEO
| Issue | Severity | Recommendation |
|-------|----------|---------------|
| No structured data (JSON-LD) | High | Add Organization, Product, and FAQPage schema. Lindy ranks for "chatbot service" queries — rich snippets would improve CTR. |
| No canonical tags detected | High | Implement self-referencing canonicals on all pages. Blog posts especially vulnerable to duplicate content via URL params. |
| Heavy JS rendering | Medium | Core content loads via JavaScript. Ensure SSR or pre-rendering for Googlebot — test with "View as Google" in Search Console. |
| No visible image alt text | Medium | Add descriptive alt text to all product screenshots and UI demos. Critical for image search and accessibility. |
| PostHog + GTM scripts | Low | Async load analytics scripts. Defer non-critical JS. Test LCP impact with PageSpeed Insights. |
| Lottie animations on homepage | Low | Already lazy-loaded (good). Monitor CLS — ensure animations don't shift layout on load. |

## Content Audit
| Page | Issue | Recommendation |
|------|-------|---------------|
| Homepage | H1 "Get two hours back every day" is great for users, weak for SEO. No primary keyword in H1. | Keep the H1 for users. Add keyword-rich subtitle or meta title: "AI Agent Platform — Get Two Hours Back Every Day \| Lindy" |
| /blog/ | Strong blog with 5,946 ranked keywords. Heavy on competitor reviews (Otter.ai, BeenVerified) — drives traffic but not conversion. | Double down on use-case content: "How to Automate Meeting Scheduling with AI" (maps to 3,600/mo keyword) |
| /pricing | Standard pricing page | Add FAQ schema with common pricing questions. Add comparison table vs. competitors. |
| /integrations | Integration pages exist but not individually indexed | Create dedicated /integrations/[tool-name] pages (Zapier's playbook: 57K keywords from integration pages alone) |
| /solutions/* | Solution pages by use case exist | Ensure each targets a specific keyword cluster. Add internal links from blog → solution pages. |

## Local SEO
- **GBP Status:** N/A — SaaS company, no local listing needed
- **NAP Consistency:** N/A
- **Schema Markup:** Missing (should have Organization + SoftwareApplication)
- **Reviews:** Strong G2/TrustRadius presence, 40,000+ users cited on homepage

## Priority Fixes (Do These First)
1. **Add JSON-LD structured data** — Organization schema on homepage, SoftwareApplication on product pages, FAQPage on pricing/FAQ pages. Immediate SERP improvement.
2. **Implement canonical tags** — Self-referencing canonicals on all pages. Prevent duplicate content issues with blog URL parameters.
3. **Add alt text to all images** — Product screenshots are Lindy's best visual assets. Make them discoverable in image search.
4. **Create integration landing pages** — `/integrations/slack`, `/integrations/salesforce`, etc. Each with unique content, not just a logo grid. This is the single biggest organic growth lever (Zapier model).
5. **Optimize blog for conversion** — Add CTAs to top-performing blog posts. Competitor review posts rank well but don't convert — add "Try Lindy" CTAs with relevant use-case framing.

## Notes
- Audit limited to what's observable via HTTP fetch. Full technical audit requires Google Search Console access + PageSpeed Insights testing.
- Blog content strategy is strong (5,946 ranked keywords) — the foundation is solid. The gap is technical SEO + conversion optimization, not content volume.
- 40,000+ user count is powerful social proof but not visible in meta descriptions or structured data — surface it everywhere.
