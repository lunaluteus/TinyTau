from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory
import unittest

SCRIPT = Path(__file__).with_name('rewrite-doc-links.py')


class RewriteDocLinksTests(unittest.TestCase):
    def test_rewrites_docgen_backlinks_relative_to_each_page(self):
        with TemporaryDirectory() as directory:
            site = Path(directory)
            documents = {
                'docs/index.html': (
                    '<a href=".//roadmap/index.md#start">Index</a>',
                    '<a href="../roadmap/index.html#start">Index</a>',
                ),
                'docs/RankLogConcave/BasePermutation.html': (
                    '<a href=".././/roadmap/rank-log-concave/index.qmd#tbl-base-perm">Roadmap</a>',
                    '<a href="../../roadmap/rank-log-concave/index.html#tbl-base-perm">Roadmap</a>',
                ),
                'docs/Example/Deep/Nested.html': (
                    '<a href="../.././/roadmap/a.qmd">Roadmap</a>',
                    '<a href="../../../roadmap/a.html">Roadmap</a>',
                ),
            }
            for name, (before, _) in documents.items():
                path = site / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(before, encoding='utf-8')

            for _ in range(2):
                subprocess.run([sys.executable, SCRIPT, '--site-dir', site], check=True)
                for name, (_, after) in documents.items():
                    with self.subTest(name=name):
                        self.assertEqual((site / name).read_text(encoding='utf-8'), after)

    def test_preserves_queries_fragments_and_external_links(self):
        with TemporaryDirectory() as directory:
            site = Path(directory)
            docs = site / 'docs'
            docs.mkdir()
            page = docs / 'index.html'
            authored = "<a href='/roadmap/a.qmd?file=x.md#label.md'>Roadmap</a>"
            external = '<a href="https://example.org/roadmap/a.qmd#label">External</a>'
            relative = '<a href="../roadmap/a.html#label">Relative</a>'
            page.write_text('\n'.join([authored, external, relative]), encoding='utf-8')

            subprocess.run([sys.executable, SCRIPT, '--site-dir', site], check=True)

            expected = "<a href='../roadmap/a.html?file=x.md#label.md'>Roadmap</a>"
            self.assertEqual(page.read_text(encoding='utf-8'), '\n'.join([expected, external, relative]))


if __name__ == '__main__':
    unittest.main()
