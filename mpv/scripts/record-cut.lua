-- ~/.config/mpv/scripts/record-cut.lua

local is_recording = false
local start_time = 0
local outfile = ""

function toggle_cut_recording()
    if not is_recording then
        start_time = mp.get_property_number("time-pos", 0)
        is_recording = true
        mp.osd_message("⏺ Marked start at " .. string.format("%.2f", start_time) .. "s")
    else
        local end_time = mp.get_property_number("time-pos", 0)
        local duration = end_time - start_time
        if duration <= 0 then
            mp.osd_message("⚠️ Invalid duration")
            is_recording = false
            return
        end

        local input = mp.get_property("path")
        local title = mp.get_property("media-title"):gsub("[^%w_%-]", "_")
        local timestamp = os.date("%Y%m%d-%H%M%S")
        outfile = string.format("%s-%s.mkv", title, timestamp)

        local args = {
            "ffmpeg",
            "-ss", tostring(start_time),
            "-i", input,
            "-t", tostring(duration),
            "-c", "copy",
            "-avoid_negative_ts", "make_zero",
            outfile
        }

        mp.command_native_async({
            name = "subprocess",
            args = args,
            playback_only = false,
            detach = true,
        })

        mp.osd_message(string.format("✅ Saved clip: %s (%.2fs → %.2fs)", outfile, start_time, end_time))
        is_recording = false
    end
end

mp.add_key_binding("c", "toggle-cut-recording", toggle_cut_recording)

