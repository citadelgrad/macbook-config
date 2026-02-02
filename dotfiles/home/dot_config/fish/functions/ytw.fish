function ytw --description "Extract wisdom from YouTube video using fabric-ai"
    set -l video_link $argv[1]
    fabric-ai -y "$video_link" --stream --pattern extract_wisdom
end
