#!/bin/bash

# Setup Git Repository & Push to GitHub
# Usage: ./setup-git.sh <github-repo-url>

set -e

echo "🚀 Setting up Git repository for Anichin iOS..."

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
else
    echo "✅ Git repository already initialized"
fi

# Add all files
echo "📝 Adding files..."
git add .

# Commit
echo "💾 Creating initial commit..."
git commit -m "Initial commit: Anichin iOS App with GitHub Actions" || echo "⚠️  No changes to commit"

# Rename branch to main
echo "🌿 Setting main branch..."
git branch -M main

# Add remote if provided
if [ -n "$1" ]; then
    REPO_URL="$1"
    echo "🔗 Adding remote origin: $REPO_URL"
    
    # Remove existing remote if any
    git remote remove origin 2>/dev/null || true
    
    git remote add origin "$REPO_URL"
    
    echo "⬆️  Pushing to GitHub..."
    git push -u origin main
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Repository pushed successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🎯 Next Steps:"
    echo "1. Go to: $REPO_URL/actions"
    echo "2. Wait for build to complete (~10-15 minutes)"
    echo "3. Download IPA from Artifacts"
    echo ""
    echo "🏷️  To create a release:"
    echo "   git tag v1.0.0"
    echo "   git push origin v1.0.0"
    echo ""
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Git repository initialized!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🔗 To push to GitHub, run:"
    echo "   git remote add origin https://github.com/username/repo.git"
    echo "   git push -u origin main"
    echo ""
    echo "Or run this script with repo URL:"
    echo "   ./setup-git.sh https://github.com/username/repo.git"
    echo ""
fi
