import json
import os
import sys
from PIL import Image, ImageChops, ImageStat

def mean_diff(a, b):
    diff = ImageChops.difference(a.convert("RGBA"), b.convert("RGBA"))
    stats = ImageStat.Stat(diff)
    return sum(stats.mean) / len(stats.mean)

def alpha_coverage(image):
    alpha = image.convert("RGBA").getchannel("A")
    hist = alpha.histogram()
    opaqueish = sum(hist[8:])
    return opaqueish / (image.width * image.height)

def contact_sheet(images, columns, output_path, cell_size=None):
    if cell_size is None:
        cell_size = images[0].size
    rows = (len(images) + columns - 1) // columns
    sheet = Image.new("RGBA", (columns * cell_size[0], rows * cell_size[1]), (0, 0, 0, 0))
    for index, image in enumerate(images):
        if image.size != cell_size:
            image = image.resize(cell_size, Image.Resampling.LANCZOS)
        x = (index % columns) * cell_size[0]
        y = (index // columns) * cell_size[1]
        sheet.alpha_composite(image, (x, y))
    sheet.save(output_path)

def main():
    if len(sys.argv) != 2:
        raise SystemExit("usage: analyze_horse_gallop.py <output-dir>")
    output_dir = sys.argv[1]

    frames = [
        Image.open(os.path.join(output_dir, f"gallop_{index:02d}.png")).convert("RGBA")
        for index in range(12)
    ]
    loop_end = Image.open(os.path.join(output_dir, "gallop_loop_end.png")).convert("RGBA")

    if any(image.getbbox() is None for image in frames):
        raise RuntimeError("At least one rendered frame is fully transparent")

    coverage = [alpha_coverage(image) for image in frames]
    consecutive = [mean_diff(frames[i], frames[(i + 1) % len(frames)]) for i in range(len(frames))]
    seam = mean_diff(frames[0], loop_end)

    if max(consecutive) < 0.25:
        raise RuntimeError("Gallop render has no measurable frame-to-frame motion")

    contact_sheet(frames, 4, os.path.join(output_dir, "gallop-contact-sheet-512.png"))
    contact_sheet(frames, 4, os.path.join(output_dir, "gallop-contact-sheet-96.png"), (96, 96))
    contact_sheet(frames, 4, os.path.join(output_dir, "gallop-contact-sheet-76.png"), (76, 76))

    for index, image in enumerate(frames):
        image.resize((96, 96), Image.Resampling.LANCZOS).save(
            os.path.join(output_dir, f"gallop_96_{index:02d}.png")
        )
        image.resize((76, 76), Image.Resampling.LANCZOS).save(
            os.path.join(output_dir, f"gallop_76_{index:02d}.png")
        )

    with open(os.path.join(output_dir, "render-metadata.json"), encoding="utf-8") as handle:
        metadata = json.load(handle)

    report = {
        "status": "PASS",
        "source": "Quaternius Ultimate Animated Animal Pack",
        "license": "CC0 1.0",
        "clip": metadata["action"],
        "preview_frames": 12,
        "target_app_horse_size_px": 76,
        "alpha_coverage_min": min(coverage),
        "alpha_coverage_max": max(coverage),
        "consecutive_frame_mean_diff_min": min(consecutive),
        "consecutive_frame_mean_diff_max": max(consecutive),
        "authored_loop_endpoint_mean_diff": seam,
        "notes": [
            "76 px output matches the current RaceLiveView horse-size ceiling.",
            "The app should consume baked 2D frames; the GLB does not need to ship in the iOS bundle.",
            "Loop endpoint metric is recorded for review and is not used as a hard gate in this first POC."
        ],
    }
    with open(os.path.join(output_dir, "poc-report.json"), "w", encoding="utf-8") as handle:
        json.dump(report, handle, indent=2, ensure_ascii=False)

    print(json.dumps(report, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
