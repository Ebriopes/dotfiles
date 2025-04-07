":NR  - Open the selected region in a new narrowed window
":NW  - Open the current visual window in a new narrowed window
":WR  - (In the narrowed window) write the changes back to the original buffer.
":NRV - Open the narrowed window for the region that was last visually selected.
":NUD - (In a unified diff) open the selected diff in 2 Narrowed windows
":NRP - Mark a region for a Multi narrowed window
":NRM - Create a new Multi narrowed window (after :NRP) - experimental!
":NRS - Enable Syncing the buffer content back (default on)
":NRN - Disable Syncing the buffer content back
":NRL - Reselect the last selected region and open it again in a narrowed window

vmap <leader>nw :NW<CR>

