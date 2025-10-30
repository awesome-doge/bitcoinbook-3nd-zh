#!/bin/bash
# Script to add missing AsciiDoc anchors before HTML table blocks

# Function to add anchor before a table
add_anchor() {
    local file=$1
    local anchor_id=$2
    local table_id=$3

    # Use sed to add [[anchor_id]] before ++++\n<table id="table_id">
    sed -i '' "/^++++$/,/<table id=\"$table_id\">/{
        /<table id=\"$table_id\">/i\\
[[${anchor_id}]]\\

    }" "$file"
}

# ch05_wallets.adoc - 9 tables
echo "Fixing ch05_wallets.adoc..."
file="zh-tw/ch05_wallets.adoc"

sed -i '' 's|^\(++++\)$|\[\[alice_tx_labels\]\]\
\1|' "$file" 2>/dev/null || true

# Use a more reliable approach with awk
awk '
/^++++$/ {
    if (!done["alice_tx_labels"] && getline next_line && next_line ~ /<table id="alice_tx_labels">/) {
        print "[[alice_tx_labels]]"
        print
        print next_line
        done["alice_tx_labels"] = 1
        next
    } else if (!done["bip_implicit_paths"] && next_line ~ /<table id="bip_implicit_paths">/) {
        print "[[bip_implicit_paths]]"
        print
        print next_line
        done["bip_implicit_paths"] = 1
        next
    } else if (!done["sample_descriptors"] && next_line ~ /<table id="sample_descriptors">/) {
        print "[[sample_descriptors]]"
        print
        print next_line
        done["sample_descriptors"] = 1
        next
    } else if (!done["table_4-5"] && next_line ~ /<table id="table_4-5">/) {
        print "[[table_4-5]]"
        print
        print next_line
        done["table_4-5"] = 1
        next
    } else if (!done["bip39_128_no_pass"] && next_line ~ /<table id="bip39_128_no_pass">/) {
        print "[[bip39_128_no_pass]]"
        print
        print next_line
        done["bip39_128_no_pass"] = 1
        next
    } else if (!done["bip39_128_w_pass"] && next_line ~ /<table id="bip39_128_w_pass"/) {
        print "[[bip39_128_w_pass]]"
        print
        print next_line
        done["bip39_128_w_pass"] = 1
        next
    } else if (!done["bip39_256_no_pass"] && next_line ~ /<table id="bip39_256_no_pass">/) {
        print "[[bip39_256_no_pass]]"
        print
        print next_line
        done["bip39_256_no_pass"] = 1
        next
    } else if (!done["table_4-8"] && next_line ~ /<table id="table_4-8"/) {
        print "[[table_4-8]]"
        print
        print next_line
        done["table_4-8"] = 1
        next
    } else if (!done["table_4-9"] && next_line ~ /<table id="table_4-9">/) {
        print "[[table_4-9]]"
        print
        print next_line
        done["table_4-9"] = 1
        next
    } else {
        print
        print next_line
        next
    }
}
{ print }
' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

echo "Done!"
