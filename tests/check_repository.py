#!/usr/bin/env python3
"""Static repository checks only. No SQL connection or integration claim."""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
checks = 0


def check(condition, message):
    global checks
    checks += 1
    if not condition:
        raise AssertionError(message)


manifest = json.loads((ROOT / 'scripts/legacy-manifest.json').read_text())
check(len(manifest['files']) == 4, 'Expected four preserved original scripts')
for name, expected in manifest['files'].items():
    path = ROOT / name
    check(path.is_file(), 'Missing original script: ' + name)
    check(hashlib.sha256(path.read_bytes()).hexdigest() == expected,
          'Original script changed: ' + name)

for name in ['README.md', 'SETUP.md', 'docs/ARCHITECTURE.md', 'docs/QUALITY.md',
             'scripts/bootstrap_schemas.sql', 'scripts/quality_checks.sql', 'LICENSE']:
    check((ROOT / name).is_file(), 'Missing documented file: ' + name)


def executable_text(name):
    text = (ROOT / name).read_text()
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    return re.sub(r'--[^\n]*', '', text)


bootstrap = executable_text('scripts/bootstrap_schemas.sql')
check(not re.search(r'\b(DROP|TRUNCATE|DELETE|INSERT|UPDATE|ALTER)\b', bootstrap, re.I),
      'Bootstrap must not destroy, load or alter existing objects')
check('DB_ID' in bootstrap and bootstrap.count('SCHEMA_ID') == 3,
      'Bootstrap must guard database and schema creation')
quality = executable_text('scripts/quality_checks.sql')
check(not re.search(r'\b(DROP|TRUNCATE|DELETE|INSERT|UPDATE|ALTER|CREATE|EXEC(?:UTE)?|MERGE)\b', quality, re.I),
      'Quality checks must remain read-only')
check(len(re.findall(r'\bSELECT\b', quality, re.I)) >= 6, 'Expected issue queries')
readme = (ROOT / 'README.md').read_text()
check('not a complete runnable warehouse' in readme, 'README must state incomplete scope')
check(not list((ROOT / 'datasets').glob('**/*.csv')), 'No data files expected in this documentation refresh')
print(f'PASS: {checks} static repository checks. SQL Server execution and ETL correctness remain unverified.')
