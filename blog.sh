#!/bin/bash

# Hugo Blog Management Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

show_help() {
    echo "Hugo Blog Management Script"
    echo ""
    echo "Usage:"
    echo "  $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  dev                    Start development server"
    echo "  build                  Build site for production"
    echo "  clean                  Clean generated files"
    echo "  new [post-name]       Create new post"
    echo "  deploy                 Deploy to GitHub"
    echo "  help                   Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 dev                # Start dev server"
    echo "  $0 build              # Build for production"
    echo "  $0 new my-post        # Create new post"
    echo "  $0 deploy             # Deploy to GitHub"
}

start_dev() {
    echo "Starting development server..."
    echo "Open http://localhost:1313 in your browser"
    echo "Press Ctrl+C to stop"
    echo ""
    hugo server --buildDrafts --bind 0.0.0.0 --port 1313
}

build_site() {
    echo "Building site..."
    rm -rf public/
    hugo --gc --minify
    echo "Build complete! Files generated in public/ directory"
}

clean_build() {
    echo "Cleaning generated files..."
    rm -rf public/ resources/ .hugo_build.lock
    echo "Clean complete!"
}

create_post() {
    local post_name="$1"
    
    if [[ -z "$post_name" ]]; then
        echo "Error: Please specify post name"
        echo "Example: $0 new my-first-post"
        exit 1
    fi
    
    post_name=$(echo "$post_name" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    
    hugo new content "posts/${post_name}.md"
    echo "New post created: content/posts/${post_name}.md"
    echo "Edit the file and set draft = false to publish"
}

deploy_to_github() {
    echo "Deploying to GitHub..."
    
    if [[ -z $(git status --porcelain) ]]; then
        echo "No changes to commit."
        return
    fi
    
    echo "Testing build..."
    if ! hugo --gc --minify --quiet; then
        echo "Error: Build failed."
        exit 1
    fi
    echo "Build test successful!"
    
    echo "Committing changes..."
    git add .
    
    commit_msg="Update blog content - $(date '+%Y/%m/%d %H:%M')"
    read -p "Commit message (Enter for default): " user_msg
    if [[ -n "$user_msg" ]]; then
        commit_msg="$user_msg"
    fi
    
    git commit -m "$commit_msg"
    
    echo "Pushing to GitHub..."
    git push origin main
    
    echo ""
    echo "Deploy complete!"
    echo "GitHub Actions will build and deploy your site."
    echo "Check progress: https://github.com/mbook-x86/blog/actions"
    echo "Site URL: https://mbook-x86.github.io/blog/"
}

main() {
    case "${1:-help}" in
        "dev"|"server"|"serve")
            start_dev
            ;;
        "build")
            build_site
            ;;
        "clean")
            clean_build
            ;;
        "new"|"post")
            create_post "$2"
            ;;
        "deploy"|"push")
            deploy_to_github
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "Error: Unknown command '$1'"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
