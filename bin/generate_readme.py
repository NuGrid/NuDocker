# Markdown Table of Contents Generator
#
# This script processes a Markdown file (`README_src.md`) and enhances it by:
# 1. **Generating a Table of Contents (TOC)**  
#    - Extracts only `##` (H2) headers.
#    - Creates a list of links pointing to each section.
# 2. **Adding GitHub-compatible Anchors**  
#    - Converts section titles into URL-friendly anchors.
#    - Ensures unique anchor names if duplicates exist.
#    - Inserts anchors directly into the headers.
# 3. **Saving the Modified File**  
#    - Outputs the processed Markdown to `README.md` with the new TOC and anchors.

import re

# Input and output file paths
input_file = "README_src.md"
output_file = "README.md"

def generate_anchor(text):
    """Generate GitHub-compatible anchor from a heading."""
    text = text.lower().strip()
    text = re.sub(r"[^\w\s-]", "", text)  # Remove special characters
    text = text.replace(" ", "-")  # Replace spaces with hyphens
    return text

def process_markdown(input_file, output_file):
    """Reads a Markdown file, generates an index with only ## headers, inserts anchors, and saves the enhanced file."""
    with open(input_file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    toc = []
    new_lines = []
    seen_anchors = set()

    for line in lines:
        match = re.match(r"^(##)\s+(.*)", line)  # Match ONLY ## headers
        if match:
            title = match.group(2).strip()

            # Generate a unique anchor
            anchor = generate_anchor(title)
            if anchor in seen_anchors:
                count = 1
                while f"{anchor}-{count}" in seen_anchors:
                    count += 1
                anchor = f"{anchor}-{count}"
            seen_anchors.add(anchor)

            # Append to TOC (only ## headers)
            toc.append(f"- [{title}](#{anchor})")

            # Insert the anchor tag in the header
            line = f"{match.group(1)} {title} <a name=\"{anchor}\"></a>\n"

        new_lines.append(line)

    # Insert TOC after the first main header
    insert_index = next((i for i, l in enumerate(new_lines) if l.startswith("# ")), 0) + 1
    new_lines.insert(insert_index, "\n## Table of Contents\n" + "\n".join(toc) + "\n\n")

    # Write the enhanced file
    with open(output_file, "w", encoding="utf-8") as f:
        f.writelines(new_lines)

    print(f"README.md updated successfully with Table of Contents (only ## headers) and anchors.")

# Run the script
process_markdown(input_file, output_file)