function yts --description "YouTube video summary using fabric-ai"
    set -l video_link $argv[1]
    fabric-ai -y "$video_link" --stream --pattern summarize
end
