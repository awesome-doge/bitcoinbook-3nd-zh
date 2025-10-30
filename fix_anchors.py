#!/usr/bin/env python3
import re
import sys

def fix_anchors_in_file(filepath, table_ids):
    """Add AsciiDoc anchors before HTML tables"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for table_id in table_ids:
        # Pattern: ++++\n<table id="table_id">
        pattern = rf'(\+\+\+\+\n)(<table id="{table_id}")'
        replacement = rf'\1[[{table_id}]]\n\2'
        
        # Only replace if anchor doesn't already exist
        if f'[[{table_id}]]' not in content:
            content = re.sub(pattern, replacement, content, count=1)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed {filepath}")

# Fix all files
files_to_fix = [
    ('zh-tw/ch05_wallets.adoc', [
        'alice_tx_labels', 'bip_implicit_paths', 'sample_descriptors',
        'table_4-5', 'bip39_128_no_pass', 'bip39_128_w_pass',
        'bip39_256_no_pass', 'table_4-8', 'table_4-9'
    ]),
    ('zh-tw/ch06_transactions.adoc', [
        'terms_used_authorization_authentication', 'weight_factors'
    ]),
    ('zh-tw/ch07_authorization-authentication.adoc', [
        'without_p2sh', 'with_p2sh'
    ]),
    ('zh-tw/ch08_signatures.adoc', [
        'sighash_types_and_their', 'sighash_types_with_modifiers'
    ]),
    ('zh-tw/ch11_blockchain.adoc', [
        'block_structure1', 'block_header_structure_ch09'
    ]),
    ('zh-tw/ch12_mining.adoc', [
        'table_8-1', 'table_8-2', 'block_header_structure_ch10'
    ]),
]

for filepath, table_ids in files_to_fix:
    fix_anchors_in_file(filepath, table_ids)

print("\nAll files fixed!")
