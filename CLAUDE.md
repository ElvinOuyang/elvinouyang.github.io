# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal blog for Elvin Ouyang built with Jekyll using the **Minimal Mistakes** theme (`minimal-mistakes-jekyll` gem). Hosted on GitHub Pages at https://elvinouyang.github.io.

## Build & Serve Commands

```bash
# Install dependencies
bundle install

# Serve locally with live reload
bundle exec jekyll serve

# Build static site (output to _site/)
bundle exec jekyll build

# Serve with incremental builds
bundle exec jekyll serve --incremental

# Docker alternative
docker build -t blog . && docker run -p 4000:4000 blog

# Rebuild minified JS (requires Node)
npm run build:js
```

## Architecture

- **Theme**: Minimal Mistakes (installed as gem, not vendored). Customizations override theme defaults via same-named files in `_includes/`, `_layouts/`, `_sass/`.
- **Config**: `_config.yml` controls site settings, author info, plugin list, permalink structure, and front matter defaults. Changes require server restart.
- **Content**:
  - `_posts/` - Blog posts (Markdown with YAML front matter, named `YYYY-MM-DD-title.md`)
  - `_pages/` - Static pages (About, Projects, Study Notes, Resources, etc.)
- **Data**: `_data/navigation.yml` defines the top nav menu. `_data/ui-text.yml` has UI string translations.
- **Layouts**: `_layouts/` contains `default.html` (base), `single.html` (posts/pages), `home.html` (index), `archive.html`, `splash.html`. Layout inheritance: most layouts extend `default.html` which wraps content in `compress.html` for HTML minification.
- **Styling**: `_sass/` contains SCSS overrides. Theme skin is set to `dark` in `_config.yml`.
- **Assets**: `assets/` has images, JS (jQuery plugins minified via `uglifyjs` into `main.min.js`), and CSS.

## Front Matter Defaults

Posts default to `layout: single` with author profile, read time, Disqus comments, and related posts enabled. Pages default to `layout: single` with author profile.

## Plugins

jekyll-paginate, jekyll-sitemap, jekyll-gist, jekyll-feed, jemoji, jekyll-include-cache, jekyll-algolia.

## Key Conventions

- Permalink pattern: `/:categories/:title/`
- Markdown engine: kramdown with GFM input
- Posts use categories and tags for taxonomy (archives at `/categories/` and `/tags/`)
- Images go in `assets/images/`
