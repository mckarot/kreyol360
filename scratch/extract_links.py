import re

with open("/Users/mathieu/.gemini/antigravity-ide/brain/7b46398b-a1b8-45cd-82cb-1a995cdf9faa/.system_generated/steps/823/content.md", "r", encoding="utf-8") as f:
    content = f.read()

# Search for any links pointing to fortdefrance.fr/
links = re.findall(r'https?://(?:www\.)?fortdefrance\.fr/[^\s"\'>\)]+', content)
filtered_links = [l for l in links if not re.search(r'/\d{4}/', l) and "wp-content" not in l and "#" not in l]
unique_links = sorted(list(set(filtered_links)))

print(f"Found {len(unique_links)} unique relevant links:")
for l in unique_links:
    print(l)
