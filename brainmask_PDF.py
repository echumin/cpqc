import os
from PIL import Image
from math import ceil

# Set the folder where your PNG brain mask images are stored
PNG_DIR = "/N/project/KBASE/neuroimaging/kbase2/derivatives/connQC/1_brainmask"

# Define how many images should go into each PDF file
PAGE_LIMIT = 300

# This will be the prefix used to name the output PDF files
# For example, the PDFs will be named like: Kbase2_brain_masks_1.pdf, Kbase2_brain_masks_2.pdf, etc.
OUTPUT_PDF_PREFIX = "Kbase2_brain_masks"

def get_png_images(png_dir):
    return sorted([
        os.path.join(png_dir, f)
        for f in os.listdir(png_dir)
        if f.lower().endswith(".png")
    ])

def save_pdfs(image_paths, output_prefix, page_limit, output_dir):
    total_chunks = ceil(len(image_paths) / page_limit)

    for i in range(total_chunks):
        chunk = image_paths[i * page_limit:(i + 1) * page_limit]
        images = []
        for path in chunk:
            try:
                images.append(Image.open(path).convert("RGB"))
            except Exception as e:
                print(f"Failed to load {path}: {e}")
        
        if images:
            pdf_name = f"{output_prefix}_{i + 1}.pdf"
            pdf_path = os.path.join(output_dir, pdf_name)
            images[0].save(pdf_path, save_all=True, append_images=images[1:])
            print(f"Saved {pdf_path} with {len(images)} pages.")

def main():
    png_images = get_png_images(PNG_DIR)
    if not png_images:
        print("No PNG files found in the directory.")
        return
    save_pdfs(png_images, OUTPUT_PDF_PREFIX, PAGE_LIMIT, PNG_DIR)

if __name__ == "__main__":
    main()
