#!/usr/bin/env bash

set -euo pipefail

DATABASE_NAME="$1"
ROOM_ID="$2"

psql -U "${DATABASE_NAME}" <<EOF
DELETE FROM event_forward_extremities WHERE room_id = '${ROOM_ID}';
DELETE FROM event_backward_extremities WHERE room_id = '${ROOM_ID}';
DELETE FROM event_edges WHERE room_id = '${ROOM_ID}';
DELETE FROM room_depth WHERE room_id = '${ROOM_ID}';
DELETE FROM state_forward_extremities WHERE room_id = '${ROOM_ID}';
DELETE FROM events WHERE room_id = '${ROOM_ID}';
DELETE FROM event_json WHERE room_id = '${ROOM_ID}';
DELETE FROM state_events WHERE room_id = '${ROOM_ID}';
DELETE FROM current_state_events WHERE room_id = '${ROOM_ID}';
DELETE FROM room_memberships WHERE room_id = '${ROOM_ID}';
DELETE FROM feedback WHERE room_id = '${ROOM_ID}';
DELETE FROM topics WHERE room_id = '${ROOM_ID}';
DELETE FROM room_names WHERE room_id = '${ROOM_ID}';
DELETE FROM rooms WHERE room_id = '${ROOM_ID}';
DELETE FROM room_hosts WHERE room_id = '${ROOM_ID}';
DELETE FROM room_aliases WHERE room_id = '${ROOM_ID}';
DELETE FROM state_groups WHERE room_id = '${ROOM_ID}';
DELETE FROM state_groups_state WHERE room_id = '${ROOM_ID}';
DELETE FROM receipts_graph WHERE room_id = '${ROOM_ID}';
DELETE FROM receipts_linearized WHERE room_id = '${ROOM_ID}';
DELETE FROM event_search_content WHERE c1room_id = '${ROOM_ID}';
DELETE FROM guest_access WHERE room_id = '${ROOM_ID}';
DELETE FROM history_visibility WHERE room_id = '${ROOM_ID}';
DELETE FROM room_tags WHERE room_id = '${ROOM_ID}';
DELETE FROM room_tags_revisions WHERE room_id = '${ROOM_ID}';
DELETE FROM room_account_data WHERE room_id = '${ROOM_ID}';
DELETE FROM event_push_actions WHERE room_id = '${ROOM_ID}';
DELETE FROM local_invites WHERE room_id = '${ROOM_ID}';
DELETE FROM pusher_throttle WHERE room_id = '${ROOM_ID}';
DELETE FROM event_reports WHERE room_id = '${ROOM_ID}';
DELETE FROM public_room_list_stream WHERE room_id = '${ROOM_ID}';
DELETE FROM stream_ordering_to_exterm WHERE room_id = '${ROOM_ID}';
DELETE FROM event_auth WHERE room_id = '${ROOM_ID}';
DELETE FROM appservice_room_list WHERE room_id = '${ROOM_ID}';
VACUUM;
EOF
