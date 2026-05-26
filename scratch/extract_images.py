import re

with open("/Users/mathieu/.gemini/antigravity-ide/brain/7b46398b-a1b8-45cd-82cb-1a995cdf9faa/.system_generated/steps/835/content.md", "r", encoding="utf-8") as f:
    content = f.read()

# Search for images or uploads links
img_links = re.findall(r'https?://(?:www\.)?fortdefrance\.fr/[^\s"\'>\)]+(?:jpg|jpeg|png)', content)
unique_img_links = sorted(list(set(img_links)))

print(f"Found {len(unique_img_links)} image links:")
for l in unique_img_links:
    print(l)
