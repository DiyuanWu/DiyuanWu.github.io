import markdown
import os
from pathlib import Path
import shutil
import re
from datetime import datetime

# Global HTML template with MathJax support and responsive design
JS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'js')
HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{my_title}</title>
    <link rel="stylesheet" href="styles.css">
    <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
    <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
</head>
<body>
    <div id="layout-wrapper">
        <button id="menu-toggle" aria-label="Toggle menu">☰</button>
        <div id="layout-menu">
            <ul>
                {my_menu_items}
            </ul>
        </div>
        <div id="layout-content">
            {my_content}
            <div id="footer">
                Last updated: {my_update_time}
            </div>
        </div>
    </div>
    <script src="./src/js/menu-toggle.js"></script>
</body>
</html>"""

def preprocess_math_formulas(md_content):
    """Preprocess math formulas in markdown content for MathJax"""
    # Convert inline math $...$ to \(...\) with proper escaping
    md_content = re.sub(r'(?<!\\)\$(.*?)(?<!\\)\$', r'\\\(\1\\\)', md_content)
    # Convert display math $$...$$ to \[...\] with proper escaping
    md_content = re.sub(r'(?<!\\)\$\$(.*?)(?<!\\)\$\$', r'\\\[\1\\\]', md_content)
    return md_content

def convert_md_to_html(md_content, title, menu_items):
    """Convert markdown content to HTML with template and MathJax support"""
    # Preprocess math formulas before markdown conversion
    md_content = preprocess_math_formulas(md_content)
    
    # Convert markdown to HTML with math extensions
    html_content = markdown.markdown(md_content, extensions=['fenced_code', 'tables'])
    
    # Replace single '-' with <br> for line breaks
    html_content = '\n'.join(
        f'<br>{line[1:]}' if line.startswith('-') else line
        for line in html_content.split('\n')
    )
    
    # Get current year and month for update time
    current_time = datetime.now()
    update_time = current_time.strftime("%Y-%m")

    # Create a safe dictionary for formatting
    format_dict = {
        'my_title': title,
        'my_menu_items': menu_items,
        'my_content': html_content,
        'my_update_time': update_time
    }
    
    # Use safe formatting with explicit keys
    return HTML_TEMPLATE.format_map(format_dict)

def generate_menu_items(pages):
    """Generate menu items for all pages"""
    menu_items = []
    # First add the Home item if it exists
    if "index" in pages:
        menu_items.append('<li><a href="index.html">Home</a></li>')
    
    # Add other pages in order, excluding index
    for page in pages:
        name = os.path.splitext(page)[0]
        if name != "index":  # Skip index since we already added it
            display_name = name.replace('_', ' ').capitalize()
            menu_items.append(
                f'<li><a href="{name}.html">{display_name}</a></li>'
            )

    return '\n'.join(menu_items)

def process_md_files():
    """Process all markdown files in ./md directory"""
    md_dir = Path('./src/md')
    output_dir = Path('./src/html')
    
    # Create output directory if it doesn't exist
    output_dir.mkdir(exist_ok=True)
    
    # Get all markdown files
    md_files = list(md_dir.glob('*.md'))
    if not md_files:
        print("No markdown files found in ./md directory")
        return
    
    # Generate menu items for all pages
    pages = [f.stem for f in md_files]
    menu_items = generate_menu_items(pages)
    
    # Process each markdown file
    for md_file in md_files:
        try:
            with open(md_file, 'r', encoding='utf-8') as f:
                md_content = f.read()
            
            # Convert to HTML
            html_file = output_dir / f"{md_file.stem}.html"
            html_content = convert_md_to_html(
                md_content,
                md_file.stem.replace('_', ' ').capitalize(),
                menu_items
            )
            
            # Write HTML file
            with open(html_file, 'w', encoding='utf-8') as f:
                f.write(html_content)
            
            print(f"Converted {md_file} to {html_file}")
            
        except Exception as e:
            print(f"Error processing {md_file}: {str(e)}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    process_md_files()

# How to use this script:
# 1. Create a directory named 'md' in the same folder as this script
# 2. Place your markdown files (.md) in the 'md' directory
#    - The first file should be named 'index.md' (this will be your homepage)
#    - Other files can be named anything (e.g., about.md, projects.md)
# 3. Run the script:
#    python mdtohtml.py
# 4. The script will:
#    - Convert all markdown files to HTML in the html directory
#    - Create a navigation menu linking all pages
#    - Copy styles.css to the html directory
# 5. Open the generated HTML files in your browser:
#    - Start with index.html
#    - Use the menu to navigate between pages
# 6. To add new pages:
#    - Add new markdown files to the 'md' directory
#    - Re-run the script
#    - The new pages will automatically appear in the menu
