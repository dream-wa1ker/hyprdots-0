# Detect TTY vs GUI
if status is-interactive

    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != linux
        starship init fish | source
    end

end
