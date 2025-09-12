# Blog

A simple Hugo blog hosted on GitHub Pages.

## Quick Start

### Local Development

```bash
git clone https://github.com/mbook-x86/blog.git
cd blog
git submodule update --init --recursive
./blog.sh dev
```

Open http://localhost:1313 in your browser.

### Create New Post

```bash
./blog.sh new post-name
```

Edit the generated file in `content/posts/` and set `draft = false` to publish.

### Deploy

```bash
./blog.sh deploy
```

## Project Structure

```
blog/
├── .github/workflows/    # GitHub Actions
├── content/posts/        # Blog posts
├── static/              # Static files
├── themes/PaperMod/     # Hugo theme
├── hugo.toml            # Hugo configuration
├── blog.sh              # Management script
└── README.md
```

## Tech Stack

- Static Site Generator: [Hugo](https://gohugo.io/)
- Theme: [PaperMod](https://github.com/adityatelange/hugo-PaperMod)
- Hosting: GitHub Pages
- CI/CD: GitHub Actions

## Commands

```bash
./blog.sh dev      # Start development server
./blog.sh build    # Build for production
./blog.sh clean    # Clean generated files
./blog.sh new      # Create new post
./blog.sh deploy   # Deploy to GitHub
./blog.sh help     # Show help
```

## GitHub Pages Setup

1. Go to repository Settings > Pages
2. Set Source to "GitHub Actions"
3. Push changes to main branch
4. Access your site at https://mbook-x86.github.io/blog/

## License

MIT License
