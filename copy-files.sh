#!/bin/bash

# Script to copy Recipe Genie iOS files to your Xcode project

echo "Copying Recipe Genie iOS files to your Xcode project..."

# Define source and destination paths
SOURCE_DIR="/Users/shana.russell/Dropbox (Personal)/_software projects/RecipeGenie ios App/recipe-genie/ios-app/RecipeGenie"
DEST_DIR="/Users/shana.russell/Dropbox (Personal)/_software projects/RecipeGenie ios App/recipe-genie/ios-app/RecipeGenie/RecipeGenie"

# Create directories if they don't exist
mkdir -p "$DEST_DIR/Models"
mkdir -p "$DEST_DIR/Views/Components"
mkdir -p "$DEST_DIR/ViewModels"
mkdir -p "$DEST_DIR/Services"
mkdir -p "$DEST_DIR/Utils"

# Copy files
echo "Copying Models..."
cp -r "$SOURCE_DIR/Models/" "$DEST_DIR/"

echo "Copying Views..."
cp -r "$SOURCE_DIR/Views/" "$DEST_DIR/"

echo "Copying ViewModels..."
cp -r "$SOURCE_DIR/ViewModels/" "$DEST_DIR/"

echo "Copying Services..."
cp -r "$SOURCE_DIR/Services/" "$DEST_DIR/"

echo "Copying Utils..."
cp -r "$SOURCE_DIR/Utils/" "$DEST_DIR/"

echo "Copying main files..."
cp "$SOURCE_DIR/README.md" "$DEST_DIR/"
cp "$SOURCE_DIR/SETUP.md" "$DEST_DIR/"
cp "$SOURCE_DIR/GEMINI_API_SETUP.md" "$DEST_DIR/"
cp "$SOURCE_DIR/SUMMARY.md" "$DEST_DIR/"

echo "All files have been copied successfully!"
echo "Please follow the SETUP.md guide to complete the integration with your Xcode project."